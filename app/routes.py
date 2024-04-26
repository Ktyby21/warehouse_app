import calendar
import os
from flask_login import current_user, login_required, login_user, logout_user
from app import app, db
from flask import jsonify, request,render_template, request, redirect, send_from_directory, session, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from app.models import AbsenceRecord, Attendance, MessageAttachment, MessageGroupList, MessageRecipient, ProcessType, UserAccount, UserMessageGroup, Worker, Process, Feedback, Message
from datetime import datetime
from app.utils import calculate_performance, get_targets_for_period, handle_uploaded_file, requires_access_level 
import pandas as pd
from io import BytesIO
from .forms import FeedbackForm
from werkzeug.utils import secure_filename


@app.route('/admin/home')
@requires_access_level(['admin', 'superadmin'])
def admin_home():
    return render_template('admin_home.html')

@app.route('/workers')
@requires_access_level(['admin', 'superadmin'])
def workers():
    workers = Worker.query.all()
    return render_template('workers.html', workers=workers)

@app.route('/worker')
@login_required
def worker_home():
    # Поскольку каждый пользователь видит только свою страницу, мы можем использовать current_user
    worker_id = current_user.worker_id

    # Загружаем информацию о работнике
    worker = Worker.query.filter_by(worker_id=worker_id).first_or_404()
    return render_template('worker_home.html', worker=worker)


@app.route('/user_accounts')
@requires_access_level(['admin', 'superadmin'])
def user_accounts():
    users = UserAccount.query.all()
    return render_template('user_accounts.html', users=users)

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

@app.route('/edit_user/<int:worker_id>', methods=['GET', 'POST'])
@requires_access_level(['admin', 'superadmin'])
def edit_user(worker_id):
    user_to_edit = UserAccount.query.filter_by(worker_id=worker_id).first_or_404()

    if request.method == 'POST':
        password = request.form.get('password')
        access_level_id = request.form.get('access_level_id')

        if password:  # Изменяем пароль
            user_to_edit.password = password
            flash('Password updated successfully.', 'success')

        if access_level_id:  # Обновляем уровень доступа
            user_to_edit.access_level_id = access_level_id
            flash('Access level updated successfully.', 'success')

        db.session.commit()
        return redirect(url_for('user_accounts'))

    return render_template('edit_user.html', user=user_to_edit)

@app.route('/delete_user/<int:worker_id>')
@requires_access_level(['superadmin'])
def delete_user(worker_id):
    user = UserAccount.query.filter_by(worker_id=worker_id).first_or_404()
    db.session.delete(user)
    db.session.commit()
    flash('User deleted successfully.', 'success')
    return redirect(url_for('user_accounts'))

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

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        worker_login = request.form['worker_login']  # Используйте 'worker_login' вместо 'worker_id'
        password = request.form['password']
        user = UserAccount.query.filter_by(worker_login=worker_login, password=password).first()

        if user:
            login_user(user)
            next_page = request.args.get('next', url_for('admin_home'))  # Используйте общую страницу в случае успешного входа
            return redirect(next_page)
        else:
            flash('Invalid username or password.')
    return render_template('login.html')


@app.route('/logout')
def logout():
    logout_user()
    session.clear()
    flash('You have successfully logged out.', 'success')
    return redirect(url_for('login'))

@app.route('/admin/data_upload')
@requires_access_level(['admin', 'superadmin'])
def data_upload():
    return render_template('data_upload.html')

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
            # Читаем Excel-файл непосредственно из потока
            stream = BytesIO(file.read())
            df = pd.read_excel(stream)
            for index, row in df.iterrows():
                worker_login = str(row['GD Number'])  # Предполагаем, что название столбца 'GD Number'
                password = str(row['Password'])  # Предполагаем, что название столбца 'Password'
                
                # Проверяем, существует ли уже такой пользователь
                if not UserAccount.query.filter_by(worker_login=worker_login).first():
                    new_user = UserAccount(worker_login=worker_login, password=password)
                    db.session.add(new_user)
            db.session.commit()
            flash('File uploaded and processed successfully.', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'Error processing file: {e}', 'danger')
    return render_template('data_upload.html')


@app.route('/admin/data_upload/upload_working_hours', methods=['GET', 'POST'])
@requires_access_level(['admin', 'superadmin'])
def upload_working_hours():
    # Your logic for handling the file upload goes here
    if request.method == 'POST':
        file = request.files.get('file')
        if not file or file.filename == '':
            flash('No file selected', 'warning')
            return redirect(request.url)
        # Process the uploaded file
        handle_uploaded_file(file.stream)
        flash('File uploaded successfully.', 'success')
    return render_template('data_upload.html')

