import calendar
import os
import re
import mimetypes
import pandas as pd
from io import BytesIO
from flask_login import current_user, login_required, login_user, logout_user
from app import app, db
from flask import jsonify, request, render_template, redirect, send_from_directory, session, url_for, flash
from app.models import AbsenceRecord, Attendance, MessageAttachment, MessageGroupList, MessageRecipient, ProcessType, UserAccount, UserMessageGroup, Worker, Process, Feedback, Message
from datetime import datetime
from app.utils import calculate_performance, get_targets_for_period, handle_uploaded_file, requires_access_level, allowed_file, upload_to_google_drive
from werkzeug.utils import secure_filename

# Admin home page
@app.route('/admin/home')
@requires_access_level(['admin', 'superadmin'])
def admin_home():
    return render_template('admin_home.html')

# Workers page
@app.route('/workers')
@requires_access_level(['admin', 'superadmin'])
def workers():
    workers = Worker.query.all()
    return render_template('workers.html', workers=workers)

# Worker home page
@app.route('/worker')
@login_required
def worker_home():
    worker_id = current_user.worker_id
    worker = Worker.query.filter_by(worker_id=worker_id).first_or_404()
    return render_template('worker_home.html', worker=worker)

# User accounts page
@app.route('/user_accounts')
@requires_access_level(['admin', 'superadmin'])
def user_accounts():
    users = UserAccount.query.all()
    return render_template('user_accounts.html', users=users)

# Add user account
@app.route('/add_user', methods=['POST'])
@requires_access_level(['superadmin'])
def add_user():
    worker_login = request.form.get('worker_login')
    password = request.form.get('password')
    access_level_id = request.form.get('access_level_id')

    if UserAccount.query.filter_by(worker_login=worker_login).first():
        flash('User with this Worker Login already exists.', 'error')
        return redirect(url_for('user_accounts'))

    new_user = UserAccount(worker_login=worker_login, password=password, access_level_id=access_level_id)
    db.session.add(new_user)
    db.session.commit()
    flash('User added successfully.', 'success')
    return redirect(url_for('user_accounts'))

# Edit user account
@app.route('/edit_user/<int:worker_id>', methods=['GET', 'POST'])
@requires_access_level(['admin', 'superadmin'])
def edit_user(worker_id):
    user_to_edit = UserAccount.query.filter_by(worker_id=worker_id).first_or_404()

    if request.method == 'POST':
        password = request.form.get('password')
        access_level_id = request.form.get('access_level_id')

        if password:
            user_to_edit.password = password
            flash('Password updated successfully.', 'success')

        if access_level_id:
            user_to_edit.access_level_id = access_level_id
            flash('Access level updated successfully.', 'success')

        db.session.commit()
        return redirect(url_for('user_accounts'))

    return render_template('edit_user.html', user=user_to_edit)

# Delete user account
@app.route('/delete_user/<int:worker_id>')
@requires_access_level(['superadmin'])
def delete_user(worker_id):
    user = UserAccount.query.filter_by(worker_id=worker_id).first_or_404()
    db.session.delete(user)
    db.session.commit()
    flash('User deleted successfully.', 'success')
    return redirect(url_for('user_accounts'))

# Reset user password
@app.route('/reset_password/<int:worker_id>', methods=['POST'])
@requires_access_level(['superadmin'])
def reset_password(worker_id):
    user = UserAccount.query.filter_by(worker_id=worker_id).first()
    if not user:
        flash('User not found.', 'danger')
        return redirect(url_for('user_accounts'))

    new_password = request.form.get('new_password')
    if new_password:
        user.password = new_password
        db.session.commit()
        flash('Password has been reset successfully.', 'success')
    else:
        flash('No password provided.', 'warning')

    return redirect(url_for('edit_user', worker_id=worker_id))

# Login route
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        worker_login = request.form['worker_login']
        password = request.form['password']
        user = UserAccount.query.filter_by(worker_login=worker_login, password=password).first()

        if user:
            login_user(user)
            next_page = request.args.get('next', url_for('admin_home'))
            return redirect(next_page)
        else:
            flash('Invalid username or password.')
    return render_template('login.html')

# Logout route
@app.route('/logout')
def logout():
    logout_user()
    session.clear()
    flash('You have successfully logged out.', 'success')
    return redirect(url_for('login'))

# Data upload page
@app.route('/admin/data_upload')
@requires_access_level(['admin', 'superadmin'])
def data_upload():
    return render_template('data_upload.html')

