from collections import defaultdict
from flask import redirect, url_for, flash
from functools import wraps
from flask_login import current_user
from sqlalchemy import func
from .models import ProcessTarget, UserAccessLevel, UserAccount, Worker, Attendance , Firm, WorkerGroupName, WorkerGroupNumber, WorkerTransportType, db
import pandas as pd
from datetime import timedelta
from io import BytesIO
import psycopg2

# Decorator to check access levels
def requires_access_level(access_levels):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                flash('You need to be signed in to access this page.', 'danger')
                return redirect(url_for('login'))

            access_level_obj = UserAccessLevel.query.join(UserAccount).filter(UserAccount.worker_id == current_user.worker_id).first()
            if not access_level_obj or access_level_obj.access_level_name not in access_levels:
                flash('You do not have permission to access this page.', 'danger')
                if current_user.access_level.access_level_name == 'admin' or current_user.access_level.access_level_name == 'superadmin':
                    return redirect(url_for('admin_home'))
                else:
                    return redirect(url_for('worker_home', worker_login=current_user.worker_login))

            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Function to get or create a firm
def get_or_create_firm(firma_name):
    if firma_name is None or firma_name == '':
        firma_name = 'LPP'
    firma_name_lower = firma_name.lower()

    firm = Firm.query.filter(Firm.name.ilike(firma_name_lower)).first()
    if not firm:
        firm = Firm(name=firma_name)
        db.session.add(firm)
        db.session.commit()
    return firm.firm_id

# Function to parse labels
def parse_labels(label_str):
    transport_id = None
    group_name_id = None
    group_number_id = None

    label_str = label_str.lower()
    transports = WorkerTransportType.query.all()
    group_names = WorkerGroupName.query.all()
    group_numbers = WorkerGroupNumber.query.all()

    for transport in transports:
        if transport.name.lower() in label_str:
            transport_id = transport.transport_id
            break

    for group_name in group_names:
        group_name_lower = group_name.name.lower()
        if group_name_lower in label_str:
            start_index = label_str.find(group_name_lower) + len(group_name_lower)
            if start_index < len(label_str) and label_str[start_index] == ' ':
                possible_number = label_str[start_index+1:].split(',')[0].strip()
                for group_number in group_numbers:
                    if group_number.number.lower() == possible_number:
                        group_name_id = group_name.group_name_id
                        group_number_id = group_number.group_number_id
                        break
                if group_number_id:
                    break

    return transport_id, group_name_id, group_number_id

# Function to calculate duration in hours
def time_to_hours(start_timestamp, end_timestamp):
    duration = end_timestamp - start_timestamp
    duration_in_hours = duration.total_seconds() / 3600
    return duration_in_hours

