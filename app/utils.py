from flask import session, redirect, url_for, flash, request
from functools import wraps
from .models import UserAccount, Worker, Attendance ,db
from io import BytesIO
import pandas as pd
from datetime import datetime, time

def requires_access_level(levels):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'worker_id' not in session:
                flash('You need to be signed in to access this page.', 'danger')
                return redirect(url_for('login'))
            
            user = UserAccount.query.filter_by(worker_id=session['worker_id']).first()
            if user.access_level not in levels:
                flash('You do not have permission to access this page.', 'danger')
                return redirect(url_for('index'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def parse_labels(label_str):
    hala = None
    transport = None
    nationality = None
    group_number = None
    group_name = None

    # Приводим всю строку к нижнему регистру для упрощения сравнений
    labels = label_str.lower().split(',')
    
    for label in labels:
        label = label.strip()
        if label in ["hala a", "hala b"]:
            hala = label.title()
        elif label in ["pruszcz azaliowa", "pruszcz żabka", "rotmanka lidl"]:
            transport = label.title()
        elif label in ["polska", "ukraina", "rosja"]:  # Продолжите список по необходимости
            nationality = label.capitalize()
        else:
            # Обрабатываем возможные варианты групп
            if label.endswith("indywidualny"):
                group_number = "Indywidualny"
                group_name = label.rsplit(' ', 1)[0] if label.endswith("indywidualny") and len(label.rsplit(' ', 1)) > 1 else None
            elif any(label.startswith(str(i) + " ") for i in range(1, 16)) or label.startswith("a "):
                parts = label.split(' ', 1)
                group_number = parts[0].capitalize()  # "A" оставляем как есть, числа в верхнем регистре не изменятся
                if len(parts) > 1:
                    group_name = parts[1].capitalize()
                else:
                    group_name = None
            # Этот блок можно расширить, если есть другие специфические случаи для обработки

    # Возвращаем значения, при необходимости приводя некоторые из них к более читаемому виду
    return (hala.title() if hala else None, 
            transport.title() if transport else None, 
            nationality.capitalize() if nationality else None, 
            group_number.capitalize() if group_number else None, 
            group_name.capitalize() if group_name else None)

def time_to_hours(start_timestamp, end_timestamp):

    duration = end_timestamp - start_timestamp

    # Конвертация разницы в часы
    duration_in_hours = duration.total_seconds() / 3600
    return duration_in_hours


def handle_uploaded_file(file_stream):
    try:
        df = pd.read_excel(file_stream, sheet_name='Dane szczególowe', header=1)
        
        new_column_names = [
            'Pracownik', 'Numer', 'Dzień tygodnia', 'Data', 'Plan Rozpoczecie pracy',
            'Plan Zakonczenie pracy', 'Plan Czas pracy', 'Typ dnia', 'Netto Rozpoczecie pracy',
            'Netto Zakonczenie pracy', 'Neto Czas pracy', 'Wykonanie Rozpoczecie pracy',
            'Wykonanie Zakonczenie pracy', 'Pobyt', 'Wykonanie Czas pracy', 'Przerwy',
            'Bilans', 'Zaliczona', 'Dopelnienie', 'Nadg.dob. 50%', 'Nadg.dob. 100%',
            'Średniotygodniowe 100%', 'Niedoczas', 'Nocne', 'Nieobecnosc', 'Status okresu.rozl.',
            'Pracodawca', 'Lokalizacja', 'Dział', 'Stanowisko','Etykiety'
        ]

        df.columns = new_column_names

        for index, row in df.iterrows():
            worker_id = str(row['Numer'])
            fullname = row['Pracownik']
            firma = row['Pracodawca']
            hala, transport, nationality, group_number, group_name = parse_labels(row['Etykiety'])
            user_account_exists = UserAccount.query.filter_by(worker_id=worker_id).first() is not None
            worker = Worker.query.filter_by(worker_id=worker_id).first()
            if user_account_exists:
                if worker:
                    if worker.fullname != fullname or worker.group_name != group_name or worker.group_number != group_number or worker.transport != transport:
                        worker.fullname = fullname
                        worker.group_name = group_name
                        worker.group_number = group_number
                        worker.transport = transport
                        worker.nationality = nationality
                        worker.firma = firma
                        db.session.commit()
                        flash(f'Updated worker data for {worker_id}.', 'success')
                    
                    attendance_date = row['Data']
                    plan_start_time = row['Plan Rozpoczecie pracy'] if not pd.isna(row['Plan Rozpoczecie pracy']) else None
                    plan_end_time = row['Plan Zakonczenie pracy'] if not pd.isna(row['Plan Zakonczenie pracy']) else None
                    scheduled_work_hours = time_to_hours(plan_start_time, plan_end_time) if not pd.isna(row['Plan Rozpoczecie pracy']) and not pd.isna(row['Plan Zakonczenie pracy']) else None
                    actual_start_time=row['Wykonanie Rozpoczecie pracy'] if not pd.isna(row['Wykonanie Rozpoczecie pracy']) else None
                    actual_end_time=row['Wykonanie Zakonczenie pracy'] if not pd.isna(row['Wykonanie Zakonczenie pracy']) else None
                    actual_work_time = time_to_hours(actual_start_time, actual_end_time) if not pd.isna(row['Wykonanie Rozpoczecie pracy']) and not pd.isna(row['Wykonanie Zakonczenie pracy']) else None
                    day_type = row['Typ dnia'] if not pd.isna(row['Typ dnia']) else None
                    existing_attendance = Attendance.query.filter_by(worker_id=worker_id, attendance_date=attendance_date).first()
                    if existing_attendance:
                        # Обновление существующей записи данными из файла
                        existing_attendance.day_type = day_type
                        existing_attendance.scheduled_start_time = plan_start_time
                        existing_attendance.scheduled_end_time = plan_end_time
                        existing_attendance.scheduled_work_hours = scheduled_work_hours
                        existing_attendance.actual_work_hours = actual_work_time
                        existing_attendance.actual_work_hours = actual_work_time
                        existing_attendance.absence_reason = row ['Nieobecnosc'] if not pd.isna(row['Nieobecnosc']) else None,
                        existing_attendance.break_time = row['Przerwy'] if not pd.isna(row['Przerwy']) else None
                        # Продолжение обновления других полей...
                        db.session.commit()
                        flash(f'Record for {worker_id} on {attendance_date} updated.', 'success')
                    else:
                        attendance = Attendance(worker_id=worker_id, attendance_date=attendance_date,
                                                scheduled_start_time=plan_start_time,
                                                scheduled_end_time=plan_end_time,
                                                scheduled_work_hours=scheduled_work_hours,
                                                actual_work_hours=actual_work_time,
                                                day_type=day_type,
                                                absence_reason=row['Nieobecnosc'] if not pd.isna(row['Nieobecnosc']) else None,
                                                break_time = row['Przerwy'] if not pd.isna(row['Przerwy']) else None)
                        db.session.add(attendance)
                        db.session.commit()
                        flash(f'Added attendance data for {worker_id} on {attendance_date}.', 'success')
                else:
                    new_worker = Worker(
                    worker_id=worker_id,
                    fullname=fullname,
                    # Дополнительно можно добавить другие поля, если они доступны
                    # например, group_name, group_number, transport, если их можно извлечь из файла
                    group_name=group_name,
                    group_number=group_number,
                    transport=transport,
                    firma = firma,
                    nationality = nationality
                    # И другие поля, которые вы хотите инициализировать
                    )
                    db.session.add(new_worker)
                    db.session.commit()
                    flash(f'New worker {worker_id} added to the database.', 'success')
            else:
                # Skip this worker_id because it's not found in UserAccount
                continue    
    except Exception as e:
        db.session.rollback()
        flash(f'Error processing file: {e}', 'danger')
