from flask_login import UserMixin
from app import db

# Worker model
class Worker(db.Model):
    __tablename__ = 'worker_info'
    worker_id = db.Column(db.Integer, db.ForeignKey('users.worker_id'), primary_key=True)
    fullname = db.Column(db.String(255), nullable=False)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    last_messages_check = db.Column(db.DateTime, default=db.func.current_timestamp(), nullable=False)
    language_id = db.Column(db.Integer, db.ForeignKey('user_languages.language_id'), nullable=False, default=1)
    firm_id = db.Column(db.Integer, db.ForeignKey('worker_firms.firm_id'), nullable=True, default=1)
    transport_id = db.Column(db.Integer, db.ForeignKey('worker_transport_types.transport_id'), nullable=True)
    group_name_id = db.Column(db.Integer, db.ForeignKey('worker_group_names.group_name_id'), nullable=True)
    group_number_id = db.Column(db.Integer, db.ForeignKey('worker_group_numbers.group_number_id'), nullable=True)
    location_id = db.Column(db.Integer, db.ForeignKey('worker_location_list.location_id'), nullable=True)

    transport = db.relationship('WorkerTransportType', backref='workers')
    group_name = db.relationship('WorkerGroupName', backref='workers')
    group_number = db.relationship('WorkerGroupNumber', backref='workers')
    language = db.relationship('Language', backref='workers')
    firm = db.relationship('Firm', backref='workers')
    location = db.relationship('Location', backref='workers')

# Attendance model
class Attendance(db.Model):
    __tablename__ = 'attendance'
    worker_id = db.Column(db.Integer, db.ForeignKey('worker_info.worker_id'), primary_key=True)
    attendance_date = db.Column(db.Date, primary_key=True)
    day_type = db.Column(db.String(10), nullable=False)
    scheduled_start_time = db.Column(db.Time, nullable=True)
    scheduled_end_time = db.Column(db.Time, nullable=True)
    scheduled_work_hours = db.Column(db.Numeric(10,2), nullable=True)
    actual_work_hours = db.Column(db.Numeric(10,2), nullable=True)
    absence_reason = db.Column(db.String(255), nullable=True)
    break_time = db.Column(db.Time, nullable=True)

# Feedback model
class Feedback(db.Model):
    __tablename__ = 'feedbacks'
    feedback_id = db.Column(db.Integer, primary_key=True)
    feedback_date = db.Column(db.Date, nullable=False)
    worker_id = db.Column(db.String(255), nullable=True)
    feedback_text = db.Column(db.Text, nullable=False)

# ProcessType model
class ProcessType(db.Model):
    __tablename__ = 'process_types'
    process_id = db.Column(db.Integer, primary_key=True)
    process_name = db.Column(db.String(20), nullable=False, unique=True)

# Process model
class Process(db.Model):
    __tablename__ = 'process'
    process_entry_id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, nullable=False)
    worker_id = db.Column(db.Integer, db.ForeignKey('worker_info.worker_id'), nullable=False)
    scanned_items = db.Column(db.Integer, nullable=False)
    time_spent = db.Column(db.Numeric(10,2), nullable=False)
    process_id = db.Column(db.Integer, db.ForeignKey('process_types.process_id'), nullable=False)

    process_type = db.relationship('ProcessType', backref=db.backref('processes', lazy=True))
    worker = db.relationship('Worker', backref=db.backref('processes', lazy=True))

# ProcessTarget model
class ProcessTarget(db.Model):
    __tablename__ = 'process_targets'
    target_id = db.Column(db.Integer, primary_key=True)
    process_id = db.Column(db.Integer, db.ForeignKey('process_types.process_id'), nullable=False)
    target_date = db.Column(db.Date, nullable=False)
    target_items_per_hour = db.Column(db.Integer, nullable=False)

    process_type = db.relationship('ProcessType', backref=db.backref('targets', lazy=True))

