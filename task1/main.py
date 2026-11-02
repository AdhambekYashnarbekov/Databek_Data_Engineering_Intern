import pandas as pd

df = pd.read_csv('orders.csv')
df['amount'] = pd.to_numeric(df['amount'], errors='coerce')
df['month'] = pd.to_datetime(df['created_at'], errors='coerce').dt.strftime('%Y-%m')

print("Invalid Rows Skipped")
print(df[df.isna().any(axis=1)])

print("\nRevenue")
print(df.dropna().groupby(['customer_id', 'month'])['amount'].sum().sort_values(ascending=False))