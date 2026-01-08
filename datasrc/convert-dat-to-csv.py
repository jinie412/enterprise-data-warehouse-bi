import pandas as pd
import numpy as np
import re
import unicodedata

# ================= CONFIG =================
INPUT_FILE = "airports.dat"
OUTPUT_FILE = "airport_locations.csv"

HEADERS = [
    "AirportID", "Name", "City", "Country", "IATA", "ICAO",
    "Latitude", "Longitude", "Altitude", "Timezone", "DST",
    "TzDatabase", "Type", "Source"
]

# ================= HELPERS =================
def to_ascii(x: str) -> str:
    """Unicode → ASCII, trim"""
    if pd.isna(x):
        return ""
    x = unicodedata.normalize("NFKD", str(x))
    return x.encode("ascii", "ignore").decode("ascii").strip()

def clean_iata(x: str) -> str:
    """IATA: ASCII, A–Z, đúng 3 ký tự"""
    x = to_ascii(x).upper()
    x = re.sub(r"[^A-Z]", "", x)
    return x if len(x) == 3 else ""

def clean_float(x) -> float:
    """Parse float an toàn + round"""
    if pd.isna(x):
        return np.nan
    try:
        return round(float(str(x).replace(",", ".").strip()), 6)
    except ValueError:
        return np.nan

# ================= READ =================
df = pd.read_csv(
    INPUT_FILE,
    header=None,
    names=HEADERS,
    dtype=str,
    na_values=["\\N", "NULL", ""],
    keep_default_na=True
)

# ================= CLEAN TEXT =================
TEXT_COLS = ["Name", "City", "Country", "ICAO", "Type", "Source"]
for col in TEXT_COLS:
    df[col] = df[col].apply(to_ascii)

df["IATA"] = df["IATA"].apply(clean_iata)

# ================= CLEAN COORD =================
df["Latitude"] = df["Latitude"].apply(clean_float)
df["Longitude"] = df["Longitude"].apply(clean_float)

# ================= FILTER =================
df_clean = df[
    df["Latitude"].notna() &
    df["Longitude"].notna() &
    (df["Country"] == "United States") &
    (df["IATA"] != "") &
    df["Latitude"].between(-90, 90) &
    df["Longitude"].between(-180, 180)
]

# bỏ 2 dòng lỗi đặc biệt
df_clean = df_clean[~df_clean["AirportID"].isin(["3443", "3603"])]

# chỉ giữ cột cần dùng
df_clean = df_clean[
    [
        "AirportID",
        "Name",
        "City",
        "Country",
        "IATA",
        "ICAO",
        "Latitude",
        "Longitude",
    ]
]

# ================= EXPORT =================
df_clean.to_csv(
    OUTPUT_FILE,
    index=False,
    encoding="latin1",
    sep=",",
    lineterminator="\r\n",
    float_format="%.6f",
    quoting=0  # QUOTE_MINIMAL
)

# ================= VERIFY =================
print(f"Done! Rows before: {len(df)}, after clean: {len(df_clean)}")
print("Latitude dtype :", df_clean["Latitude"].dtype)
print("Longitude dtype:", df_clean["Longitude"].dtype)
print("Any null lat/long?",
      df_clean[["Latitude", "Longitude"]].isna().any().any())
print("IATA ASCII only?",
      df_clean["IATA"].apply(lambda x: all(ord(c) < 128 for c in x)).all())
