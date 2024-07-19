import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager

app = Flask(__name__,
            static_folder='../static',
            static_url_path='/static',
            template_folder='../templates')

app.secret_key = 'wash_sekretnyi_kluch_zdes'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://danielteshner:Isedim2112@localhost/test_db'
db = SQLAlchemy(app)

# Import routes and models
from . import routes, models

UPLOAD_FOLDER = os.path.join(app.root_path, '../static/uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    return models.UserAccount.query.get(user_id)
