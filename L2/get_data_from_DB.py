import psycopg2
from datetime import datetime, timedelta
import csv


try:
    connection = psycopg2.connect(host="almpsql.ck0crvwvnxmw.ap-south-1.rds.amazonaws.com",dbname="radisyscimetricsdb",user="radisyscimetricsrw",password="C1metricsRad!sys")

    cursor = connection.cursor()

    thirty_days_ago = datetime.now() - timedelta(days=30)
    thirty_days_ago_str = thirty_days_ago.strftime('%Y-%m-%d')
    
    query = f"""
    SELECT * FROM l2component
    WHERE comp_date >= '{thirty_days_ago_str}';
    """

    cursor.execute(query)

    records = cursor.fetchall()

    column_names = [desc[0] for desc in cursor.description]

    csv_file_name = 'l2component_last_30_days.csv'

    with open(csv_file_name, mode='w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow(column_names)
        
        csv_writer.writerows(records)

    print(f"Data has been written to {csv_file_name}")

except Exception as error:
    print(f"Error fetching data: {error}")

finally:
    if cursor:
        cursor.close()
    if connection:
        connection.close()