# UserAccount model
class UserAccount(db.Model, UserMixin):
    __tablename__ = 'users'
    worker_id = db.Column(db.Integer, primary_key=True)
    worker_login = db.Column(db.String(255), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    access_level_id = db.Column(db.Integer, db.ForeignKey('user_access_levels.access_level_id'), nullable=False, default=1)
    is_logged_in = db.Column(db.Boolean, default=False, nullable=False)

    access_level = db.relationship('UserAccessLevel')
    worker = db.relationship('Worker', backref='user_account', uselist=False)

    def get_id(self):
        return str(self.worker_id)

# Language model
class Language(db.Model):
    __tablename__ = 'user_languages'
    language_id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(3), unique=True, nullable=False)
    name = db.Column(db.String(50), nullable=True)

# Firm model
class Firm(db.Model):
    __tablename__ = 'worker_firms'
    firm_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), unique=True, nullable=False)

# WorkerTransportType model
class WorkerTransportType(db.Model):
    __tablename__ = 'worker_transport_types'
    transport_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)

# WorkerGroupName model
class WorkerGroupName(db.Model):
    __tablename__ = 'worker_group_names'
    group_name_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)

# WorkerGroupNumber model
class WorkerGroupNumber(db.Model):
    __tablename__ = 'worker_group_numbers'
    group_number_id = db.Column(db.Integer, primary_key=True)
    number = db.Column(db.String(50), nullable=False)

# Message model
class Message(db.Model):
    __tablename__ = 'messages'
    message_id = db.Column(db.Integer, primary_key=True)
    message_content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    title = db.Column(db.String(255), nullable=False)
    sender_id = db.Column(db.Integer, db.ForeignKey('worker_info.worker_id'), nullable=False)
    has_attachments = db.Column(db.Boolean, default=False)

    sender = db.relationship('Worker', backref='sent_messages')
    recipients = db.relationship('MessageRecipient', backref='message', lazy='dynamic')

# MessageAttachment model
class MessageAttachment(db.Model):
    __tablename__ = 'message_attachments'
    attachment_id = db.Column(db.Integer, primary_key=True)
    message_id = db.Column(db.Integer, db.ForeignKey('messages.message_id'), nullable=False)
    file_path = db.Column(db.Text, nullable=False)
    file_type = db.Column(db.Text, nullable=True)

    message = db.relationship('Message', backref=db.backref('attachments', lazy=True))

# MessageGroupList model
class MessageGroupList(db.Model):
    __tablename__ = 'message_group_list'
    group_id = db.Column(db.Integer, primary_key=True)
    group_name = db.Column(db.String(255), nullable=False)

# MessageRecipient model
class MessageRecipient(db.Model):
    __tablename__ = 'message_recipients'
    message_id = db.Column(db.Integer, db.ForeignKey('messages.message_id'), primary_key=True)
    recipient_group_id = db.Column(db.Integer, db.ForeignKey('message_group_list.group_id'))
    recipient_user_id = db.Column(db.Integer, db.ForeignKey('worker_info.worker_id'))

    recipient_group = db.relationship('MessageGroupList', backref='recipients')
    recipient = db.relationship('Worker', backref='received_messages')

# UserAccessLevel model
class UserAccessLevel(db.Model):
    __tablename__ = 'user_access_levels'
    access_level_id = db.Column(db.Integer, primary_key=True)
    access_level_name = db.Column(db.String(50), unique=True, nullable=False)

# UserMessageGroup model
class UserMessageGroup(db.Model):
    __tablename__ = 'user_message_groups'
    user_id = db.Column(db.Integer, db.ForeignKey('worker_info.worker_id'), primary_key=True)
    group_id = db.Column(db.Integer, db.ForeignKey('message_group_list.group_id'), primary_key=True)

    user = db.relationship('Worker', backref='message_groups')
    group = db.relationship('MessageGroupList', backref='user_groups')

# Location model
class Location(db.Model):
    __tablename__ = 'worker_location_list'
    location_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)

# AbsenceRecord model
class AbsenceRecord(db.Model):
    __tablename__ = 'message_absence_records'
    record_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    worker_id = db.Column(db.Integer, db.ForeignKey('worker_info.worker_id'), nullable=False)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    message = db.Column(db.String(255), nullable=False)
    sent_at = db.Column(db.DateTime, default=db.func.current_timestamp(), nullable=False)
    file_url = db.Column(db.String(255), nullable=True)
    
    worker = db.relationship('Worker', backref='absence_records')