# Upload user accounts data
@app.route('/admin/data_upload/upload_user_accounts', methods=['POST'])
@requires_access_level(['admin', 'superadmin'])
def upload_user_accounts():
    if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
    file = request.files['file']
    if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
    if file:
        try:
            stream = BytesIO(file.read())
            df = pd.read_excel(stream)
            for index, row in df.iterrows():
                worker_login = str(row['GD Number'])
                password = str(row['Password'])
                if not UserAccount.query.filter_by(worker_login=worker_login).first():
                    new_user = UserAccount(worker_login=worker_login, password=password)
                    db.session.add(new_user)
            db.session.commit()
            flash('File uploaded and processed successfully.', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'Error processing file: {e}', 'danger')
    return render_template('data_upload.html')

# Upload working hours data
@app.route('/admin/data_upload/upload_working_hours', methods=['GET', 'POST'])
@requires_access_level(['admin', 'superadmin'])
def upload_working_hours():
    if request.method == 'POST':
        file = request.files.get('file')
        if not file or file.filename == '':
            flash('No file selected', 'warning')
            return redirect(request.url)
        handle_uploaded_file(file.stream)
        flash('File uploaded successfully.', 'success')
    return render_template('data_upload.html')

# Upload process data
@app.route('/admin/data_upload/upload_process_data', methods=['POST'])
@requires_access_level(['admin', 'superadmin'])
def upload_process_data():
    file = request.files.get('file')
    if not file or file.filename == '':
        flash('No file selected', 'warning')
        return redirect(request.url)

    try:
        df = pd.read_excel(file, sheet_name=0)
        for index, row in df.iterrows():
            date = pd.to_datetime(row['Data']).date()
            worker_login = row['USER LOGIN']
            scanned_items = int(row['SZTUKI'])
            time_spent = float(row['CZAS'])
            process_name = row.get('process_name')

            if process_name:
                process_type = ProcessType.query.filter_by(process_name=process_name).first()
                if not process_type:
                    new_process_type = ProcessType(
                        process_name=process_name
                    )
                    db.session.add(new_process_type)
                    flash(f'Process "{process_name}" created.', 'warning')
                    continue
                process_id = process_type.process_id
            else:
                flash('Process name is missing in the row', 'warning')
                continue

            user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
            worker_id = user_account.worker_id
            if user_account:
                new_process = Process(
                    date=date,
                    worker_id=worker_id,
                    scanned_items=scanned_items,
                    time_spent=time_spent,
                    process_id=process_id
                )
                db.session.add(new_process)
            else:
                flash(f'Worker with ID {worker_id} not found.', 'warning')

        db.session.commit()
        flash('Process data uploaded successfully.', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Error processing file: {e}', 'danger')

    return render_template('data_upload.html')

@app.route('/worker/feedback', methods=['GET', 'POST'])
@login_required
def feedback():
    if request.method == 'POST':
        content = request.form.get('content')
        anonymous = request.form.get('anonymous')
        
        if not content:
            flash('Please enter your feedback.', 'danger')
        else:
            feedback_worker_id = current_user.worker_login if not anonymous else 'anonymous'
            feedback = Feedback(
                worker_id=feedback_worker_id,
                feedback_text=content,
                feedback_date=datetime.now()
            )
            db.session.add(feedback)
            db.session.commit()
            flash('Your feedback has been successfully submitted!', 'success')
            return redirect(url_for('feedback')) if anonymous else redirect(url_for('feedback'))
    
    return render_template('feedback.html')

# View feedbacks page
@app.route('/feedbacks')
@requires_access_level(['admin', 'superadmin'])
def view_feedbacks():
    feedbacks = Feedback.query.order_by(Feedback.feedback_id.desc()).all()
    return render_template('view_feedbacks.html', feedbacks=feedbacks)

# Feedback details page
@app.route('/feedbacks/<int:feedback_id>')
@requires_access_level(['admin', 'superadmin'])
def feedback_details(feedback_id):
    feedback = Feedback.query.get_or_404(feedback_id)
    return render_template('feedback_details.html', feedback=feedback)

# Performance data page
@app.route('/performance/<string:worker_login>/', methods=['GET'])
@login_required
def show_performance(worker_login):
    user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
    worker_id = user_account.worker_id
    if current_user.worker_id != worker_id:
        return "Access Denied", 403
    return render_template('performance.html', worker_id=worker_id)

# Handle performance data request
@app.route('/performance/data/', methods=['GET'])
@login_required
def handle_performance_request():
    worker_id = int(request.args.get('worker_id'))
    if current_user.worker_id != worker_id:
        return jsonify({"error": "Access Denied"}), 403
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')

    start_date_obj = datetime.strptime(start_date, '%m/%d/%Y').date()
    end_date_obj = datetime.strptime(end_date, '%m/%d/%Y').date()

    process_data = db.session.query(
        ProcessType.process_id,
        ProcessType.process_name,
        Process.date,
        db.func.sum(Process.scanned_items).label('scanned_items'),
        db.func.sum(Process.time_spent).label('time_spent')
    ).join(ProcessType).filter(
        Process.worker_id == worker_id,
        Process.date >= start_date_obj,
        Process.date <= end_date_obj
    ).group_by(ProcessType.process_id, ProcessType.process_name, Process.date).all()

    process_data_formatted = [
        {
            "process_id": data.process_id,
            "process_name": data.process_name,
            "date": data.date,
            "scanned_items": data.scanned_items,
            "time_spent": float(data.time_spent)
        } for data in process_data
    ]

    targets = get_targets_for_period(start_date_obj, end_date_obj)
    performance_results = calculate_performance(process_data_formatted, targets, start_date_obj, end_date_obj)

    return jsonify({
        'worker_id': worker_id,
        'start_date': start_date,
        'end_date': end_date,
        'data': performance_results
    })

# Schedule page
@app.route('/schedule/<string:worker_login>')
@login_required
def show_schedule(worker_login):
    user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
    worker_id = user_account.worker_id

    if current_user.worker_id != worker_id:
        return "Access Denied", 403

    return render_template('schedule.html', worker_id=worker_id)

# API to get schedule data
@app.route('/api/schedule/<string:worker_login>')
@login_required
def get_schedule(worker_login):
    user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
    worker_id = user_account.worker_id

    if current_user.worker_id != worker_id:
        return jsonify({"error": "Access Denied"}), 403

    year = request.args.get('year', type=int)
    month = request.args.get('month', type=int)

    if not year or not month:
        return jsonify({"error": "Year and month parameters are required"}), 400

    schedule_data = Attendance.query.filter(
        Attendance.worker_id == worker_id,
        db.extract('year', Attendance.attendance_date) == year,
        db.extract('month', Attendance.attendance_date) == month
    ).all()
    
    events = []
    for entry in schedule_data:
        if entry.day_type != 'P':
            title = entry.day_type
        else:
            start_time = entry.scheduled_start_time.strftime('%H:%M') if entry.scheduled_start_time else 'Unknown'
            end_time = entry.scheduled_end_time.strftime('%H:%M') if entry.scheduled_end_time else 'Unknown'
            title = f"{start_time}-{end_time}"

        event = {
            'title': title,
            'start': entry.attendance_date.strftime('%Y-%m-%d'),
            'allDay': True,
            'absenceReason': entry.absence_reason if entry.absence_reason else ''
        }
        events.append(event)
    
    return jsonify(events)

# Messages page
@app.route('/messages')
@login_required
def show_messages():
    if current_user.is_authenticated:
        worker = Worker.query.filter_by(worker_id=current_user.worker_id).first()
        if worker:
            worker.last_messages_check = datetime.now()
            db.session.commit()

    group_ids = db.session.query(UserMessageGroup.group_id).filter(UserMessageGroup.user_id == current_user.worker_id).subquery()
    
    group_messages_query = db.session.query(Message).join(
        MessageRecipient,
        Message.message_id == MessageRecipient.message_id
    ).filter(
        MessageRecipient.recipient_group_id.in_(group_ids)
    )

    personal_messages_query = db.session.query(Message).join(
        MessageRecipient,
        Message.message_id == MessageRecipient.message_id
    ).filter(
        MessageRecipient.recipient_user_id == current_user.worker_id
    )

    all_messages = group_messages_query.union(personal_messages_query).order_by(Message.created_at.desc()).all()

    return render_template('messages.html', messages=all_messages)

# Message details page
@app.route('/message/<int:message_id>')
@login_required
def message_details(message_id):
    message = Message.query.filter_by(message_id=message_id).first_or_404()
    attachments = MessageAttachment.query.filter_by(message_id=message_id).all()
    return render_template('message_details.html', message=message, attachments=attachments)

# Serve uploaded files
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# API to get new messages count
@app.route('/api/new-messages-count')
def new_messages_count():
    if not current_user.is_authenticated:
        return jsonify({"error": "Unauthorized"}), 401

    current_user_id = current_user.worker_id
    last_checked = Worker.query.filter_by(worker_id=current_user_id).first().last_messages_check
    group_ids = [group.group_id for group in UserMessageGroup.query.filter_by(user_id=current_user_id).all()]
    messages_count = Message.query.join(MessageRecipient).filter(
        db.or_(
            db.and_(
                MessageRecipient.recipient_user_id == current_user_id,
                Message.created_at > last_checked
            ),
            db.and_(
                MessageRecipient.recipient_group_id.in_(group_ids),
                Message.created_at > last_checked
            )
        )
    ).count()
    return jsonify(count=messages_count)

# Absence form page
@app.route('/absence-form')
@login_required
def absence_form():
    return render_template('absence_form.html')

# Submit absence form
@app.route('/submit-absence-form', methods=['POST'])
def submit_absence_form():
    try:
        start_date_str = request.form['start_date']
        end_date_str = request.form['end_date']
        start_date = datetime.strptime(start_date_str, '%d-%m-%Y').strftime('%Y-%m-%d')
        end_date = datetime.strptime(end_date_str, '%d-%m-%Y').strftime('%Y-%m-%d')
        reason = request.form['reason']
        custom_reason = request.form['custom_reason'] if request.form['reason'] == 'other' else reason
        file = request.files.get('file')
        file_url = None
        
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file_url = upload_to_google_drive(file)

        new_absence = AbsenceRecord(
            worker_id=current_user.worker_id,
            start_date=start_date,
            end_date=end_date,
            message=custom_reason,
            file_url=file_url
        )
        db.session.add(new_absence)
        db.session.commit()
        flash('Attendance send.')

    except Exception as e:
        db.session.rollback()
        flash(f'Form error: {e}')

    return redirect(url_for('absence_form'))

# Worker attendance page
@app.route('/worker/attendance', methods=['GET', 'POST'])
@login_required
def worker_attendance():
    worker_id = current_user.worker_id
    now = datetime.now()
    month = int(request.form.get('month', now.month))
    year = int(request.form.get('year', now.year))

    first_day = datetime(year, month, 1)
    last_day = datetime(year, month, calendar.monthrange(year, month)[1])

    attendance_records = Attendance.query.filter(
        Attendance.worker_id == worker_id,
        Attendance.attendance_date >= first_day,
        Attendance.attendance_date <= last_day
    ).all()
    attendance_dict = {record.attendance_date: record for record in attendance_records}

    attendance = []
    for day in range(1, last_day.day + 1):
        day_date = datetime(year, month, day)
        record = attendance_dict.get(day_date.date(), None)
        attendance.append({
            'date': day_date,
            'day_type': record.day_type if record else '',
            'start_time': record.scheduled_start_time.strftime('%H:%M') if record and record.scheduled_start_time else '',
            'end_time': record.scheduled_end_time.strftime('%H:%M') if record and record.scheduled_end_time else '',
            'work_hours': record.actual_work_hours if record else '',
            'absence_reason': record.absence_reason if record else '',
            'break_time': record.break_time.strftime('%H:%M') if record and record.break_time else ''
        })

    total_scheduled = sum([rec['work_hours'] for rec in attendance if rec['work_hours']])
    total_actual = sum([rec['work_hours'] for rec in attendance if rec['work_hours']])

    return render_template('attendance.html', attendance=attendance, total_scheduled=total_scheduled, total_actual=total_actual, month=month, year=year)

# Send message route
@app.route('/send-message', methods=['GET', 'POST'])
@login_required
def send_message():
    if request.method == 'POST':
        title = request.form.get('title')
        content = request.form.get('content')
        recipient = request.form.get('recipient')
        group_id = request.form.get('group_id')

        new_message = Message(
            title=title,
            message_content=content,
            sender_id=current_user.worker_id,
            has_attachments='<img' in content
        )
        db.session.add(new_message)
        db.session.flush()

        urls = re.findall(r'src="([^"]+)"', content)
        for url in urls:
            filename = url.split('/')[-1]
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file_type, _ = mimetypes.guess_type(filepath)
            if not file_type:
                file_type = 'application/octet-stream'

            attachment = MessageAttachment(
                message_id=new_message.message_id,
                file_path=filepath,
                file_type=file_type
            )
            db.session.add(attachment)

        if recipient:
            recipient_user = UserAccount.query.filter_by(worker_login=recipient).first()
            if recipient_user:
                recipient_entry = MessageRecipient(
                    message_id=new_message.message_id,
                    recipient_user_id=recipient_user.worker_id
                )
                db.session.add(recipient_entry)

        if group_id:
            recipient_entry = MessageRecipient(
                message_id=new_message.message_id,
                recipient_group_id=group_id
            )
            db.session.add(recipient_entry)

        db.session.commit()
        return jsonify({'success': True})

    groups = MessageGroupList.query.all()
    return render_template('send_message.html', groups=groups)

# Upload files route
@app.route('/upload-files', methods=['POST'])
def upload_files():
    files = request.files.getlist('files[]')
    urls = []
    for file in files:
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        file_url = url_for('static', filename='uploads/' + filename, _external=True)
        urls.append(file_url)

    return jsonify(urls=urls)
