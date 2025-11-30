import pandas as pd
import re

# Load files
air = pd.read_csv("Code-mapping/IATA_OCT_remaining.csv")
dot = pd.read_csv("L_AIRPORT_ID_US.csv")

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


# Apply clean functions
air['CITY_TOKENS'] = air['CITY'].apply(clean_city)
air['NAME_TOKENS'] = air['AIRPORT'].apply(clean_name)

dot['CITY_TOKENS'] = dot['Cities'].apply(clean_city)
dot['NAME_TOKENS'] = dot['Airport_Name'].apply(clean_name)


# --------------------------------
# SPECIAL CASES (FULL LIST)
# --------------------------------
SPECIAL_CASES = {
    # (giữ nguyên toàn bộ danh sách 19 case)
    "ACV": {"Code": 10157, "Cities": "Arcata/Eureka", "State": "CA", "Airport_Name": "California Redwood Coast Humboldt County"},
    "BDL": {"Code": 10529, "Cities": "Hartford", "State": "CT", "Airport_Name": "Bradley International"},
    "CVG": {"Code": 11193, "Cities": "Cincinnati", "State": "OH", "Airport_Name": "Cincinnati/Northern Kentucky International"},
    "DCA": {"Code": 11278, "Cities": "Washington", "State": "DC", "Airport_Name": "Ronald Reagan Washington National"},
    "FSD": {"Code": 11775, "Cities": "Sioux Falls", "State": "SD", "Airport_Name": "Joe Foss Field"},
    "GCC": {"Code": 11865, "Cities": "Gillette", "State": "WY", "Airport_Name": "Northeast Wyoming Regional"},
    "GRK": {"Code": 11982, "Cities": "Killeen", "State": "TX", "Airport_Name": "Robert Gray AAF"},
    "GUM": {"Code": 12016, "Cities": "Guam", "State": "TT", "Airport_Name": "Guam International"},
    "IAD": {"Code": 12264, "Cities": "Washington", "State": "DC", "Airport_Name": "Washington Dulles International"},
    "MEI": {"Code": 13241, "Cities": "Meridian", "State": "MS", "Airport_Name": "Key Field"},
    "PPG": {"Code": 14222, "Cities": "Pago Pago", "State": "TT", "Airport_Name": "Pago Pago International"},
    "RKS": {"Code": 14543, "Cities": "Rock Springs", "State": "WY", "Airport_Name": "Southwest Wyoming Regional"},
    "SCE": {"Code": 14711, "Cities": "State College", "State": "PA", "Airport_Name": "State College Regional"},
    "CLD": {"Code": 11041, "Cities": "Carlsbad", "State": "CA", "Airport_Name": "McClellan-Palomar"},
    "HYA": {"Code": 12250, "Cities": "Hyannis", "State": "MA", "Airport_Name": "Cape Cod Gateway"},
    "ILG": {"Code": 12320, "Cities": "Wilmington", "State": "DE", "Airport_Name": "New Castle"},
    "VEL": {"Code": 15582, "Cities": "Vernal", "State": "UT", "Airport_Name": "Vernal Regional"},
    "WYS": {"Code": 15897, "Cities": "West Yellowstone", "State": "MT", "Airport_Name": "Yellowstone"}
}


# --------------------------------
# RESULT LISTS
# --------------------------------
matches = []
unmatched = []


