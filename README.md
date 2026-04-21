# ☁️ Atmos — Premium Weather Experience

Atmos is a modern, high-fidelity weather application that combines a robust **Django Rest Framework** backend with a stunning **Flutter** frontend. It features a heavy glassmorphic design, dynamic background animations that respond to weather conditions, and comprehensive atmospheric data.

<p align="center">
  <img src="https://i.ibb.co.com/HD8M4Ndw/Screenshot-2026-04-21-114739.png" width="32%" />
  <img src="https://i.ibb.co.com/WvB2htm2/Screenshot-2026-04-21-115538.png" width="32%" />
  <img src="https://i.ibb.co.com/JwSQ1Zhg/Screenshot-2026-04-21-120103.png" width="32%" />
</p>

## ✨ Features

- **Heavy Glassmorphism**: A state-of-the-art UI with deep blurs, multi-layered translucency, and inner glow effects.
- **Dynamic Atmosphere**: Animated background gradients and ambient orbs that change colors based on real-time weather conditions.
- **6-Point Data Grid**: Comprehensive stats including Feels Like, Humidity, Wind Speed, Visibility, Pressure, and Conditions.
- **Smart Search**: Intuitive city searching with automatic soft-keyboard dismissal and focus management.
- **Responsive & Centered**: A layout that intelligently adapts to different screen sizes while keeping focus on the data.
- **Portrait Locked**: Optimized for the best vertical mobile experience.

---

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
  - **State Management**: Provider
  - **Networking**: Http
  - **UI**: Custom Glassmorphism & Animated Shadows
- **Backend**: Django (Python)
  - **Framework**: Django Rest Framework (DRF)
  - **External API**: OpenWeatherMap API
  - **Environment**: python-dotenv

---

## 🚀 Getting Started

Follow these steps to set up Atmos on your local machine.

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- [Python 3.10+](https://www.python.org/downloads/)
- [OpenWeather API Key](https://openweathermap.org/api) (Free tier works perfectly)

### 2. Backend Setup (Django)
```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv

# Activate venv (Windows)
.\venv\Scripts\activate

# Install dependencies
pip install django djangorestframework requests python-dotenv django-cors-headers

# Setup environment variables
cp .env.example .env
# Edit .env and paste your OPENWEATHER_API_KEY
```

**Run Backend:**
```bash
python manage.py runserver 0.0.0.0:8000
```
*The backend must be running for the Flutter app to fetch real-time data.*

### 3. Frontend Setup (Flutter)
```bash
# Navigate to frontend
cd frontend

# Get packages
flutter pub get

# Run the app (Chrome or Mobile)
flutter run -d chrome
```

---

## 🔑 Environment Variables

The backend requires a `.env` file in its root directory:

```env
OPENWEATHER_API_KEY=your_secret_api_key_here
```

---

## 📸 Design Philosophy
Atmos is built on the principle of **"Liquid Motion"**. Every element, from the background orbs to the glass card, is designed to feel alive and organic. By using `BackdropFilter` and `AnimatedContainer`, I achieve a level of depth that mimics real frosted glass under changing skies.

## 🤝 Contributing
Feel free to fork this repository and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

---

**Built by Earthen8 for a better weather experience.**
