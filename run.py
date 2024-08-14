# my_flask_app/run.py
from app import app

if __name__ == '__main__':
    app.app.run(debug=True)