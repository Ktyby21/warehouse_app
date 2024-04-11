from collections import defaultdict
from flask import session, redirect, url_for, flash, request
from functools import wraps

import psycopg2
from sqlalchemy import func
from .models import ProcessTarget, ProcessType, UserAccount, Worker, Attendance , Firm, Process, db
from io import BytesIO
import pandas as pd
from datetime import datetime, time, timedelta

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

def get_or_create_firm(firma_name):
    # Приводим имя фирмы к нижнему регистру только для поиска
    if firma_name is None or firma_name == '':
        firma_name = 'LPP'  # Устанавливаем 'LPP' как значение по умолчанию
    firma_name_lower = firma_name.lower()

    # Используем функцию lower() SQL для сравнения в нижнем регистре, сохраняя исходный регистр имени для добавления
    firm = Firm.query.filter(Firm.name.ilike(firma_name_lower)).first()
    if not firm:
        # Если фирма не найдена, добавляем новую с сохранением исходного регистра имени
        firm = Firm(name=firma_name)  # Сохраняем имя как в исходном виде
        db.session.add(firm)
        db.session.commit()
    return firm.firm_id

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
            firma_name = row['Pracodawca']
            firm_id = get_or_create_firm(firma_name)
            hala, transport, nationality, group_number, group_name = parse_labels(row['Etykiety'])
            user_account_exists = UserAccount.query.filter_by(worker_id=worker_id).first() is not None
            worker = Worker.query.filter_by(worker_id=worker_id).first()
            if user_account_exists:
                if not worker:
                    new_worker = Worker(
                    worker_id=worker_id,
                    fullname=fullname,
                    group_name=group_name,
                    group_number=group_number,
                    transport=transport,
                    firm_id=firm_id,
                    # И другие поля, которые вы хотите инициализировать
                    )
                    db.session.add(new_worker)
                    db.session.commit()
                    flash(f'New worker {worker_id} added to the database.', 'success')
                else:
                    if worker.fullname != fullname or worker.group_name != group_name or worker.group_number != group_number or worker.transport != transport or worker.firm_id != firm_id:
                        worker.fullname = fullname
                        worker.group_name = group_name
                        worker.group_number = group_number
                        worker.transport = transport
                        worker.firm_id = firm_id
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
                # Skip this worker_id because it's not found in UserAccount
                continue    
    except Exception as e:
        db.session.rollback()
        flash(f'Error processing file: {e}', 'danger')

def get_targets_for_period(start_date, end_date):
    # Получение последних целей для всех процессов перед началом периода одним запросом
    subquery = ProcessTarget.query \
        .filter(ProcessTarget.target_date < start_date) \
        .with_entities(
            ProcessTarget.process_id,
            func.max(ProcessTarget.target_date).label('last_target_date')
        ) \
        .group_by(ProcessTarget.process_id) \
        .subquery()

    # Соединяем подзапрос с таблицей целей для получения детальной информации о последних целях
    last_targets = ProcessTarget.query \
        .join(subquery, (ProcessTarget.process_id == subquery.c.process_id) & 
              (ProcessTarget.target_date == subquery.c.last_target_date)) \
        .all()

    # Получение целевых показателей из БД для заданного периода
    targets_within_period = ProcessTarget.query \
        .filter(
            ProcessTarget.target_date >= start_date,
            ProcessTarget.target_date <= end_date
        ) \
        .all()

    # Объединение целей внутри периода с последними целями до начала периода
    all_targets = targets_within_period + last_targets

    # Преобразование результатов в список словарей
    targets_data = [{
        "process_id": target.process_id,
        "target_date": target.target_date,
        "target_items_per_hour": target.target_items_per_hour
    } for target in all_targets]

    # Сортировка результатов по дате и ID процесса
    targets_data.sort(key=lambda x: (x['process_id'], x['target_date']))

    return targets_data


def calculate_performance(process_data, targets, start_date, end_date):
    # Группировка данных о процессах по ID процесса
    process_data_grouped = defaultdict(list)
    for item in process_data:
        if start_date <= item["date"] <= end_date:
            process_data_grouped[item["process_id"]].append(item)
    
    performance_results = []
    for process_id, data in process_data_grouped.items():
        total_items = total_time = 0
        weighted_performance = 0
        
        # Определение интервалов с различными целями для данного process_id
        relevant_targets = [target for target in targets if target["process_id"] == process_id]
        periods = [start_date] + [target["target_date"] for target in relevant_targets if start_date < target["target_date"] <= end_date] + [end_date + timedelta(days=1)]
        
        for start, end in zip(periods[:-1], periods[1:]):
            # Находим цель для текущего интервала
            current_target = next((target["target_items_per_hour"] for target in reversed(relevant_targets) if target["target_date"] < end), None)
            if not current_target:
                continue
            
            # Фильтрация данных по текущему интервалу
            interval_data = [d for d in data if start <= d["date"] < end]
            interval_items = sum(d["scanned_items"] for d in interval_data)
            interval_time = sum(d["time_spent"] for d in interval_data)
            
            if interval_time > 0:
                items_per_hour = interval_items / interval_time
                performance_percent = (items_per_hour / current_target) * 100
                weighted_performance += performance_percent * interval_time
            
            total_items += interval_items
            total_time += interval_time
        
        # Идентификация имени процесса для включения в результаты
        process_name = next((item["process_name"] for item in process_data if item["process_id"] == process_id), "Unknown Process")

        # Расчёт итоговой производительности
        avg_performance = weighted_performance / total_time if total_time else 0
        overall_items_per_hour = total_items / total_time if total_time else 0
        
        performance_results.append({
            "process_id": process_id,
            "process_name": process_name,  # Включаем имя процесса для удобства
            "items_per_hour": overall_items_per_hour,
            "overall_performance": avg_performance,
            "total_scanned_items": total_items,
            "total_time_spent": total_time
        })
    
    return performance_results