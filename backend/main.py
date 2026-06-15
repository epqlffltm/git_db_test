from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import pymysql

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_conn():
    return pymysql.connect(
        host='localhost',
        user='zerouser',
        password='zeropass123!',
        database='zerodb',
        charset='utf8mb4'
    )

@app.get("/api/members")
def get_members(page: int = 1):
    limit = 20
    offset = (page - 1) * limit
    conn = get_conn()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    cursor.execute("SELECT COUNT(*) as total FROM members")
    total = cursor.fetchone()['total']
    total_pages = -(-total // limit)

    cursor.execute("SELECT * FROM members LIMIT %s OFFSET %s", (limit, offset))
    rows = cursor.fetchall()
    cursor.close()
    conn.close()

    for row in rows:
        row['reg_date'] = str(row['reg_date'])

    return {
        "total": total,
        "total_pages": total_pages,
        "current_page": page,
        "members": rows
    }
