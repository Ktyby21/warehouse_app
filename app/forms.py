from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, BooleanField, SubmitField
from wtforms.validators import DataRequired

class FeedbackForm(FlaskForm):
    content = TextAreaField('Отзыв', validators=[DataRequired()])
    anonymous = BooleanField('Отправить анонимно')
    submit = SubmitField('Отправить')
