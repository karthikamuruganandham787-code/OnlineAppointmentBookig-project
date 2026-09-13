# MediBook — Online Appointment Booking System
### Project 3 — Servlet / JSP / JDBC / MariaDB

MediBook is a complete, standalone online appointment booking platform.
Patients can browse doctors, choose a service, pick a date and time from a
live calendar, enter their details, review, and confirm an appointment —
with the backend guaranteeing no doctor is ever double-booked.

---

## 1. Technology Stack

| Layer      | Technology                                   |
|------------|-----------------------------------------------|
| Backend    | Java 8, Servlet (javax.servlet, MVC pattern)  |
| Frontend   | JSP, JSTL, EL, HTML5, CSS3, vanilla JavaScript |
| Data Access| JDBC + DAO pattern                            |
| Server     | Apache Tomcat 9                               |
| Database   | MariaDB                                       |
| Build Tool | Maven                                         |

No Spring, no Hibernate, no frontend frameworks — pure Servlet/JSP/JDBC.

---

## 2. Project Structure

```
project3-medibook/
├── pom.xml
├── database.sql
├── README.md
└── src/main/
    ├── java/com/project3/
    │   ├── controller/   (Servlets: Home, Doctor, Service, Booking, Appointment, Confirmation)
    │   ├── dao/          (DoctorDAO, ServiceDAO, ScheduleDAO, AppointmentDAO)
    │   ├── model/        (Doctor, Service, DoctorService, TimeSlot, Appointment)
    │   └── util/         (DBConnection)
    └── webapp/
        ├── WEB-INF/web.xml
        ├── WEB-INF/jspf/  (header.jspf, footer.jspf — shared includes)
        ├── css/style.css
        ├── js/main.js, js/booking.js
        ├── index.jsp, doctors.jsp, services.jsp, book.jsp,
        │   confirmation.jsp, my-appointments.jsp, error.jsp
```

---

## 3. Database Setup

1. Start MariaDB and make sure it is listening on **port 3308** (not the
   default 3306). Example `my.cnf` snippet:
   ```
   [mysqld]
   port = 3308
   ```
2. Run the schema + seed script:
   ```
   mysql -u root -p -P 3308 -h localhost < database.sql
   ```
   This creates the `employeedb` database with tables `doctors`,
   `services`, `doctor_services`, `doctor_schedule`, `appointments`,
   seeds 6 doctors / 6 services, and auto-generates two weeks of
   15-minute schedule slots (9 AM–5 PM, Mon–Sat) for every doctor.

3. Connection settings used by the app (`DBConnection.java`):
   ```
   URL      : jdbc:mariadb://localhost:3308/employeedb
   Driver   : org.mariadb.jdbc.Driver
   Username : root
   Password : admin
   ```
   Update these three constants in
   `src/main/java/com/project3/util/DBConnection.java` if your local
   credentials differ.

---

## 4. Build & Deploy

### Using Maven (command line)
```
mvn clean package
```
This produces `target/medibook.war`. Copy it into Tomcat's `webapps/`
folder (or deploy it from Eclipse/STS using "Add and Remove" on the
Tomcat 9 server), then start Tomcat.

### Using Eclipse / Spring Tool Suite
1. Import as an **Existing Maven Project**.
2. Right-click the project → **Run As → Run on Server** → choose your
   configured Apache Tomcat 9 server.
3. Visit `http://localhost:8080/medibook/`.

---

## 5. Application Flow

```
Home  →  Doctors / Services  →  Book Appointment
                                     │
                     ┌───────────────┼───────────────────┐
                     ▼               ▼                    ▼
                 1. Doctor      2. Service          3. Date & Time
                     │               │                    │
                     └───────────────┴────────┬───────────┘
                                               ▼
                                     4. Patient Details
                                               ▼
                                        5. Review & Confirm
                                               ▼
                                    Confirmation Page (Appointment ID)
```

- **GET /** or **/home** — landing page (featured doctors + services)
- **GET /doctors** — browse/search doctors
- **GET /services** — browse services
- **GET /booking** — the 5-step booking wizard (AJAX-driven)
- **POST /booking** — validates and persists the appointment
- **GET /confirmation?id=NN** — success page with appointment details
- **GET /appointment?email=...** — "My Appointments" lookup by email

---

## 6. Double-Booking Prevention

