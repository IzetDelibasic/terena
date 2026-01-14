# **Terena - Sports Court Booking Application**

Terena is a sports court booking application that allows users to browse available courts, book time slots, pay via Stripe, and track their reservations. The system is built using a .NET Web API backend, with Flutter-based desktop and mobile applications.

---

## **How to Run the Project**

### **Environment Setup**

1. **Extract fit_env.zip**

   - Extract the file `fit_env.zip` (password: **fit**)
   - Copy the `.env` file into the root Terena folder (the same directory where `docker-compose.yml` is located)

2. **Start Backend Services**

   - Run Docker and:

   ```bash
   docker compose up --build
   ```

3. **Locate the Desktop and Mobile Applications**

   - Exract files from `fit-build-2026-01-14`
   - Find the `.apk` file for the Android mobile app in the `android_mobile_app` folder
   - Find the `.exe` file for the Windows desktop app in the `dekstop_app` folder

---

## **Installing the Applications**

- **Desktop Application**: Run the `terena_desktop.exe` file
- **Mobile Application**: Install the `app-release.apk` file on an Android device

---

## **Login Credentials**

### **Desktop Application (Administrator)**

- **Username:** admin
- **Password:** Admin123

### **Mobile Application (Administrator)**

- **Username:** admin
- **Password:** Admin123

### **Mobile Application (Regular Users)**

- **Username:** emir
- **Password:** Emir123

or

- **Username:** kenan
- **Password:** Kenan123

---

## **Test Payment Credentials**

### **Stripe Test Card**

Use the following details to test Stripe payments when booking court time slots:

- **Card Number:** 4242 4242 4242 4242
- **Expiration Date:** 12/34
- **CVC:** 123
- **Postal Code:** 12345

For additional test cards and different testing scenarios, visit:
[https://docs.stripe.com/testing](https://docs.stripe.com/testing)

---

## **RabbitMQ**

The project uses RabbitMQ as a message broker for asynchronous communication and sending email notifications to users. RabbitMQ manages the following message queues:

- **booking_confirmations** - Sends email confirmations to users after a successful court booking
- **booking_cancellations** - Notifies users when their booking has been cancelled
- **booking_reminders** - Sends reminders to users before their scheduled booking time

This architecture enables reliable and scalable email notification delivery without blocking the main API.

---

## **Email Service**

The application includes a comprehensive email notification system that sends professionally styled HTML emails to users. The Email Service is integrated with RabbitMQ for asynchronous message processing and uses SMTP (configured for Gmail) to deliver emails.

### **Email Types**

1. **Booking Confirmation Email** - Sent immediately after a successful booking, containing:

   - Booking number and venue details
   - Date, time slot, and total price
   - Important reminders (arrive 10 minutes early, bring confirmation number)

2. **Booking Cancellation Email** - Sent when a booking is cancelled, including:

   - Cancellation reason
   - Booking details for reference
   - Support contact information

3. **Booking Reminder Email** - Sent before the scheduled booking time with:
   - Upcoming booking details
   - Helpful reminders for the visit

### **How It Works**

1. When a booking event occurs (creation, cancellation), the `BookingService` creates a message and sends it to RabbitMQ via `NotificationService`
2. The `RabbitMQProducer` publishes the message to the appropriate queue
3. The `EmailConsumerService` (background service) runs continuously, consuming messages from RabbitMQ
4. The `RabbitMQConsumer` processes each message and calls the `EmailService` to send the actual email
5. Emails are sent via SMTP with professionally designed HTML templates

---

## **System Architecture**

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Flutter Mobile │     │ Flutter Desktop │     │   SQL Server    │
│       App       │     │       App       │     │    Database     │
└────────┬────────┘     └────────┬────────┘     └────────▲────────┘
         │                       │                       │
         └───────────┬───────────┘                       │
                     │                                   │
                     ▼                                   │
         ┌───────────────────────┐                       │
         │    .NET Web API       │───────────────────────┘
         │   (REST Endpoints)    │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐     ┌─────────────────┐
         │      RabbitMQ         │────▶│  Email Service  │
         │   (Message Broker)    │     │     (SMTP)      │
         └───────────────────────┘     └─────────────────┘
```

---

## **Technologies**

- **Backend:** .NET 8 Web API, Entity Framework Core, SQL Server
- **Frontend:** Flutter (Desktop and Mobile)
- **Payments:** Stripe API
- **Message Broker:** RabbitMQ
- **Email:** SMTP (Gmail)
- **Containerization:** Docker, Docker Compose
- **Object Mapping:** Mapster

---

## **Key Features**

- Browse and search sports venues and courts
- Real-time availability checking for time slots
- Secure payment processing via Stripe
- Booking management (create, confirm, cancel, refund)
- User authentication and authorization
- Admin dashboard for venue and booking management
- Automated email notifications for booking events
- Discount system for longer bookings
- Review and rating system for venues
- Favorite venues functionality
- Personalized venue recommendations based on user preferences
