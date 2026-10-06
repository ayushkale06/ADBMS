import os
import sys

# Ensure root directory is in sys.path
root_dir = os.path.abspath(os.path.dirname(__file__))
if root_dir not in sys.path:
    sys.path.insert(0, root_dir)

from app import create_app
from app.db import init_db_pool

app = create_app()

if __name__ == '__main__':
    print("Starting College Internship Management System...")
    init_db_pool()
    app.run(host='0.0.0.0', port=5000, debug=True)
