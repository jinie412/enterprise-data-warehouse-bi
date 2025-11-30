import pandas as pd

df = pd.read_csv("airport_code_mapping.csv")

dotcodes = df['DOT_Code'].unique()
# print(dotcodes)
print("Tổng số unique:", len(dotcodes))
