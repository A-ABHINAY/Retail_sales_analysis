import pandas as pd

# LOADING CSV FILES
customers=pd.read_csv("customers_data.csv")
products=pd.read_csv("products_data.csv")
orders=pd.read_csv("orders_data.csv")

# Printing the tables
print("\n",customers.head())
print("\n",products.head())
print("\n",orders.head())

# Changing data type of signup_date and order_date
customers["signup_date"] = pd.to_datetime(customers["signup_date"])
orders["order_date"] = pd.to_datetime(orders["order_date"])

# Printing the info
print("\n",customers.info())
print("\n",products.info())
print("\n",orders.info())

# Merge orders with customers
df = orders.merge(customers, on="customer_id", how="left")

# Merge with products
df = df.merge(products, on="product_id", how="left")

print(df.head())
print(df.shape)

# Checking null values
print(df.isnull().sum())

# Creating revenue column and profit column

df["revenue"]=df["quantity"]*df["selling_price"] * (1-df["discount_percent"]/100)
df["profit"]=df["revenue"]-(df["quantity"]*df["cost_price"])

print(df)         #Prints entire data after merging
print(df[["revenue", "profit"]].describe())
