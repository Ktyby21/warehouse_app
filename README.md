# Warehouse Management System

![Flask](https://img.shields.io/badge/Flask-1.1.2-blue)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-1.3.23-blue)
![Python](https://img.shields.io/badge/Python-3.8+-blue)
![MIT License](https://img.shields.io/badge/license-MIT-green)

Welcome to the Warehouse Management System! This is my first major project, built to help manage employees' data, work schedules, performance evaluations, and communications within a company. I've included features like user authentication, feedback management, and data uploads.

## Features

- User login and logout functionality.
- Different access levels for users (User, Administrator, Super Administrator).
- User Management:
  - Add, edit, and delete users.
  - Super Administrators can assign access levels.
- Employee Data Management:
  - View detailed information about employees.
  - Manage employee details like work schedules, languages, companies, groups, and transport.
- Feedback and Complaints:
  - Employees can submit feedback and complaints.
  - Admins can view and manage feedback.
- Messaging and Notifications:
  - Send and receive messages between users.
  - View notifications and new message counts.
- Performance and Scheduling:
  - View performance evaluations for employees.
  - Display employee schedules in a calendar format.
- Data Upload and Processing:
  - Upload files with user data, working hours, and process data.
  - Process and store uploaded data.

## Getting Started

### Prerequisites

- Python 3.8+
- PostgreSQL

### Installation

1. **Clone the repository**:

    ```sh
    git clone https://github.com/Ktyby21/warehouse_app.git
    cd warehouse_app
    ```

2. **Create a virtual environment and activate it**:

    ```sh
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

3. **Install the required dependencies**:

    ```sh
    pip install -r requirements.txt
    ```

4. **Set up the environment variables**:

    Create a file named `.env` in the root directory of the project with the following content:

    ```plaintext
    DATABASE_URL=postgresql://yourusername:yourpassword@localhost/yourdatabase
    SECRET_KEY=your_secret_key
    ```

    Replace `yourusername`, `yourpassword`, `yourdatabase`, and `your_secret_key` with your own values.

5. **Create a PostgreSQL user and database**:

    Open PostgreSQL command-line tool:

    ```sh
    psql -U postgres
    ```

    Then run the following commands to create a user and database:

    ```sql
    CREATE USER yourusername WITH PASSWORD 'yourpassword';
    CREATE DATABASE yourdatabase OWNER yourusername;
    ```

6. **Set up the database**:

    - **Initialize the Flask database**:

      ```sh
      flask db init
      flask db migrate -m "Initial migration."
      flask db upgrade
      ```

    - **Import the PostgreSQL database backup (if required)**:

      ```sh
      psql -U yourusername -d yourdatabase -f database_backup.sql
      ```

7. **Add access levels and create users**:

    Open PostgreSQL command-line tool:

    ```sh
    psql -U yourusername -d yourdatabase
    ```

    Run the following SQL commands to add access levels and create users:

    ```sql
    INSERT INTO user_access_levels (access_level_name) VALUES ('user'), ('admin'), ('superadmin');

    INSERT INTO users (worker_login, password, access_level_id, is_logged_in) VALUES
    ('user1', '1', (SELECT access_level_id FROM user_access_levels WHERE access_level_name = 'user'), FALSE),
    ('admin1', '1', (SELECT access_level_id FROM user_access_levels WHERE access_level_name = 'admin'), FALSE),
    ('superadmin', '1', (SELECT access_level_id FROM user_access_levels WHERE access_level_name = 'superadmin'), FALSE);
    ```
3 users and passwords
login 'user1' - password '1'
login 'admin1' - password '1'
login 'superadmin1' - password '1'

### Running the Application

1. **Run the application**:

    ```sh
    flask run
    ```

2. **Open your browser and go to**:

    ```
    http://127.0.0.1:5000/
    ```

## Directory Structure

```plaintext
├── app
│   ├── __init__.py
│   ├── models.py
│   ├── routes.py
│   └── utils.py
├── database_backup.sql
├── run.py
├── requirements.txt
├── migrations
│   ├── alembic.ini
│   ├── env.py
│   ├── README
│   ├── script.py.mako
│   └── versions
│       └── <migration_files>.py
├── static
│   ├── css
│   │   └── styles.css
│   ├── images
│   ├── js
│   │   └── scripts.js
│   └── uploads
└── templates
    ├── absence_form.html
    ├── admin_home.html
    ├── attendance.html
    ├── data_upload.html
    ├── edit_user.html
    ├── feedback.html
    ├── feedback_details.html
    ├── login.html
    ├── message_details.html
    ├── messages.html
    ├── performance.html
    ├── schedule.html
    ├── send_message.html
    ├── send_notification.html
    ├── user_accounts.html
    ├── view_feedbacks.html
    ├── view_notifications.html
    ├── worker_home.html
    └── workers.html
```
## About This Project
Hi! I'm a self-taught developer, and this is my first major programming project. I created this application to learn and practice web development with Flask. Through this project, I've learned a lot about user authentication, database management, and creating dynamic web pages.
