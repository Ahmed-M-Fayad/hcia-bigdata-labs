import pandas as pd
from sqlalchemy import create_engine

engine = create_engine("mysql+pymysql://root:root123@pyint-lab-mysql:3306/company")

print("\n--- Same JOIN query from the SQL session, now arriving as a DataFrame ---\n")
df = pd.read_sql("""
    SELECT e.first_name, e.last_name, d.department_name, d.budget
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id WHERE d.department_name = "Engineering";
""", engine)

# df = df.sort_values(by="budget", ascending=False)

print(df.to_string(index=False))

print("\n--- Optional round trip: writing the DataFrame back into MySQL ---\n")
df.to_sql("employees_backup", engine, if_exists="replace", index=False)
print("Done. Check Adminer (or the mysql CLI) for a new 'employees_backup' table.")
