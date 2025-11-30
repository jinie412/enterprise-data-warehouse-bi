import pandas as pd

# Đọc file text
df = pd.read_csv("check_distance.txt", sep=r"\s+", engine="python")

# Gom nhóm theo cặp sân bay
grouped = df.groupby(["Destination_Airport", "Origin_Airport"])

rows_output = []

# Kiểm tra nhóm có nhiều distance khác nhau
for (dest, orig), group in grouped:
    unique_distances = group["Distance"].unique()

    if len(unique_distances) > 1:   # Bị trùng distance không đồng nhất
        rows_output.append({
            "Destination_Airport": dest,
            "Origin_Airport": orig,
            "Distance_Values": ", ".join(map(str, unique_distances)),
            "Count": len(group)
        })

# Chuyển sang DataFrame để xuất file
conflict_df = pd.DataFrame(rows_output)

# Xuất ra CSV
output_file = "conflict_airport_distance.csv"
conflict_df.to_csv(output_file, index=False, encoding="utf-8-sig")

print("Đã tạo file:", output_file)
print("Số lượng cặp sân bay có nhiều distance:", len(conflict_df))
