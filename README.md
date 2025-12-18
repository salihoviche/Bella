# Bella - Hair Salon Management System

Bella is a comprehensive hair salon management system built with .NET Core backend and Flutter mobile/desktop applications. The system supports multiple user roles including administrators, clients, and hairdressers, with features for appointment booking, product management, order processing, and real-time notifications via RabbitMQ.

## Project Structure

```
Bella/
├── Bella.Model/          # Data models, requests, responses, and search objects
├── Bella.Services/       # Business logic and database services
├── Bella.Subscriber/     # RabbitMQ message subscriber service
├── Bella.WebAPI/         # REST API endpoints
└── UI/
    ├── bella_client_mobile/        # Flutter mobile app for clients
    ├── bella_desktop/              # Flutter desktop app for administrators
    └── bella_hairdresser_mobile/   # Flutter mobile app for hairdressers
```

## Test Accounts

### Admin Desktop App
- **Username:** `admin`
- **Password:** `test`

### Client Mobile App
- **Username:** `user`
- **Password:** `test`

### Hairdresser Mobile App
- **Username:** `hairdresser`
- **Password:** `test`

## Environment Configuration

### Root `.env` File
Located in the root of the project (Bella/), this file contains configuration for:
- **RabbitMQ Settings:**
  - `RABBITMQ__HOST` - RabbitMQ server host
  - `RABBITMQ__USERNAME` - RabbitMQ username
  - `RABBITMQ__PASSWORD` - RabbitMQ password
  - `RABBITMQ__VIRTUALHOST` - RabbitMQ virtual host (default: `/`)

- **SQL Server Settings:**
  - `SQL__USER` - SQL Server username
  - `SQL__PASSWORD` - SQL Server password
  - `SQL__DATABASE` - Database name
  - `SQL__PID` - SQL Server product ID (optional)

### Client Mobile App `.env` File
Located in `Bella/UI/bella_client_mobile/`, this file contains:
- **Stripe Configuration:**
  - `STRIPE_PUBLISHABLE_KEY` - Stripe publishable key (PK)
  - `STRIPE_SECRET_KEY` - Stripe secret key (SK)

## RabbitMQ Testing

RabbitMQ notifications are triggered in `AppointmentService.cs` when appointments are created or cancelled. The service publishes messages to RabbitMQ that are consumed by the subscriber service.

### Testing RabbitMQ Email Notifications

To test RabbitMQ email notifications:

1. **Test Email Account:**
   - **Email:** `bella.salon.example@gmail.com`
   - **Password:** `bellaseminarski2025`

2. **How to Test:**
   - Create a new appointment in the system
   - Set **Emina Salihovic** as the hairdresser
   - The appointment creation will trigger a RabbitMQ notification
   - Check the test email account for the notification email

3. **Notification Flow:**
   - When an appointment is created, `AppointmentService.AfterInsert()` is called
   - This triggers `SendAppointmentNotificationAsync()` which publishes a message to RabbitMQ
   - The `Bella.Subscriber` service consumes the message and sends an email notification
   - Similarly, appointment cancellations trigger `SendAppointmentCancellationNotificationAsync()`

