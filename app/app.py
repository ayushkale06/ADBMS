import sys
import os

# Prevent self-import collision when executed as 'python app/app.py'
current_dir = os.path.abspath(os.path.dirname(__file__))
if sys.path and os.path.abspath(sys.path[0]) == current_dir:
    sys.path.pop(0)

parent_dir = os.path.abspath(os.path.join(current_dir, '..'))
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

from app import create_app
from app.db import init_db_pool

app = create_app()

if __name__ == '__main__':
    print("Starting College Internship Management System...")
    init_db_pool()
    app.run(host='0.0.0.0', port=5000, debug=True)
