# Paliriza — Rooted in Change

An AI-powered carbon footprint tracker built for SETA Hack by **Spark Twins**.

**Live app:** https://carbon-footprint-tracker-298a3.web.app
**Landing page:** https://carbon-footprint-tracker-298a3.web.app

---

## What it does

Paliriza turns everyday choices — how you get around, what you eat, how you power your home, how often you fly, shop, and go out — into a clear, ongoing picture of your monthly carbon footprint. It pairs that with an AI companion for open-ended sustainability questions and a gamified system (points, streaks, badges) to make consistent tracking feel like less of a chore.

Built around three UN Sustainable Development Goals:
- **SDG 11** — Sustainable Cities and Communities
- **SDG 12** — Responsible Consumption and Production
- **SDG 13** — Climate Action

## Features

- **Accounts** — per-user sign-up/login via Firebase Authentication
- **Lifestyle onboarding** — a detailed questionnaire (transport, diet, home energy, waste/recycling, flights, water usage, shopping habits, and social outings — including free-text "Other" answers) that seeds each user's starting footprint
- **Daily check-ins** — a quick daily log updates the footprint and feeds a running history
- **Footprint dashboard** — a category-by-category breakdown of estimated monthly kg CO2e, grounded in published emission-factor research rather than arbitrary numbers
- **Gamification** — points for lower-carbon choices, day-over-day streaks, and unlockable badges
- **AI chatbot** — an open Q&A assistant for sustainability questions, powered by Google's Gemini API
- **Light/dark mode** — full theming, not just a color swap

## Tech stack

- **Frontend:** Flutter (web)
- **Backend:** Firebase (Authentication, Cloud Firestore, Hosting)
- **AI:** Google Gemini API
- **Hosting:** Firebase Hosting

## Team

Spark Twins — Lana & Mohamed

## Running it locally

```bash
git clone https://github.com/lanamohamedmosaadelsabaa-jpg/-carbon_footprint_tracker.git
cd -carbon_footprint_tracker
flutter pub get
```

```dart
const String geminiApiKey = 'AQ.Ab8RN6IivGUA9aC8PklNJCmufURgwOI4ufTilNwRrw-j67na8Q';
```

Then run:
```bash
flutter run -d chrome
```

## A note on the calculation methodology

Category estimates are informed by published averages (vehicle fleet emissions data, diet-footprint research, typical grid electricity carbon intensity) rather than precise per-user measurement. A natural next step is collecting actual logged distances/kWh for more precise, individualized figures.