@app.route('/admin/data_upload/upload_process_data', methods=['POST'])
@requires_access_level(['admin', 'superadmin'])
def upload_process_data():
    file = request.files.get('file')
    if not file or file.filename == '':
        flash('No file selected', 'warning')
        return redirect(request.url)

    try:
        # Чтение Excel файла
        df = pd.read_excel(file, sheet_name=0)  # предполагается, что данные на первом листе

        for index, row in df.iterrows():
            date = pd.to_datetime(row['Data']).date()
            worker_login = row['USER LOGIN']
            scanned_items = int(row['SZTUKI'])
            time_spent = float(row['CZAS'])
            process_name = row.get('process_name')

            # Поиск process_id по имени процесса
            if process_name:
                process_type = ProcessType.query.filter_by(process_name=process_name).first()
                if not process_type:
                    flash(f'Process "{process_name}" not found.', 'warning')
                    continue  # Пропускаем запись, если процесс не найден
                process_id = process_type.process_id
            else:
                flash('Process name is missing in the row', 'warning')
                continue

            user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
            worker_id = user_account.worker_id
            if user_account:
                # Создание новой записи процесса
                new_process = Process(
                    date=date,
                    worker_id=worker_id,
                    scanned_items=scanned_items,
                    time_spent=time_spent,
                    process_id=process_id  # Используем process_id вместо process_name
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
    form = FeedbackForm()
    if form.validate_on_submit():
        feedback_worker_id = current_user.worker_login if not form.anonymous.data else 'anonymous'
        feedback = Feedback(
            worker_id=feedback_worker_id,
            feedback_text=form.content.data,
            feedback_date=datetime.now()
        )
        db.session.add(feedback)
        db.session.commit()
        flash('Ваш отзыв успешно отправлен!', 'success')
        return redirect(url_for('feedback')) if form.anonymous.data else redirect(url_for('worker_home'))
    return render_template('feedback.html', form=form)


@app.route('/feedbacks')
@requires_access_level(['admin', 'superadmin'])
def view_feedbacks():
    feedbacks = Feedback.query.order_by(Feedback.feedback_id.desc()).all()  # Сортировка по feedback_id
    return render_template('view_feedbacks.html', feedbacks=feedbacks)

@app.route('/feedbacks/<int:feedback_id>')
@requires_access_level(['admin', 'superadmin'])
def feedback_details(feedback_id):
    feedback = Feedback.query.get_or_404(feedback_id)  # Получение отзыва или возврат 404
    return render_template('feedback_details.html', feedback=feedback)


@app.route('/performance/<string:worker_login>/', methods=['GET'])
@login_required
def show_performance(worker_login):
    user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
    worker_id = user_account.worker_id
    if current_user.worker_id != worker_id:
        return "Access Denied", 403
    return render_template('performance.html', worker_id=worker_id)

@app.route('/performance/data/', methods=['GET'])
@login_required
def handle_performance_request():
    worker_id = int(request.args.get('worker_id'))
    if current_user.worker_id != worker_id:
        return jsonify({"error": "Access Denied"}), 403
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')

    # Конвертирование строковых дат в объекты datetime
    start_date_obj = datetime.strptime(start_date, '%m/%d/%Y').date()
    end_date_obj = datetime.strptime(end_date, '%m/%d/%Y').date()

    # Запрос к БД для агрегации данных по процессам, включая process_id
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

    # Преобразование результатов запроса в формат, пригодный для calculate_performance
    process_data_formatted = [
        {
            "process_id": data.process_id,  # Теперь используем process_id
            "process_name": data.process_name,  # Можем сохранить process_name для отображения
            "date": data.date,
            "scanned_items": data.scanned_items,
            "time_spent": float(data.time_spent)
        } for data in process_data
    ]

    # Получение целей для процессов за интересующий период
    targets = get_targets_for_period(start_date_obj, end_date_obj)

    # Вычисление производительности
    performance_results = calculate_performance(process_data_formatted, targets, start_date_obj, end_date_obj)

    # Подготовка и возврат ответа
    return jsonify({
        'worker_id': worker_id,
        'start_date': start_date,
        'end_date': end_date,
        'data': performance_results
    })

@app.route('/schedule/<string:worker_login>')
@login_required
def show_schedule(worker_login):
    # Получение учетной записи пользователя по логину
    user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
    worker_id = user_account.worker_id

    # Проверка, имеет ли текущий пользователь доступ к этой странице
    if current_user.worker_id != worker_id:
        return "Access Denied", 403

    # Отображение расписания
    return render_template('schedule.html', worker_id=worker_id)

@app.route('/api/schedule/<string:worker_login>')
@login_required
def get_schedule(worker_login):
    # Поиск учетной записи по логину
    user_account = UserAccount.query.filter_by(worker_login=worker_login).first_or_404()
    worker_id = user_account.worker_id

    # Проверка доступа
    if current_user.worker_id != worker_id:
        return jsonify({"error": "Access Denied"}), 403

    # Получение данных о посещаемости
    schedule_data = Attendance.query.filter_by(worker_id=worker_id).all()
    
    events = []
    for entry in schedule_data:
        if entry.day_type != 'P':
            title = entry.day_type
        else:
            start_time = entry.scheduled_start_time.strftime('%H:%M') if entry.scheduled_start_time else 'Unknown'
            end_time = entry.scheduled_end_time.strftime('%H:%M') if entry.scheduled_end_time else 'Unknown'
            title = f"{start_time}-{end_time}"

        # Создание объекта события для календаря
        event = {
            'title': title,
            'start': entry.attendance_date.strftime('%Y-%m-%d'),
            'allDay': True,
            'absenceReason': entry.absence_reason if entry.absence_reason else ''
        }
        events.append(event)
    
    return jsonify(events)

@app.route('/messages')
@login_required
def show_messages():
    if current_user.is_authenticated:
        # Получаем пользователя и обновляем время последнего доступа к сообщениям
        worker = Worker.query.filter_by(worker_id=current_user.worker_id).first()
        if worker:
            worker.last_messages_check = datetime.now()
            db.session.commit()  # Сохраняем изменения в базе данных 

    group_ids = db.session.query(UserMessageGroup.group_id).filter(UserMessageGroup.user_id == current_user.worker_id).subquery()
    
    # Запрос для сообщений групп
    group_messages_query = db.session.query(Message).join(
        MessageRecipient,
        Message.message_id == MessageRecipient.message_id
    ).filter(
        MessageRecipient.recipient_group_id.in_(group_ids)
    )

    # Запрос для личных сообщений
    personal_messages_query = db.session.query(Message).join(
        MessageRecipient,
        Message.message_id == MessageRecipient.message_id
    ).filter(
        MessageRecipient.recipient_user_id == current_user.worker_id
    )

    # Объединяем запросы с помощью union и сортируем итоговые данные
    all_messages = group_messages_query.union(personal_messages_query).order_by(Message.created_at.desc()).all()

    return render_template('messages.html', messages=all_messages)


@app.route('/message/<int:message_id>')
@login_required
def message_details(message_id):
    message = Message.query.filter_by(message_id=message_id).first_or_404()
    attachments = MessageAttachment.query.filter_by(message_id=message_id).all()  # Загружаем вложения
    return render_template('message_details.html', message=message, attachments=attachments)

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/api/new-messages-count')
def new_messages_count():
    if not current_user.is_authenticated:
        return jsonify({"error": "Unauthorized"}), 401

    current_user_id = current_user.worker_id  # Аутентифицированный пользователь

    # Получаем время последней проверки сообщений
    last_checked = Worker.query.filter_by(worker_id=current_user_id).first().last_messages_check

    # Получаем ID групп, в которых состоит пользователь
    group_ids = [group.group_id for group in UserMessageGroup.query.filter_by(user_id=current_user_id).all()]

    # Получаем все сообщения, адресованные как группам, так и текущему пользователю после last_messages_check
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

@app.route('/absence-form')
@login_required
def absence_form():
    return render_template('absence_form.html')

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
        
        # Проверяем, разрешен ли тип файла и не превышает ли он размер
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            # Загрузка файла и получение URL
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
        flash('Уведомление об отсутствии отправлено.')

    except Exception as e:
        db.session.rollback()
        flash(f'Ошибка обработки формы: {e}')

    return redirect(url_for('absence_form'))

def allowed_file(filename):
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf', 'heic'}
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def upload_to_google_drive(file):
    # Логика загрузки файла на Google Drive
    pass

@app.route('/worker/attendance', methods=['GET', 'POST'])
@login_required
def worker_attendance():
    worker_id = current_user.worker_id
    now = datetime.now()
    month = int(request.form.get('month', now.month))
    year = int(request.form.get('year', now.year))

    # Первый и последний день выбранного месяца
    first_day = datetime(year, month, 1)
    last_day = datetime(year, month, calendar.monthrange(year, month)[1])

    # Запрос к базе данных для получения данных посещаемости
    attendance_records = Attendance.query.filter(
        Attendance.worker_id == worker_id,
        Attendance.attendance_date >= first_day,
        Attendance.attendance_date <= last_day
    ).all()
    attendance_dict = {record.attendance_date: record for record in attendance_records}

    # Создание полного списка дней месяца
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

    # Подсчет суммарных значений
    total_scheduled = sum([rec['work_hours'] for rec in attendance if rec['work_hours']])
    total_actual = sum([rec['work_hours'] for rec in attendance if rec['work_hours']])

    return render_template('attendance.html', attendance=attendance, total_scheduled=total_scheduled, total_actual=total_actual, month=month, year=year)

@app.route('/send-message', methods=['GET', 'POST'])
@login_required
def send_message():
    if request.method == 'POST':
        title = request.form.get('title')
        content = request.form.get('content')
        recipient = request.form.get('recipient')
        group_id = request.form.get('group_id')
        files = request.files.getlist('files')

        new_message = Message(
            title=title,
            message_content=content,
            sender_id=current_user.worker_id,
            has_attachments=len(files) > 0
        )
        db.session.add(new_message)
        db.session.flush()

        content_to_add = ""
        for file in files:
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                file.save(filepath)
                attachment = MessageAttachment(
                    message_id=new_message.message_id,
                    file_path=filepath,
                    file_type=file.content_type
                )
                db.session.add(attachment)
                content_to_add += f'<br><a href="/uploads/{filename}">View attachment</a>'

        new_message.message_content += content_to_add
        db.session.commit()
        flash('Your message has been sent successfully!', 'success')
        return redirect(url_for('send_message'))

    groups = MessageGroupList.query.all()
    return render_template('send_message.html', groups=groups)

    
    