# Hisaab — Freelancer Tax Companion

A Flutter app for Pakistani freelancers (Fiverr, Upwork, direct clients) who
get paid via Payoneer, Wise, or bank transfer. Log payments, track the
**80% approved-channel rule**, see your estimated final tax rate, and
generate a clean PDF summary for your accountant or FBR IRIS filing.

## Why this exists

Every existing "solution" for this problem is a human consultancy service —
send your bank statements over WhatsApp and someone manually reconciles
them. Hisaab is a self-service tool that does the reconciliation and
80%-rule tracking for you, in real time, as you log each payment.

## Core features (MVP)

- Onboarding — name, NTN, PSEB registration status
- Dashboard — a circular "Compliance Ring" showing what % of this tax
  year's income came through an approved channel, plus estimated tax
  and a filing-deadline countdown (Sep 30)
- Transaction log — add/delete payments by channel (Payoneer, Wise,
  Pakistani Bank, Other), swipe to delete
- Tax-year switcher (Pakistani tax year: July 1 – June 30)
- PDF report generation + share, summarizing income, the 80% rule,
  estimated tax, and a full transaction list
- Settings — edit profile, clear all local data

## Tax logic (see `lib/services/tax_engine.dart`)

- Tax year: July 1 to June 30
- 80% rule: at least 80% of foreign income must arrive via Payoneer,
  Wise, or a Pakistani bank to qualify for the reduced final tax rate
- If the 80% rule is met: 0.25% (PSEB-registered) or 1% (not registered)
- If the 80% rule is **not** met, the app does not guess a slab
  calculation — it flags this clearly and recommends consulting a tax
  advisor, since normal income tax slabs depend on total taxable income.

**This is self-reported, reference-only data — not official tax advice.**
Always confirm figures with a registered tax consultant or the FBR IRIS
portal before filing.

## Setup

```bash
flutter pub get
flutter run
```

## Not yet built (roadmap ideas)

- Cloud sync / multi-device (Firebase, same pattern as before)
- CSV import directly from Payoneer/Wise exports (currently manual entry)
- Push/local notification reminders near the Sep 30 deadline
- Multi-year comparison charts
- Editing an existing transaction (currently add/delete only)
