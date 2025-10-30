# Private Clinic App

The **Private Clinic App** is a Salesforce-based healthcare management system for private clinics.  
It supports internal clinic operations and includes a secure **Patient Portal** built on **Experience Cloud**, where patients can view and book appointments, update profile information, and pay invoices online.

---

## Users & Access

| User / Team | Purpose |
|------------|---------|
| **Doctor** | Views only their own appointments and patient records |
| **Receptionist** | Manages appointments for all doctors |
| **Billing Team** | Manages invoices, payments, and billing communication |
| **CEO / Admin** | Full visibility and reporting |
| **Patient Portal User** *(Profile)* | Accesses personal records, appointments, and invoices in the portal |

**Access is controlled through:**
- **Profiles:** Doctor, Receptionist, Billing, Patient Portal User, Integration User  
- **Permission Sets:** (Manage Patients, Manage Appointments, Manage Invoices, Manage Doctors, etc.)
- **Manual sharing model** for patient-related data (details below)

---

## Data Model (Key Custom Objects)

| Object | Purpose | Key Relationships |
|--------|---------|------------------|
| **Patient__c** | Patient record | Lookup **User__c** (links portal user to patient) |
| **Doctor__c** | Clinic staff doctor profile | Lookup **User__c** (links internal user to doctor) |
| **Appointment__c** | Appointment scheduling & tracking | Lookup **Patient__c**, **Doctor__c**, **Treatment__c** |
| **Invoice__c** | Billing record | Lookup **Appointment__c**, **Patient__c** |
| **Treatment__c** | Service catalog | Price & duration |
| **Insurance_Company__c** | Optional payer | Used for invoice routing & email delivery |

**OWD (Org-Wide Defaults):**
Patient__c, Appointment__c, and Invoice__c: Private → Require **manual sharing** so portal users only see their own records.

---

## Internal Clinic Application (Salesforce App)

Used by Doctors, Receptionists, Billing staff, and Management.

### Key Features  
- Patient management  
- Appointment creation and updates  
- Treatment and doctor schedule management  
- Invoice review and status tracking  

---

## Clinic Calendar

The internal **Home page** includes a Clinic Calendar built with **LWC + FullCalendar.js (Static Resource)**.

| Visibility | Behavior |
|-----------|-----------|
| **Doctor** | Sees **only their** appointments |
| **Receptionist** | Sees **all** clinic appointments |

The calendar updates automatically when `Appointment__c` records change.

> *This component is not displayed in the Patient Portal.*

---

## Patient Portal (Experience Cloud)

Patients can:
- Update personal profile information
- View upcoming and past appointments
- View invoices and payment status
- **Pay invoices online via Stripe Checkout**
- Book appointments *(after completing their profile)*

Portal UI is built using **Lightning Web Components**, including: 
patientProfile, patientAppointments, patientInvoices, doctorList + doctorAvailabilityModal

---

## Invoice Generation (PDFMonkey Integration)

When an **Appointment__c** is marked **Completed**, an **Invoice__c** is created with status **Draft**.

### Nightly Automation Jobs
| Time | Process |
|------|---------|
| **02:00 AM** | Batch - sends invoice data to PDFMonkey → receives PDF Document ID |
| **02:30 AM** | Batch - downloads generated PDF files → stores them as Files on Invoice__c |

### Invoice Delivery
A Flow runs in the morning and **emails the PDF invoice** to:
- The **patient**, or
- The **insurance company** (if the patient is insured)

The email also includes the **Stripe payment link**.  
After the email is sent → `Invoice__c.Status__c = "Sent"`.

---

## Online Payments (Stripe Integration)

Invoices automatically receive **Payment Links** from Stripe via a nightly batch job.

### Payment Flow
Patient clicks "Pay Invoice" (in portal or email)
→ Redirect to Stripe Checkout
→ Payment completed
→ Stripe Webhook (Heroku service) receives event
→ Heroku authenticates to Salesforce (JWT OAuth)
→ Invoice__c.Status__c is updated to "Paid"

Webhook integration is maintained in a separate repo:  
**[https://github.com/.../salesforce-stripe-integration](https://github.com/CecaDj/salesforce-stripe-integration)**

---

## Secure Record Visibility (Cascade Sharing)

Because core objects are **Private**, a **platform event–based sharing mechanism** ensures portal users see **only their own** data.

### Sharing Architecture
Trigger → Publish ShareEvent__e
→ ShareEventTriggerHandler
→ PortalSharingService
→ Creates __Share records

### Cascade Logic
Patient__c → Appointment__c → Invoice__c (only if Status != 'Draft')

This ensures patients see **only their own** records.

---

## Additional Automations (Flows)

| Flow | Purpose |
|------|---------|
| Appointment Email Notification | Sends booking/cancellation/update emails |
| Daily Appointment Reminder | Reminds patients of next-day appointments |
| Weekly Invoice Reminder | Notifies patients of unpaid invoices every Monday |
| Patient Portal Registration Flow | Links new portal users to the correct Patient__c or creates a new one |

Flows handle **communication and orchestration** →  
**Business logic remains in Apex services.**

---
