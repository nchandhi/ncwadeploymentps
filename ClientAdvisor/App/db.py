# db.py
import os
# import pymssql
import psycopg2
from dotenv import load_dotenv

load_dotenv()

# server = os.environ.get('SQLDB_SERVER')
# database = os.environ.get('SQLDB_DATABASE')
# username = os.environ.get('SQLDB_USERNAME')
# password = os.environ.get('SQLDB_PASSWORD')

server = os.environ.get('POSTGRESQL_SERVER')
database = os.environ.get('POSTGRESQL_DATABASENAME')
username = os.environ.get('POSTGRESQL_USER')
password = os.environ.get('POSTGRESQL_PASSWORD')
sslmode='require'


def get_connection():

    # conn = pymssql.connect(
    #     server=server,
    #     user=username,
    #     password=password,
    #     database=database,
    #     as_dict=True
    # )  
    # return conn

    # Construct connection URI
    db_uri = f"postgresql://{username}:{password}@{server}/{database}?sslmode={sslmode}"
    conn = psycopg2.connect(db_uri) 
    return conn