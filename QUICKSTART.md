# Quick Start Guide - Basis

## 🚀 Get Started in 5 Minutes

### Step 1: Setup Supabase (2 minutes)

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Go to **SQL Editor** and run the schema from `SUPABASE_SETUP.md`
3. Go to **Settings** → **API** and copy:
   - Project URL
   - Anon/Public Key

### Step 2: Configure the App (1 minute)

Open `lib/core/constants/app_constants.dart` and update:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

### Step 3: Install Dependencies (1 minute)

```bash
flutter pub get
```

### Step 4: Run the App (1 minute)

**For Web:**
```bash
flutter run -d chrome
```

**For Mobile:**
```bash
flutter run
```

## ✅ What You Get

### Authentication
- Email/password signup with company name
- Secure login with Supabase Auth
- Automatic session management

### Dashboard
- **Total Monthly Cost** - Current month's SaaS spend
- **Total Yearly Cost** - Annual projection
- **3-Year Total** - Long-term cost with growth
- **36-Month Chart** - Visual cost trajectory
- **Waste Warnings** - Automatic detection of:
  - Zero seats (unused subscriptions)
  - High growth rates (>20%)
  - Duplicate categories

### Add SaaS Tools
- Tool name, category, monthly price
- Number of seats/licenses
- Billing type (monthly/yearly)
- Expected yearly growth rate (%)

### Rent vs Own Calculator
- Compare competitor pricing vs your pricing
- Calculate break-even month
- Show 3-year savings
- Visual cost comparison chart

## 📱 Usage Flow

1. **Sign Up** → Enter email, password, and company name
2. **Add Tools** → Click "Add SaaS Tool" and fill in details
3. **View Dashboard** → See real-time cost calculations
4. **Check Waste** → Review warnings for optimization
5. **Calculate ROI** → Use Rent vs Own calculator

## 🎨 Design Highlights

- **Premium Dark Theme** - Professional B2B aesthetic
- **Inter Font** - Modern, clean typography
- **Responsive Layout** - Works on web and mobile
- **Real-time Updates** - Instant calculation refresh
- **Clean Architecture** - Scalable, maintainable code

## 🔐 Security

- **Row Level Security (RLS)** - Users only see their own data
- **Supabase Auth** - Industry-standard authentication
- **Secure API Keys** - Anon key is safe for client-side use

## 📊 Financial Calculations

### 3-Year Projection
```
Year 1: monthly_price × 12
Year 2: (monthly_price × (1 + growth_rate/100)) × 12
Year 3: (monthly_price × (1 + growth_rate/100)²) × 12
```

### Waste Detection
- **Zero Seats**: Tools with 0 seats allocated
- **High Growth**: Growth rate > 20%
- **Duplicate Categories**: Multiple tools in same category

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter |
| State Management | Riverpod |
| Backend | Supabase |
| Charts | fl_chart |
| Fonts | Google Fonts (Inter) |
| Architecture | Clean Architecture |

## 📁 Project Structure

```
lib/
├── core/              # Constants, theme
├── data/              # Models, repositories
├── domain/            # Entities, business logic
└── presentation/      # UI, providers, screens
```

## 🐛 Troubleshooting

### "User not authenticated" error
- Make sure you're logged in
- Check Supabase connection

### Tools not showing up
- Verify RLS policies are created
- Check Supabase dashboard for data

### Chart not displaying
- Add at least one tool first
- Ensure growth rate is set

## 🎯 Next Steps

1. ✅ Add your first SaaS tool
2. ✅ Review the 3-year projection
3. ✅ Check for waste warnings
4. ✅ Try the Rent vs Own calculator
5. ✅ Invite team members (future feature)

## 📚 Documentation

- `README.md` - Full documentation
- `SUPABASE_SETUP.md` - Database schema
- `lib/` - Inline code comments

## 💡 Tips

- Start with your most expensive tools
- Set realistic growth rates (10-15% typical)
- Review waste warnings monthly
- Use calculator for vendor negotiations

---

**Built with Flutter 💙 | Powered by Supabase ⚡**
