import os
import subprocess
import datetime
from dotenv import load_dotenv

load_dotenv()

def backup_db():
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = f"backup_{timestamp}.sql"
    
    db_url = os.environ.get("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/agripilot")
    
    print(f"Starting backup to {backup_file}...")
    try:
        subprocess.run(["pg_dump", db_url, "-f", backup_file], check=True)
        print("Backup completed successfully!")
    except Exception as e:
        print(f"Backup failed: {e}")

if __name__ == "__main__":
    backup_db()