# Function to handle uploaded file
def handle_uploaded_file(file_stream):
    try:
        df = pd.read_excel(file_stream, sheet_name='Dane szczególowe', header=1)
        df.columns = [
            'Pracownik', 'Numer', 'Dzień tygodnia', 'Data', 'Plan Rozpoczecie pracy',
            'Plan Zakonczenie pracy', 'Plan Czas pracy', 'Typ dnia', 'Netto Rozpoczecie pracy',
            'Netto Zakonczenie pracy', 'Neto Czas pracy', 'Wykonanie Rozpoczecie pracy',
            'Wykonanie Zakonczenie pracy', 'Pobyt', 'Wykonanie Czas pracy', 'Przerwy',
            'Bilans', 'Zaliczona', 'Dopelnienie', 'Nadg.dob. 50%', 'Nadg.dob. 100%',
            'Średniotygodniowe 100%', 'Niedoczas', 'Nocne', 'Nieobecnosc', 'Status okresu.rozl.',
            'Pracodawca', 'Lokalizacja', 'Dział', 'Stanowisko','Etykiety'
        ]

        for index, row in df.iterrows():
            worker_login = str(row['Numer'])
            fullname = row['Pracownik']
            firma_name = row['Pracodawca']
            firm_id = get_or_create_firm(firma_name)

            transport_id, group_name_id, group_number_id = parse_labels(row['Etykiety'])
            user_account = UserAccount.query.filter_by(worker_login=worker_login).first()

            if user_account:
                worker = Worker.query.filter_by(worker_id=user_account.worker_id).first()
                if not worker:
                    new_worker = Worker(
                        worker_id=user_account.worker_id,
                        fullname=fullname,
                        transport_id=transport_id,
                        group_name_id=group_name_id,
                        group_number_id=group_number_id,
                        firm_id=firm_id,
                    )
                    db.session.add(new_worker)
                    flash(f'New worker {worker_login} added to the database.', 'success')
                else:
                    worker.fullname = fullname
                    worker.transport_id = transport_id
                    worker.group_name_id = group_name_id
                    worker.group_number_id = group_number_id
                    worker.firm_id = firm_id
                    flash(f'Updated worker data for {worker_login}.', 'success')
                handle_attendance_data(user_account.worker_id, row)
            else:
                flash(f'No user account found for {worker_login}.', 'warning')
        db.session.commit()
        flash('Data uploaded successfully.', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Error processing file: {e}', 'danger')

# Function to handle attendance data
def handle_attendance_data(worker_id, row):
    attendance_date = row['Data']
    plan_start_time = row['Plan Rozpoczecie pracy'] if not pd.isna(row['Plan Rozpoczecie pracy']) else None
    plan_end_time = row['Plan Zakonczenie pracy'] if not pd.isna(row['Plan Zakonczenie pracy']) else None
    scheduled_work_hours = time_to_hours(plan_start_time, plan_end_time) if not pd.isna(row['Plan Rozpoczecie pracy']) and not pd.isna(row['Plan Zakonczenie pracy']) else None
    actual_start_time = row['Wykonanie Rozpoczecie pracy'] if not pd.isna(row['Wykonanie Rozpoczecie pracy']) else None
    actual_end_time = row['Wykonanie Zakonczenie pracy'] if not pd.isna(row['Wykonanie Zakonczenie pracy']) else None
    actual_work_time = time_to_hours(actual_start_time, actual_end_time) if not pd.isna(row['Wykonanie Rozpoczecie pracy']) and not pd.isna(row['Wykonanie Zakonczenie pracy']) else None
    break_time = row['Przerwy'] if not pd.isna(row['Przerwy']) else None
    day_type = row['Typ dnia'] if not pd.isna(row['Typ dnia']) else None

    existing_attendance = Attendance.query.filter_by(worker_id=worker_id, attendance_date=attendance_date).first()
    if existing_attendance:
        update_existing_attendance(existing_attendance, day_type, plan_start_time, plan_end_time, scheduled_work_hours, actual_work_time, break_time, row)
    else:
        add_new_attendance(worker_id, attendance_date, day_type, plan_start_time, plan_end_time, scheduled_work_hours, actual_work_time, break_time, row)

# Function to update existing attendance data
def update_existing_attendance(attendance, day_type, start_time, end_time, scheduled_hours, actual_hours, break_time, row):
    attendance.day_type = day_type
    attendance.scheduled_start_time = start_time
    attendance.scheduled_end_time = end_time
    attendance.scheduled_work_hours = scheduled_hours
    attendance.actual_work_hours = actual_hours
    attendance.break_time = break_time
    attendance.absence_reason = row['Nieobecnosc'] if not pd.isna(row['Nieobecnosc']) else None
    db.session.commit()
    flash('Attendance record updated.', 'success')

# Function to add new attendance data
def add_new_attendance(worker_id, date, day_type, start_time, end_time, scheduled_hours, actual_hours, break_time, row):
    new_attendance = Attendance(
        worker_id=worker_id,
        attendance_date=date,
        day_type=day_type,
        scheduled_start_time=start_time,
        scheduled_end_time=end_time,
        scheduled_work_hours=scheduled_hours,
        actual_work_hours=actual_hours,
        break_time=break_time,
        absence_reason=row['Nieobecnosc'] if not pd.isna(row['Nieobecnosc']) else None
    )
    db.session.add(new_attendance)
    db.session.commit()
    flash('New attendance record added.', 'success')

# Function to get process targets for a period
def get_targets_for_period(start_date, end_date):
    subquery = ProcessTarget.query \
        .filter(ProcessTarget.target_date < start_date) \
        .with_entities(
            ProcessTarget.process_id,
            func.max(ProcessTarget.target_date).label('last_target_date')
        ) \
        .group_by(ProcessTarget.process_id) \
        .subquery()

    last_targets = ProcessTarget.query \
        .join(subquery, (ProcessTarget.process_id == subquery.c.process_id) & 
              (ProcessTarget.target_date == subquery.c.last_target_date)) \
        .all()

    targets_within_period = ProcessTarget.query \
        .filter(
            ProcessTarget.target_date >= start_date,
            ProcessTarget.target_date <= end_date
        ) \
        .all()

    all_targets = targets_within_period + last_targets

    targets_data = [{
        "process_id": target.process_id,
        "target_date": target.target_date,
        "target_items_per_hour": target.target_items_per_hour
    } for target in all_targets]

    targets_data.sort(key=lambda x: (x['process_id'], x['target_date']))

    return targets_data

# Function to calculate performance
def calculate_performance(process_data, targets, start_date, end_date):
    process_data_grouped = defaultdict(list)
    for item in process_data:
        if start_date <= item["date"] <= end_date:
            process_data_grouped[item["process_id"]].append(item)
    
    performance_results = []
    for process_id, data in process_data_grouped.items():
        total_items = total_time = 0
        weighted_performance = 0
        
        relevant_targets = [target for target in targets if target["process_id"] == process_id]
        periods = [start_date] + [target["target_date"] for target in relevant_targets if start_date < target["target_date"] <= end_date] + [end_date + timedelta(days=1)]
        
        for start, end in zip(periods[:-1], periods[1:]):
            current_target = next((target["target_items_per_hour"] for target in reversed(relevant_targets) if target["target_date"] < end), None)
            if not current_target:
                continue
            
            interval_data = [d for d in data if start <= d["date"] < end]
            interval_items = sum(d["scanned_items"] for d in interval_data)
            interval_time = sum(d["time_spent"] for d in interval_data)
            
            if interval_time > 0:
                items_per_hour = interval_items / interval_time
                performance_percent = (items_per_hour / current_target) * 100
                weighted_performance += performance_percent * interval_time
            
            total_items += interval_items
            total_time += interval_time
        
        process_name = next((item["process_name"] for item in process_data if item["process_id"] == process_id), "Unknown Process")

        avg_performance = weighted_performance / total_time if total_time else 0
        overall_items_per_hour = total_items / total_time if total_time else 0
        
        performance_results.append({
            "process_id": process_id,
            "process_name": process_name,
            "items_per_hour": overall_items_per_hour,
            "overall_performance": avg_performance,
            "total_scanned_items": total_items,
            "total_time_spent": total_time
        })
    
    return performance_results

# Function to check if file type is allowed
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg', 'gif'}

# Function to upload file to Google Drive
def upload_to_google_drive(file):
    pass