Booking is handled entirely inside `AppointmentDAO.bookAppointment()`:

1. A database transaction is opened (`autoCommit = false`).
2. The target `doctor_schedule` row is locked and re-checked with
   `SELECT ... FOR UPDATE`, so two simultaneous requests for the same
   doctor/date/time cannot both see `AVAILABLE`.
3. If the slot is already taken, the transaction rolls back and the
   client receives:
   > "This time slot is no longer available. Please select another time."
4. If available, the appointment is inserted and the schedule row is
   flipped to `BOOKED` in the same transaction, then committed.
5. As a database-level backstop, `appointments` also has a
   `UNIQUE(doctor_id, appointment_date, appointment_time)` constraint,
   so even a race condition that somehow slipped past the row lock is
   rejected by MariaDB itself.

---

## 7. AI Research & Usage

This project was built with the assistance of Claude (Anthropic) as a
pair-programming aid, used specifically for:
- Scaffolding the Maven project layout and Servlet MVC package structure.
- Drafting the JDBC/DAO boilerplate (PreparedStatements, ResultSet
  mapping) so effort could focus on correctness of the booking logic.
- Generating the CSS design system and responsive layout rules.
- Reviewing the double-booking transaction logic for correctness.

All generated code was reviewed, adjusted to the exact assignment
requirements (MariaDB port 3308, Servlet/JSP/JDBC only, no Spring),
and tested manually against the booking flow described above.

## 8. Logical Approach

The system follows a strict layered MVC design:

```
JSP (View)  →  Servlet (Controller)  →  DAO (Data Access)  →  JDBC  →  MariaDB
```

- **View (JSP)**: renders static structure and receives data only via
  `request` attributes or AJAX JSON — no business logic in JSPs beyond
  JSTL iteration/conditionals.
- **Controller (Servlet)**: one servlet per resource (`Doctor`,
  `Service`, `Booking`, `Appointment`, `Confirmation`), each exposing
  both an HTML-forwarding GET and, where the UI needs it, a
  JSON (`?format=json`) endpoint consumed by `booking.js` for the
  calendar and time-slot widgets.
- **DAO**: one class per table/entity, isolating all SQL. Only
  `AppointmentDAO` and `ScheduleDAO` share a JDBC `Connection` directly,
  and only for the booking transaction — every other DAO method opens
  and closes its own connection via try-with-resources.
- **Validation** happens twice: JavaScript (`booking.js`) blocks obviously
  invalid input before an AJAX call is made (fast feedback), and the
  `BookingServlet.doPost` independently re-validates every field
  server-side before writing to the database, so the API can never be
  tricked into an invalid state by skipping the UI.

## 9. Reason for Usage of Elements

- **Custom calendar (not `<input type="date">`)**: the assignment
  explicitly requires a calendar showing per-doctor availability
  (available/unavailable/today/selected/disabled-past), which a native
  date input cannot visually represent.
- **AJAX JSON endpoints on existing servlets** (`?format=json`) rather
  than a separate REST layer: keeps the assignment's required Servlet
  set (`HomeServlet`, `DoctorServlet`, `ServiceServlet`, `BookingServlet`,
  `AppointmentServlet`, `ConfirmationServlet`) intact while still giving
  the calendar/time-slot UI the live data it needs without full-page
  reloads.
- **`SELECT ... FOR UPDATE` + a UNIQUE constraint** rather than either
  alone: the row lock stops the race under normal load; the constraint
  is a zero-cost safety net against any edge case (e.g. isolation-level
  quirks) — belt and braces for a requirement explicitly marked
  "extremely important" in the brief.
- **Gson** for JSON serialization: keeps servlets free of hand-built
  JSON string concatenation, reducing the chance of malformed payloads
  as the doctor/service/slot models evolve.

## 10. Unique Approach Addressed

Unlike a form-per-page implementation, the entire booking journey
(Doctor → Service → Date & Time → Patient Details → Review) lives on a
**single JSP (`book.jsp`)** driven by a JavaScript state machine
(`booking.js`). This gives the "premium" stepper UX the brief asks for
(animated progress, sticky live summary, instant validation) while every
step still round-trips through real servlets and a real database — the
page never fakes data. The booking summary panel updates reactively from
the same in-memory state used for the final submission, so what the
patient sees in the sidebar is guaranteed to match exactly what gets
POSTed and stored.
