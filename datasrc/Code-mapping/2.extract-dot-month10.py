import pandas as pd

# --- STEP 1: Đọc flights tháng 10 ---
df = pd.read_csv("OCT/flight_OCT.csv")

# Lấy distinct từ 2 cột ORIGIN & DESTINATION
codes = pd.unique(df[['ORIGIN_AIRPORT', 'DESTINATION_AIRPORT']].values.ravel())

# Tạo DataFrame
distinct_df = pd.DataFrame({'Code': codes})

# Giữ các mã dạng số (US DOT)
distinct_df = distinct_df[distinct_df['Code'].astype(str).str.isnumeric()]

# Sort tăng dần theo giá trị số
distinct_df = distinct_df.sort_values(by='Code', key=lambda x: x.astype(int))


# --- STEP 2: Map với L_AIRPORT_ID_US.csv để lấy Airport_Name, Cities, State ---
dot = pd.read_csv("L_AIRPORT_ID_US.csv")

# Merge theo cột Code
merged = distinct_df.merge(
    dot[['Code', 'City', 'State', 'Airport_Name']], on='Code', how='left')


# --- STEP 3: Xuất file CSV (ghi đè file sorted cũ) ---
merged.to_csv("OCT/OCT_airport_codes.csv", index=False)

print("Đã tạo FULL file OCT_airport_codes.csv!")
print("Tổng số mã US DOT trong tháng 10:", len(merged))
print("Số mã có mapping từ L_AIRPORT_ID_US:",
      merged['Airport_Name'].notna().sum())
print("Số mã KHÔNG match:", merged['Airport_Name'].isna().sum())
