from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.secret_key = 'wash_sekretnyi_kluch_zdes'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://danielteshner:Isedim2112@localhost/test_db'
db = SQLAlchemy(app)
from . import routes, models

UPLOAD_FOLDER = '/Users/danielteshner/Desktop/Profit4you/images'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'  # Направлять неаутентифицированных пользователей на страницу входа

@login_manager.user_loader
def load_user(user_id):
    return models.UserAccount.query.get(user_id)
