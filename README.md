# ☁️ Atmos — Premium Weather Experience

Atmos is a modern, high-fidelity weather application that combines a robust **Django Rest Framework** backend with a stunning **Flutter** frontend. It features a heavy glassmorphic design, dynamic generative weather environments, and comprehensive atmospheric data.

<p align="center">
  <img src="https://i.ibb.co.com/HD8M4Ndw/Screenshot-2026-04-21-114739.png" width="32%" />
  <img src="https://i.ibb.co.com/KxVrPwTr/Screenshot-2026-04-21-115538.png" width="32%" />
  <img src="https://i.ibb.co.com/C3S2cLrD/Screenshot-2026-04-21-120103.png" width="32%" />
</p>

## ✨ Features

- **Generative Weather Environments**: A custom-built engine using Flutter's `CustomPainter` that renders real-time, procedurally generated weather effects.
- **Advanced Particle Systems**: Unique physics for every condition—falling rain with wind drift, oscillating snowflakes, and floating "Frutiger Aero" bubbles.
- **Atmospheric Visuals**: Dynamic lighting including pulsing sun rays, drifting procedural clouds, periodic lightning bolts with screen flashes, and shimmering puddle effects.
- **Heavy Glassmorphism**: A state-of-the-art UI with deep blurs, multi-layered translucency, and inner glow effects.
- **6-Point Data Grid**: Comprehensive stats including Feels Like, Humidity, Wind Speed, Visibility, Pressure, and Conditions.
- **Smart Search**: Intuitive city searching with automatic soft-keyboard dismissal and focus management.
- **Portrait locked**: Optimized for the best vertical mobile experience.

---

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
  - **Core**: CustomPainter & AnimationController
  - **State Management**: Provider
  - **Networking**: Http
  - **UI**: Heavy Glassmorphism & Procedural Backgrounds
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
pip install -r requirements.txt

# Setup environment variables
cp .env.example .env
# Edit .env and paste your OPENWEATHER_API_KEY

# Run database migrations
python manage.py migrate
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
Atmos is built on the principle of **"Liquid Motion"**. Every element, from the generative particle backgrounds to the heavy glass cards, is designed to feel alive and organic. By leveraging Flutter's `CustomPainter`, the app moves beyond static gradients to create a truly immersive environment that mirrors the sky.

## 🤝 Contributing
Feel free to fork this repository and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

---

**Built by Earthen8 for a better weather experience.**

