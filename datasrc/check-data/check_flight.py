import pandas as pd

# === 1. Load file ===
df = pd.read_csv("check_flight.txt", sep=r"\s+", engine="python")

# === 2. Các cột khóa định danh 1 chuyến bay ===
# key_cols = ["Year_Value", "Month_Value", "Day_Value",
#             "Iata_Airline", "Flight_Number"]

key_cols = ["Year_Value", "Month_Value", "Day_Value",
            "Iata_Airline", "Flight_Number", "Scheduled_Departure"]

# === 3. Tìm các nhóm trùng lặp theo key ===
dup_groups = df.groupby(key_cols).filter(lambda g: len(g) > 1)


# === 4. Thêm cột Duplicate_Group cho dễ kiểm tra (không bắt buộc) ===
# dup_groups["Duplicate_Group"] = dup_groups[key_cols].astype(
#     str).agg("_".join, axis=1)
dup_groups["Duplicate_Group"] = dup_groups.apply(
    lambda row: "_".join(row[key_cols].astype(str)), axis=1
)


# === 5. Chỉ giữ các cột bạn cần ===
output_cols = [
    "Year_Value", "Month_Value", "Day_Value", "Day_Of_Week",
    "Iata_Airline", "Flight_Number", "Tail_Number",
    "Origin_Airport", "Destination_Airport", "Scheduled_Departure",
    "Duplicate_Group"   # giữ lại để dễ xem từng nhóm
]

final_output = dup_groups[output_cols].sort_values(key_cols)

# === 6. Xuất CSV ===
final_output.to_csv("duplicated_flights.csv", index=False)

print("Đã xuất duplicated_flights.csv — chỉ gồm các cột bạn yêu cầu!")