# ============================================
# LOOP THROUGH FILE 1 (IATA) + DEBUG
# ============================================
for idx, a in air.iterrows():

    IATA = a["IATA_CODE"]

    print("\n\n========================================================")
    print(f"DEBUG FOR IATA = {IATA}")
    print("========================================================")
    print("IATA:", IATA)
    print("City:", a["CITY"])
    print("State:", a["STATE"])
    print("Airport Name:", a["AIRPORT"])
    print("City Tokens:", a["CITY_TOKENS"])
    print("Name Tokens:", a["NAME_TOKENS"])

    matched_row = None

    # -------------------------------------------------------
    # SPECIAL CASE
    # -------------------------------------------------------
    if IATA in SPECIAL_CASES:
        print("SPECIAL CASE TRIGGERED → AUTO MATCH")
        sc = SPECIAL_CASES[IATA]

        matches.append({
            "IATA_CODE": IATA,
            "DOT_Code": sc["Code"],
            "Cities": sc["Cities"],
            "State": sc["State"],
            "DOT_Airport_Name": sc["Airport_Name"],
            "IATA_Airport_Name": a["AIRPORT"]
        })

        dot = dot[dot["Code"] != sc["Code"]]
        air = air.drop(index=idx)
        continue

    # -------------------------------------------------------
    # STEP 1 — FILTER BY STATE
    # -------------------------------------------------------
    dot_state = dot[dot["State"] == a["STATE"]]

    if len(dot_state) == 0:
        print("→ FAIL at STEP 1 (NO DOT in same State)")
        unmatched.append({
            "IATA_CODE": IATA,
            "City": a["CITY"],
            "State": a["STATE"],
            "Airport": a["AIRPORT"]
        })
        continue

    # -------------------------------------------------------
    # STEP 2 — CITY TOKEN MATCH
    # -------------------------------------------------------
    print("\nSTEP 2 — CITY TOKEN MATCHING")

    candidates = []
    for _, d in dot_state.iterrows():
        city_overlap = set(a["CITY_TOKENS"]).intersection(
            set(d["CITY_TOKENS"]))

        if len(city_overlap) > 0:
            candidates.append(d)

    if len(candidates) == 0:
        print("→ FAIL at STEP 2 (NO CITY TOKEN MATCH)")
        unmatched.append({
            "IATA_CODE": IATA,
            "City": a["CITY"],
            "State": a["STATE"],
            "Airport": a["AIRPORT"]
        })
        continue

    # -------------------------------------------------------
    # STEP 3 — NAME MATCHING
    # -------------------------------------------------------
    print("\nSTEP 3 — NAME MATCHING")
    # print("IATA Name Tokens:", a["NAME_TOKENS"])

    name_iata = set(a["NAME_TOKENS"])

    # PRIORITY RULE
    if len(candidates) == 1:
        d = candidates[0]
        name_dot_set = set(d["NAME_TOKENS"])
        print("Only 1 candidate → priority rule check")
        print("DOT name tokens:", name_dot_set)
        print("Overlap:", name_iata.intersection(name_dot_set))

        if len(name_iata.intersection(name_dot_set)) >= 1:
            matched_row = d

    # OLD RULE (>=2 token overlap, choose max overlap)
    if matched_row is None:
        print("\nOLD RULE (>=2 token overlap, choose max overlap)")

        best_row = None
        best_overlap = 0

        for d in candidates:
            name_dot_set = set(d["NAME_TOKENS"])
            overlap = len(name_iata.intersection(name_dot_set))

            print(
                f"DOT {d['Code']} → DOT tokens {name_dot_set}, overlap = {overlap}")

            # Chỉ xét những dòng overlap ≥ 2
            if overlap >= 2:
                # Nếu overlap lớn hơn best_overlap → cập nhật
                if overlap > best_overlap:
                    best_overlap = overlap
                    best_row = d

        # Sau vòng lặp, nếu tìm được dòng tốt nhất thì gán
        if best_row is not None:
            matched_row = best_row

    # -------------------------------------------------------
    # FINAL DECISION
    # -------------------------------------------------------
    if matched_row is not None:
        print("\nFINAL → MATCHED WITH DOT:")
        print(dict(matched_row))

        matches.append({
            "IATA_CODE": IATA,
            "DOT_Code": matched_row["Code"],
            "Cities": matched_row["Cities"],
            "State": matched_row["State"],
            "DOT_Airport_Name": matched_row["Airport_Name"],
            "IATA_Airport_Name": a["AIRPORT"]
        })

        dot = dot[dot["Code"] != matched_row["Code"]]
        air = air.drop(index=idx)

    else:
        print("\nFINAL → UNMATCHED")
        unmatched.append({
            "IATA_CODE": IATA,
            "City": a["CITY"],
            "State": a["STATE"],
            "Airport": a["AIRPORT"]
        })


# --------------------------------
# OUTPUT
# --------------------------------
pd.DataFrame(matches).to_csv(
    "Code-mapping/15_airport_left_mapping.csv", index=False)
# pd.DataFrame(unmatched).to_csv("airport_unmatched.csv", index=False)

print("\nDONE!")
print("Matched:", len(matches))
print("Unmatched:", len(unmatched))
