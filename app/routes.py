from app import app, db
from flask import request,render_template, request, redirect, session, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from app.models import UserAccount, Worker, Process, Feedback, Notification
from datetime import datetime
from app.utils import handle_uploaded_file, requires_access_level 
import pandas as pd
from io import BytesIO
from .forms import FeedbackForm, NotificationForm



@app.route('/admin/home')
@requires_access_level(['admin', 'superadmin'])
def admin_home():
    # Здесь могут быть добавлены запросы к БД для получения данных, которые нужно отобразить на странице
    return render_template('admin_home.html')

@app.route('/workers')
@requires_access_level(['admin', 'superadmin'])
def workers():
    workers = Worker.query.all()
    return render_template('workers.html', workers=workers)

@app.route('/<worker_id>')
def worker_home(worker_id):
    worker = Worker.query.filter_by(worker_id=worker_id).first_or_404()
    # Убедитесь, что в шаблоне worker_home.html используете {{ worker.fullname }} вместо {{ worker.name }}
    return render_template('worker_home.html', worker=worker)

@app.route('/user_accounts')
@requires_access_level(['admin', 'superadmin'])
def user_accounts():
    users = UserAccount.query.all()
    current_user_access_level = session.get('access_level', 'user')
    return render_template('user_accounts.html', users=users, current_user_access_level=current_user_access_level)

@app.route('/add_user', methods=['POST'])
@requires_access_level(['superadmin'])
def add_user():
    worker_id = request.form.get('worker_id')
    password = request.form.get('password')
    access_level = request.form.get('access_level')

    if UserAccount.query.filter_by(worker_id=worker_id).first():
        flash('User with this Worker ID already exists.', 'error')
        return redirect(url_for('user_accounts'))

    new_user = UserAccount(worker_id=worker_id, password=password, access_level=access_level)
    db.session.add(new_user)
    db.session.commit()
    flash('User added successfully.', 'success')
    return redirect(url_for('user_accounts'))


@app.route('/edit_user/<worker_id>', methods=['GET', 'POST'])
def edit_user(worker_id):
    current_user_id = session.get('worker_id')
    current_user = UserAccount.query.filter_by(worker_id=current_user_id).first()

    if not current_user or current_user.access_level not in ['admin', 'superadmin']:
        flash('You do not have permission to access this page.', 'danger')
        return redirect(url_for('login'))

    user_to_edit = UserAccount.query.filter_by(worker_id=worker_id).first_or_404()

    if request.method == 'POST':
        password = request.form.get('password')
        access_level = request.form.get('access_level')

        if password and current_user.access_level == 'superadmin': # Изменяем пароль
            user_to_edit.password = password
            flash('Password updated successfully.', 'success')

        if access_level: # Обновляем уровень доступа
            user_to_edit.access_level = access_level
            flash('Access level updated successfully.', 'success')

        db.session.commit()
        return redirect(url_for('user_accounts'))

    return render_template('edit_user.html', user=user_to_edit, current_user_access_level=current_user.access_level)

@app.route('/delete_user/<worker_id>')
@requires_access_level(['superadmin'])
def delete_user(worker_id):
    user = UserAccount.query.filter_by(worker_id=worker_id).first_or_404()
    db.session.delete(user)
    db.session.commit()
    flash('User deleted successfully.', 'success')
    return redirect(url_for('user_accounts'))

@app.route('/reset_password/<worker_id>', methods=['POST'])
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
        worker_id = request.form.get('worker_id')
        password = request.form.get('password')

        user = UserAccount.query.filter_by(worker_id=worker_id).first()

        if user and user.password == password: # Прямое сравнение пароля
            session['worker_id'] = user.worker_id
            session['access_level'] = user.access_level
            session['is_logged_in'] = True

            # Обновляем статус входа пользователя в систему
            user.is_logged_in = True
            db.session.commit()

            # Перенаправление в зависимости от уровня доступа пользователя
            if user.access_level in ['admin', 'superadmin']:
                return redirect(url_for('admin_home'))
            else:
                return redirect(url_for('worker_home', worker_id=user.worker_id))
        else:
            flash('Invalid login credentials.', 'danger')
    return render_template('login.html')

@app.route('/logout')
def logout():
    user = UserAccount.query.filter_by(worker_id=session.get('worker_id')).first()
    if user:
        user.is_logged_in = False
        db.session.commit()
        
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
                worker_id = str(row['GD Number'])  # Предполагаем, что название столбца 'GD Number'
                password = str(row['Password'])  # Предполагаем, что название столбца 'Password'
                
                # Проверяем, существует ли уже такой пользователь
                if not UserAccount.query.filter_by(worker_id=worker_id).first():
                    new_user = UserAccount(worker_id=worker_id, password=password)
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
            worker_id = row['USER LOGIN']
            scanned_items = int(row['SZTUKI'])
            time_spent = float(row['CZAS'])
            process_name = row['process_name'] if 'process_name' in row and not pd.isna(row['process_name']) else None

            # Проверка существования worker_id
            worker = Worker.query.filter_by(worker_id=worker_id).first()
            if worker:
                # Создание новой записи процесса
                new_process = Process(
                    date=date,
                    worker_id=worker_id,
                    scanned_items=scanned_items,
                    time_spent=time_spent,
                    process_name=process_name
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

@app.route('/<worker_id>/feedback/', methods=['GET', 'POST'])
def feedback(worker_id):
    form = FeedbackForm()
    feedback_worker_id = worker_id  # Объявляем переменную здесь
    if form.validate_on_submit():
        if form.anonymous.data:
            feedback_worker_id = 'anonymous'  # Изменяем значение, если необходимо
        feedback = Feedback(worker_id=feedback_worker_id,
                            feedback_text=form.content.data,
                            feedback_date=datetime.now())
        db.session.add(feedback)
        db.session.commit()
        flash('Ваш отзыв успешно отправлен!', 'success')
        # Если feedback_worker_id равен 'anonymous', оставляем пользователя на текущей странице
        return redirect(url_for('feedback', worker_id=worker_id)) if feedback_worker_id == 'anonymous' else redirect(url_for('worker_home', worker_id=worker_id))
    return render_template('feedback.html', form=form, worker_id=worker_id)


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

@app.route('/send_notification', methods=['GET', 'POST'])
@requires_access_level(['admin', 'superadmin'])
def send_notification():
    form = NotificationForm()
    if form.validate_on_submit():
        sender_id = session.get('worker_id')
        new_notification = Notification(
            send_date=datetime.now(),
            message=form.message.data,
            recipient_id=form.recipient_id.data,
            notification_tags=form.notification_tags.data,
            flash_type=form.flash_type.data,
            sender_id=sender_id # Пример получения ID отправителя
        )
        db.session.add(new_notification)
        db.session.commit()
        flash('Уведомление отправлено!', 'success')
        return redirect(url_for('send_notification'))
    return render_template('send_notification.html', form=form)

@app.route('/view_notifications')
@requires_access_level(['admin', 'superadmin'])
def view_notifications():
    notifications = Notification.query.order_by(Notification.send_date.desc()).all()
    return render_template('view_notifications.html', notifications=notifications)