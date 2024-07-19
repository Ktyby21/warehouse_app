// Check and execute scripts for the Performance Evaluation page
if (document.getElementById('performanceForm')) {
    $(function() {
        $("#start_date, #end_date").datepicker({
            firstDay: 1
        });
        $("#dateShortcuts").change(setDateRange);
        fetchPerformance();
    });

    function setDateRange() {
        var today = new Date();
        var start, end;

        switch ($("#dateShortcuts").val()) {
            case "today":
                start = end = today;
                break;
            case "yesterday":
                start = new Date(today);
                end = new Date(today);
                start.setDate(today.getDate() - 1);
                break;
            case "thisWeek":
                var first = today.getDate() - today.getDay() + 1;
                var last = first + 6;
                start = new Date(today.setDate(first));
                end = new Date(today.setDate(last));
                break;
            case "thisMonth":
                start = new Date(today.getFullYear(), today.getMonth(), 1);
                end = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                break;
        }

        $("#start_date").datepicker("setDate", start);
        $("#end_date").datepicker("setDate", end);
        fetchPerformance();
    }

    function fetchPerformance() {
        var workerId = $("#worker_id").val();
        var startDate = $("#start_date").val() || "01/01/1970";
        var endDate = $("#end_date").val() || "12/31/2099";

        $.ajax({
            url: '/performance/data/',
            type: 'GET',
            data: {
                'worker_id': workerId,
                'start_date': startDate,
                'end_date': endDate
            },
            success: function(response) {
                updateTable(response.data);
            },
            error: function(xhr, status, error) {
                console.error("Error fetching data: " + error);
            }
        });
    }

    function updateTable(data) {
        const tableBody = document.getElementById('performanceTable').getElementsByTagName('tbody')[0];
        tableBody.innerHTML = '';
        let totalWeightedPerformance = 0;
        let totalHours = 0;
        data.forEach(item => {
            let row = `<tr>
                        <td>${item.process_name}</td>
                        <td>${item.total_scanned_items}</td>
                        <td>${parseFloat(item.total_time_spent).toFixed(2)}</td>
                        <td>${parseFloat(item.items_per_hour).toFixed(2)}</td>
                        <td>${parseFloat(item.overall_performance).toFixed(2)}%</td>
                    </tr>`;
            tableBody.innerHTML += row;
            totalWeightedPerformance += (parseFloat(item.overall_performance) * parseFloat(item.total_time_spent));
            totalHours += parseFloat(item.total_time_spent);
        });

        let totalPerformance = totalHours > 0 ? totalWeightedPerformance / totalHours : 0;
        document.getElementById('totalPerformance').innerHTML = `<h3>Total Weighted Performance: ${totalPerformance.toFixed(2)}%</h3>`;
    }
}

// Check and execute scripts for the Employee Schedule page
if (document.getElementById('calendar-body')) {
    const calendarBody = document.getElementById('calendar-body');
    const currentMonth = document.getElementById('currentMonth');
    const workerLogin = document.getElementById('worker_login').value;
    let date = new Date();
    let blankDays;

    function prevMonth() {
        date.setMonth(date.getMonth() - 1);
        renderCalendar();
    }

    function nextMonth() {
        date.setMonth(date.getMonth() + 1);
        renderCalendar();
    }

    function renderCalendar() {
        calendarBody.innerHTML = '';
        const month = date.getMonth();
        const year = date.getFullYear();
        const firstDay = (new Date(year, month, 1).getDay() + 6) % 7; // Monday - 0
        const lastDate = new Date(year, month + 1, 0).getDate();
        blankDays = firstDay;

        currentMonth.textContent = date.toLocaleDateString('en-GB', { month: 'long', year: 'numeric' });

        let row = document.createElement('tr');

        for (let i = 0; i < blankDays; i++) {
            const cell = document.createElement('td');
            row.appendChild(cell);
        }

        for (let i = 1; i <= lastDate; i++) {
            if ((blankDays + i - 1) % 7 === 0 && row.children.length > 0) {
                calendarBody.appendChild(row);
                row = document.createElement('tr');
            }
            const cell = document.createElement('td');
            const header = document.createElement('div');
            header.classList.add('day-header');
            header.textContent = i;
            cell.appendChild(header);
            row.appendChild(cell);
        }

        if (row.children.length > 0) {
            calendarBody.appendChild(row);
        }

        fetchSchedule(workerLogin, year, month + 1);
    }

    function fetchSchedule(workerLogin, year, month) {
        fetch(`/api/schedule/${workerLogin}?year=${year}&month=${month}`)
            .then(response => response.json())
            .then(data => {
                data.forEach(event => {
                    const eventDate = new Date(event.start);
                    const eventMonth = eventDate.getMonth() + 1;
                    const eventYear = eventDate.getFullYear();
                    if (eventMonth === month && eventYear === year) {
                        const day = eventDate.getDate();
                        const rowIndex = Math.floor((blankDays + day - 1) / 7);
                        const cellIndex = (blankDays + day - 1) % 7;
                        const dayCell = calendarBody.rows[rowIndex].cells[cellIndex];
                        if (dayCell) {
                            const eventElement = document.createElement('div');
                            eventElement.classList.add('event');
                            eventElement.textContent = event.title;
                            if (event.absenceReason) {
                                const reasonElement = document.createElement('div');
                                reasonElement.classList.add('fc-absence-reason');
                                reasonElement.textContent = event.absenceReason;
                                eventElement.appendChild(reasonElement);
                            }
                            dayCell.appendChild(eventElement);
                        }
                    }
                });
            })
            .catch(error => console.error("Error fetching data: ", error));
    }

    document.addEventListener('DOMContentLoaded', renderCalendar);
}

// Check and execute scripts for the Create Message page
if (document.getElementById('messageForm')) {
    document.getElementById('fileInput').addEventListener('change', function(e) {
        const files = e.target.files;
        const formData = new FormData();
        for (let file of files) {
            formData.append('files[]', file);
        }

        fetch('/upload-files', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            data.urls.forEach(url => {
                const img = document.createElement('img');
                img.src = url;
                document.getElementById('editor').appendChild(img);
            });
        })
        .catch(error => console.error('Error:', error));
    });

    document.getElementById('messageForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const formData = new FormData(this);
        const content = document.getElementById('editor').innerHTML;

        formData.set('content', content);

        fetch('/send-message', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                alert('Message sent successfully!');
                document.getElementById('messageForm').reset();
                document.getElementById('editor').innerHTML = '';
            } else {
                alert('Error sending message');
            }
        })
        .catch(error => console.error('Error:', error));
    });
}

// Check and execute scripts for the Worker Information page
if (document.getElementById('new-messages-count')) {
    document.addEventListener('DOMContentLoaded', function() {
        function fetchNewMessagesCount() {
            fetch('/api/new-messages-count')
                .then(response => response.json())
                .then(data => {
                    if (data.count > 0) {
                        document.getElementById('new-messages-count').textContent = data.count;
                    } else {
                        document.getElementById('new-messages-count').style.display = 'none';
                    }
                })
                .catch(error => console.error('Error fetching new messages count:', error));
        }
        fetchNewMessagesCount();
    });
}
