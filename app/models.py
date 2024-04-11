from datetime import datetime
from app import db

class Worker(db.Model):
    __tablename__ = 'workers'
    worker_id = db.Column(db.String(255), db.ForeignKey('user_accounts.worker_id'), primary_key=True)
    fullname = db.Column(db.String(255), nullable=False)
    group_name = db.Column(db.String(50), nullable=True)
    group_number = db.Column(db.String(50), nullable=True)
    transport = db.Column(db.String(50), nullable=True)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    last_messages_check = db.Column(db.DateTime, default=db.func.current_timestamp(), nullable=False)
    language_id = db.Column(db.Integer, db.ForeignKey('languages.language_id'), nullable=False, default=1)
    firm_id = db.Column(db.Integer, db.ForeignKey('firms.firm_id'), nullable=True, default=1)

    # Отношения
    language = db.relationship('Language', backref='workers')
    firm = db.relationship('Firm', backref='workers')

class Attendance(db.Model):
    __tablename__ = 'attendance'
    worker_id = db.Column(db.String(255), db.ForeignKey('workers.worker_id'), primary_key=True)
    attendance_date = db.Column(db.Date, primary_key=True)
    day_type = db.Column(db.String(10), nullable=False)
    scheduled_start_time = db.Column(db.Time, nullable=True)
    scheduled_end_time = db.Column(db.Time, nullable=True)
    scheduled_work_hours = db.Column(db.Numeric(10,2), nullable=True)
    actual_work_hours = db.Column(db.Numeric(10,2), nullable=True)
    absence_reason = db.Column(db.String(255), nullable=True)
    break_time = db.Column(db.Time, nullable=True)

class Feedback(db.Model):
    __tablename__ = 'feedbacks'
    feedback_id = db.Column(db.Integer, primary_key=True)
    feedback_date = db.Column(db.Date, nullable=False)
    worker_id = db.Column(db.String(255), db.ForeignKey('workers.worker_id'), nullable=True)
    feedback_text = db.Column(db.Text, nullable=False)

class Notification(db.Model):
    __tablename__ = 'notifications'
    notification_id = db.Column(db.Integer, primary_key=True)
    send_date = db.Column(db.DateTime, nullable=False)
    message = db.Column(db.Text, nullable=False)
    recipient_id = db.Column(db.String(255), db.ForeignKey('workers.worker_id'), nullable=False)
    notification_tags = db.Column(db.String(255), nullable=False)
    is_read = db.Column(db.Boolean, nullable=False, default=False)
    read_date = db.Column(db.DateTime, nullable=True)
    sender_id = db.Column(db.String(255), db.ForeignKey('workers.worker_id'), nullable=False)
    flash_type = db.Column(db.Boolean, nullable=False, default=False)

class ProcessType(db.Model):
    __tablename__ = 'process_types'
    process_id = db.Column(db.Integer, primary_key=True)
    process_name = db.Column(db.String(20), nullable=False, unique=True)
    
class Process(db.Model):
    __tablename__ = 'process'
    process_entry_id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, nullable=False)
    worker_id = db.Column(db.String(255), db.ForeignKey('workers.worker_id'), nullable=False)
    scanned_items = db.Column(db.Integer, nullable=False)
    time_spent = db.Column(db.Numeric(10,2), nullable=False)
    process_id = db.Column(db.Integer, db.ForeignKey('process_types.process_id'), nullable=False)

    # Определения отношений
    process_type = db.relationship('ProcessType', backref=db.backref('processes', lazy=True))
    worker = db.relationship('Worker', backref=db.backref('processes', lazy=True))

class ProcessTarget(db.Model):
    __tablename__ = 'process_targets'
    target_id = db.Column(db.Integer, primary_key=True)
    process_id = db.Column(db.Integer, db.ForeignKey('process_types.process_id'), nullable=False)
    target_date = db.Column(db.Date, nullable=False)
    target_items_per_hour = db.Column(db.Integer, nullable=False)

    # Определение отношения
    process_type = db.relationship('ProcessType', backref=db.backref('targets', lazy=True))

class UserAccount(db.Model):
    __tablename__ = 'user_accounts'
    worker_id = db.Column(db.String(255), primary_key=True)
    password = db.Column(db.String(255), nullable=False)
    access_level = db.Column(db.String(10), nullable=False, default='user')
    is_logged_in = db.Column(db.Boolean, nullable=False, default=False)
    # Связь с таблицей workers
    worker = db.relationship('Worker', backref='user_account', uselist=False)

class Language(db.Model):
    __tablename__ = 'languages'
    language_id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(3), nullable=False, unique=True)
    name = db.Column(db.String(50), nullable=True)
    
class Firm(db.Model):
    __tablename__ = 'firms'
    firm_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), unique=True, nullable=False)