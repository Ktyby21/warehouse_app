from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, BooleanField, SubmitField
from wtforms.validators import DataRequired

class FeedbackForm(FlaskForm):
    content = TextAreaField('Отзыв', validators=[DataRequired()])
    anonymous = BooleanField('Отправить анонимно')
    submit = SubmitField('Отправить')
class NotificationForm(FlaskForm):
    recipient_id = StringField('Recipient ID', validators=[DataRequired()])
    message = TextAreaField('Message', validators=[DataRequired()])
    notification_tags = StringField('Tags')
    flash_type = BooleanField('Flash Type')
    submit = SubmitField('Send Notification')