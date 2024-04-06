from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.secret_key = 'wash_sekretnyi_kluch_zdes'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://danielteshner:Isedim2112@localhost/test_db'
db = SQLAlchemy(app)
from . import routes, models