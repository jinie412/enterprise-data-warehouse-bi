import pandas as pd

df = pd.read_csv("L_AIRPORT_ID.csv")

# Tách thành City(s), State, Airport_Name
df[['CityState', 'Airport_Name']] = df['Description'].str.split(
    pat=":",
    n=1,
    expand=True
)

df[['City', 'State']] = df['CityState'].str.rsplit(
    pat=",",
    n=1,
    expand=True
)

# Clean
df['City'] = df['City'].str.strip()
df['State'] = df['State'].str.strip()
df['Airport_Name'] = df['Airport_Name'].str.strip()

# Chỉ giữ state có độ dài 2 (US airports)
df_us = df[df['State'].str.len() == 2]

# Giữ lại đúng 4 cột (đổi "Code" nếu cột của bạn tên khác)
df_clean = df_us[['Code', 'City', 'State', 'Airport_Name']]

# Xuất file
df_clean.to_csv("L_AIRPORT_ID_US.csv", index=False)
