📄 Product Requirements Document (PRD)
Product Name (Working Title)

Basis AI
Tagline: Your AI CFO for SaaS Spend

1. Product Vision

To help startups and growing companies:

Track all SaaS subscriptions

Detect hidden and wasted costs

Forecast long-term expenses

Compare Rent vs Own decisions

Optimize and consolidate tools

Make data-driven financial decisions using AI

The platform will function as a SaaS cost intelligence engine, not just a subscription tracker.

2. Target Market (Ideal Customer Profile)
Primary ICP

Seed to Series A startups

10–100 employees

Remote-first teams

SaaS-heavy companies

Founders, CFOs, Finance Leads

Secondary

Agencies

Tech startups

VC portfolio companies

3. Problem Statement

Startups often:

Don’t know their true SaaS spend

Pay for unused licenses

Use redundant tools

Face unexpected price increases

Cannot project long-term cost impact

Struggle with Build vs Buy decisions

This results in thousands of dollars wasted annually.

4. Core Features
4.1 SaaS Stack Input System
MVP:

Tool name

Plan type

Cost per user

Number of users

Billing cycle

Renewal date

Department allocation

Phase 2:

CSV import

Stripe/Bank integration

API auto-detection

4.2 Intelligent Cost Dashboard

Displays:

Monthly total spend

Annual total spend

3-year projection

5-year projection

Cost per employee

Growth-adjusted forecast

Inflation-adjusted forecast

4.3 Professional Graph System

Must include interactive enterprise-grade charts:

SaaS Spend Over Time (Line Graph)

Tool Cost Distribution (Pie Chart)

Department Breakdown (Bar Chart)

Growth Projection (Area Graph)

Rent vs Own Comparison Graph

Requirements:

Interactive hover data

Export to PDF/CSV

Clean CFO-level UI

Fast rendering

Suggested libraries:

Recharts

Chart.js

Apache ECharts

4.4 AI Waste Detection Engine

AI identifies:

Unused licenses

Redundant tools

Overlapping features

Downgrade opportunities

Vendor lock-in risk

Upcoming price increase impact

Output example:

“Potential annual savings: $12,480”

4.5 Break-Even Analysis Engine

Inputs:

Custom build cost

Current SaaS yearly cost

Team growth rate

Outputs:

Break-even year

ROI timeline

Sensitivity analysis

Risk score

4.6 Rent vs Own Intelligence

AI comparison table:

Factor	SaaS	Custom Build
1-Year Cost	✔	✔
3-Year Cost	✔	✔
5-Year Cost	✔	✔
Scalability	✔	✔
Control	✔	✔
Risk Level	✔	✔

Includes visual ROI comparison graph.

4.7 AI Consolidation Engine

Analyzes entire stack and suggests:

Tool replacements

Stack consolidation

Open-source alternatives

Reserved cloud pricing optimization

Downgrade recommendations

Example:
“Replace Slack + Loom + Zoom with Microsoft 365 – Estimated savings: $8,200/year”

5. Technical Architecture

🚀 Basis AI – Flutter Technical Architecture
🧱 Overall Architecture

Flutter (Frontend App)
↓
Backend API (Supabase / Node / Firebase)
↓
PostgreSQL Database
↓
AI Layer (OpenAI API)

📱 Frontend (Flutter)

You will build:

Web App (Flutter Web)

Possibly Desktop later

Optional mobile app

Flutter is good because:

Single codebase

Fast UI

Professional dashboard possible

Works for SaaS

📊 Professional Graph Libraries for Flutter

Instead of web chart libraries, use:

1️⃣ fl_chart

Best for:

Line charts

Bar charts

Pie charts

Area charts

Very customizable.

2️⃣ syncfusion_flutter_charts (Enterprise-level)

Best for:

Advanced CFO dashboards

Export support

Professional animation

Zoom & interaction

This is more “enterprise looking”.

3️⃣ charts_flutter (Google)

Basic but less flexible.

📊 Your Required Graph Types in Flutter

You need:

SaaS Spend Over Time → Line Chart

Tool Distribution → Pie Chart

Department Breakdown → Bar Chart

3–5 Year Projection → Area Chart

Rent vs Own → Comparative Bar/Line

All possible with:
👉 fl_chart
or
👉 Syncfusion (more premium)

🗄 Backend (Recommended for Flutter)

Option 1 (Best balance):

Supabase (Auth + PostgreSQL + Storage)

Option 2:

Firebase (but less structured for financial modeling)

For financial intelligence platform:
👉 PostgreSQL is better.

🤖 AI Layer in Flutter Architecture

Flutter does NOT handle AI directly.

Flow:

User → Flutter UI
→ Backend API
→ OpenAI API
→ Backend processes result
→ Return structured insights
→ Display in dashboard

Never call OpenAI directly from Flutter (security risk).

🔐 Security Considerations

Since this is SaaS finance data:

JWT authentication

Role-based access

Encrypted storage

No AI key exposed on frontend

Secure API gateway

🏗 Updated Technical Stack (Flutter Version)

Frontend:

Flutter Web

fl_chart or Syncfusion

Provider / Riverpod (state management)

Backend:

Supabase (Auth + DB)

Node API layer

PostgreSQL

AI:

OpenAI API

Rule-based cost engine

Forecast modeling service

⚠️ Important Reality

Flutter is good for:

Beautiful UI

Cross-platform apps

But:

Most B2B SaaS dashboards are built with:

React / Next.js

Because:

Easier SEO

Easier web integration

More SaaS ecosystem support

Flutter Web is improving, but still heavier.

🧠 Honest Founder Advice

If your goal is:

Enterprise SaaS
VC-backed startup
Global CFO-level tool

Then React/Next.js is industry standard.

If your goal is:

Fast build
Nice UI
Cross-platform app

Flutter is fine.
6. Non-Functional Requirements

Page load under 2.5 seconds

Enterprise-grade design

Fully responsive

Secure authentication

Scalable architecture

Clean onboarding flow

7. Monetization Model

Starter – $29/month
Growth – $79/month
Enterprise – Custom pricing

Add-ons:

AI SaaS Audit Report ($199 one-time)

VC Portfolio Dashboard Plan