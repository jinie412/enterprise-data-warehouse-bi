import pandas as pd

# Đọc dữ liệu
file1 = pd.read_csv("Code-mapping/15_airport_left_mapping.csv")
file2 = pd.read_csv("OCT/airport_OCT_mapping.csv")

# Ghép dữ liệu (theo cột giống nhau)
df = pd.concat([file1, file2], ignore_index=True)

# Sort theo IATA_CODE
df = df.sort_values(by="IATA_CODE")

# Lưu vào thư mục cha (../)
df.to_csv("airport_code_mapping.csv", index=False)

print("DONE! File saved as airport_code_mapping.csv")
