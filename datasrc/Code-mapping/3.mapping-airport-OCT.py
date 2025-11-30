import pandas as pd
import re

# Load files
air = pd.read_csv("airports.csv")
dot = pd.read_csv("OCT/OCT_airport_codes.csv")

# -----------------------------
# CLEAN FUNCTIONS
# -----------------------------


def clean_name(s):
    if not isinstance(s, str):
        return []
    s = s.lower().replace("airport", "")
    for sym in ["-", "/", "(", ")", ","]:
        s = s.replace(sym, " ")
    s = re.sub(r"\s+", " ", s).strip()
    return [t for t in s.split(" ") if t]


def clean_city(c):
    if not isinstance(c, str):
        return []
    tokens = []
    for sym in ["-", "/", "(", ")", ","]:
        c = c.replace(sym, " ")
    for x in c.split("/"):
        tokens += x.strip().lower().split()
    return tokens


air['CITY_TOKENS'] = air['CITY'].apply(clean_city)
air['NAME_TOKENS'] = air['AIRPORT'].apply(clean_name)

dot['CITY_TOKENS'] = dot['Cities'].apply(clean_city)
dot['NAME_TOKENS'] = dot['Airport_Name'].apply(clean_name)

# --------------------------------
# SPECIAL CASE FOR ACV
# --------------------------------
SPECIAL_CASES = {
    "ACV": {
        "Code": 10157,
        "Cities": "Arcata/Eureka",
        "State": "CA",
        "Airport_Name": "California Redwood Coast Humboldt County"
    },

    "BDL": {
        "Code": 10529,
        "Cities": "Hartford",
        "State": "CT",
        "Airport_Name": "Bradley International"
    },

    "CVG": {
        "Code": 11193,
        "Cities": "Cincinnati",
        "State": "OH",
        "Airport_Name": "Cincinnati/Northern Kentucky International"
    },

    "DCA": {
        "Code": 11278,
        "Cities": "Washington",
        "State": "DC",
        "Airport_Name": "Ronald Reagan Washington National"
    },

    "FSD": {
        "Code": 11775,
        "Cities": "Sioux Falls",
        "State": "SD",
        "Airport_Name": "Joe Foss Field"
    },

    "GCC": {
        "Code": 11865,
        "Cities": "Gillette",
        "State": "WY",
        "Airport_Name": "Northeast Wyoming Regional"
    },

    "GRK": {
        "Code": 11982,
        "Cities": "Killeen",
        "State": "TX",
        "Airport_Name": "Robert Gray AAF"
    },

    "GUM": {
        "Code": 12016,
        "Cities": "Guam",
        "State": "TT",
        "Airport_Name": "Guam International"
    },

    "IAD": {
        "Code": 12264,
        "Cities": "Washington",
        "State": "DC",
        "Airport_Name": "Washington Dulles International"
    },

    "MEI": {
        "Code": 13241,
        "Cities": "Meridian",
        "State": "MS",
        "Airport_Name": "Key Field"
    },

    "PPG": {
        "Code": 14222,
        "Cities": "Pago Pago",
        "State": "TT",
        "Airport_Name": "Pago Pago International"
    },

    "RKS": {
        "Code": 14543,
        "Cities": "Rock Springs",
        "State": "WY",
        "Airport_Name": "Southwest Wyoming Regional"
    },

    "SCE": {
        "Code": 14711,
        "Cities": "State College",
        "State": "PA",
        "Airport_Name": "State College Regional"
    },

    "CLD": {
        "Code": 11041,
        "Cities": "Carlsbad",
        "State": "CA",
        "Airport_Name": "McClellan-Palomar"
    },

    "HYA": {
        "Code": 12250,
        "Cities": "Hyannis",
        "State": "MA",
        "Airport_Name": "Cape Cod Gateway"
    },

    "ILG": {
        "Code": 12320,
        "Cities": "Wilmington",
        "State": "DE",
        "Airport_Name": "New Castle"
    },

    "VEL": {
        "Code": 15582,
        "Cities": "Vernal",
        "State": "UT",
        "Airport_Name": "Vernal Regional"
    },

    "WYS": {
        "Code": 15897,
        "Cities": "West Yellowstone",
        "State": "MT",
        "Airport_Name": "Yellowstone"
    }
}


matches = []
unmatched = []

