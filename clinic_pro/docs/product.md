# 📦 product.md — Product Definition

---

## Product Vision

**ClinicPro** is a multi-tenant SaaS mobile application built with Flutter,
designed to digitize and streamline the daily operations of medical clinics —
from appointment scheduling and patient management to prescription writing,
invoicing, and expense tracking — all in one fast, role-aware system.

---

## Problem Statement

Medical clinics in the Arab world still rely heavily on paper-based systems or
disconnected tools. This leads to:

- Lost patient records and prescription history
- Scheduling conflicts and missed appointments
- No visibility into clinic financial performance
- Difficulty managing multi-doctor or multi-branch operations
- Time wasted on manual paperwork during patient visits

---

## Target Users

| Role | Description |
|------|-------------|
| **Owner** | Clinic owner — manages everything, may or may not be a doctor |
| **Doctor** | Handles appointments, patient examinations, and prescriptions |
| **Secretary** | Manages appointments, patient check-in, and invoices |

---

## Core Features

### 👤 User & Clinic Management
- Multi-clinic support under one owner account
- Staff invitation system via email (no self-registration for staff)
- Role-based access control per clinic

### 📅 Appointments
- Daily / weekly / monthly calendar view
- Real-time waiting queue
- Appointment types with custom pricing
- Status tracking: scheduled → confirmed → in_progress → done → cancelled

### 🏥 Patient Management
- Full patient profile (medical history, allergies, chronic conditions)
- Visit history and previous prescriptions

### 📋 Prescription (Examination Screen)
- Opened exclusively from "Confirm Examination" button
- Diagnosis via reusable templates (multi-select)
- Per-drug dose configuration: Frequency + Duration + Timing (Chip rows)
- Export to PDF and share via WhatsApp

### 💊 Drugs & Templates
- Shared drug database (trade name + generic name)
- Doctor-specific prescription templates with use count tracking

### 💰 Financial
- Auto-generated invoices after examination
- Manual expense tracking with categories
- Reports: revenue vs expenses, doctor performance

### 🔔 Realtime
- Live waiting queue (Supabase Realtime)
- Live appointment updates across all staff devices

---

## Subscription Plans

| Plan | Monthly Price | Yearly Price | Lifetime Price| Staff | Patients | Clinics |
|------|-------|---------|----------|-------|-------|-------|
| Basic | $7/mo | $70/yr | $155 | 3 | 1000 | 1 |
| Growth | $11/mo | $110/yr | $250 | 20 | 5000 | 3 |
| Enterprise | $17/mo | $170/yr | $350 | Unlimited (-1) | Unlimited (-1) | Unlimited (-1) |

- 14-day free trial
- Subscription is per Owner, not per clinic

---

## Scope

### ✅ Included in v1.0
- Authentication (Google, Apple, Magic Link)
- Owner onboarding flow
- Staff invitation via email
- All 27 screens (UI-first approach)
- Appointments, patients, prescriptions, invoices, expenses
- Reports and analytics
- Light & Dark theme
- Arabic (RTL) + English (LTR) localization
- Responsive: Android, iOS, Tablet

### ❌ Excluded from v1.0 (Future)
- Lab results and radiology management
- Telehealth / video consultations
- Insurance claim management
- Desktop support (planned for v2.0)
- Patient-facing mobile app

---

## Development Approach

> **UI First** — The entire UI is built with mock data before any Supabase
> integration. This ensures screens are fully designed and tested independently
> before connecting to the backend.