# ============================================
# DUYỆT THEO FILE DOT
# ============================================
for idx, d in dot.iterrows():

    matched_row = None

    # -----------------------------
    # SPECIAL CASE
    # -----------------------------
    for iata_code, sc in SPECIAL_CASES.items():
        if d["Code"] == sc["Code"]:
            a = air[air["IATA_CODE"] == iata_code]
            if len(a) == 1:
                a = a.iloc[0]

                matches.append({
                    "IATA_CODE": iata_code,
                    "DOT_Code": d["Code"],
                    "Cities": d["Cities"],
                    "State": d["State"],
                    "DOT_Airport_Name": d["Airport_Name"],
                    "IATA_Airport_Name": a["AIRPORT"]
                })

                # XOÁ TRỰC TIẾP DÒNG TRONG FILE 1
                air.drop(index=a.name, inplace=True)

            # Và xóa luôn dòng DOT này
            dot.drop(index=idx, inplace=True)
            break

    # Nếu là special-case thì không chạy tiếp
    if idx not in dot.index:
        continue

    # -----------------------------
    # STEP 1 — FILTER BY STATE
    # -----------------------------
    air_state = air[air["STATE"] == d["State"]]

    if len(air_state) == 0:
        unmatched.append({
            "DOT_Code": d['Code'],
            "Cities": d['Cities'],
            "State": d['State'],
            "DOT_Airport_Name": d['Airport_Name']
        })
        dot.drop(index=idx, inplace=True)
        continue

    # -----------------------------
    # STEP 2 — CITY TOKEN
    # -----------------------------

    candidates = []
    for _, a in air_state.iterrows():
        if len(set(a['CITY_TOKENS']).intersection(set(d['CITY_TOKENS']))) > 0:
            candidates.append(a)

    if len(candidates) == 0:
        unmatched.append({
            "DOT_Code": d['Code'],
            "Cities": d['Cities'],
            "State": d['State'],
            "DOT_Airport_Name": d['Airport_Name']
        })
        dot.drop(index=idx, inplace=True)
        continue

    # -----------------------------
    # STEP 3 — NAME MATCHING
    # -----------------------------
    name_dot = set(d["NAME_TOKENS"])

    # PRIORITY RULE (chỉ còn 1 candidate)
    if len(candidates) == 1:
        a = candidates[0]
        if len(name_dot.intersection(set(a['NAME_TOKENS']))) >= 1:
            matched_row = a

    # RULE MỚI (>=2 token nhưng chọn dòng có overlap max)
    if matched_row is None:

        best_row = None
        best_overlap = 0

        for a in candidates:
            overlap = len(set(a['NAME_TOKENS']).intersection(name_dot))

            # Chỉ xét khi overlap >= 2
            if overlap >= 2:

                # Nếu overlap lớn hơn max → cập nhật
                if overlap > best_overlap:
                    best_overlap = overlap
                    best_row = a

        # Sau khi duyệt xong → nếu có best_row thì dùng nó
        if best_row is not None:
            matched_row = best_row

    # -----------------------------
    # LƯU KẾT QUẢ
    # -----------------------------
    if matched_row is not None:

        matches.append({
            "IATA_CODE": matched_row["IATA_CODE"],
            "DOT_Code": d["Code"],
            "Cities": d["Cities"],
            "State": d["State"],
            "DOT_Airport_Name": d["Airport_Name"],
            "IATA_Airport_Name": matched_row["AIRPORT"]
        })

        # XOÁ TRỰC TIẾP TRONG FILE 1 ĐÚNG THEO YÊU CẦU
        air.drop(index=matched_row.name, inplace=True)

        # XÓA DÒNG DOT
        dot.drop(index=idx, inplace=True)

    else:
        unmatched.append({
            "DOT_Code": d['Code'],
            "Cities": d['Cities'],
            "State": d['State'],
            "DOT_Airport_Name": d['Airport_Name']
        })
        dot.drop(index=idx, inplace=True)


# --------------------------------
# OUTPUT
# --------------------------------
pd.DataFrame(matches).to_csv("OCT/airport_OCT_mapping.csv", index=False)
pd.DataFrame(unmatched).to_csv(
    "OCT/airport_OCT_unmatched.csv", index=False)
air.to_csv("Code-mapping/IATA_OCT_remaining.csv", index=False)

print("DONE!")
print(f"Matched: {len(matches)}")
print(f"Unmatched: {len(unmatched)}")
