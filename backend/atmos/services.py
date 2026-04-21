import os
import requests

def fetch_weather(city_name):
    api_key = os.getenv("OPENWEATHER_API_KEY")

    if not api_key:
        print("Error: OPENWEATHER_API_KEY is not loaded.")
        return None

    url = f"https://api.openweathermap.org/data/2.5/weather?q={city_name}&appid={api_key}&units=metric"

    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

        return {
            "temperature": data.get("main", {}).get("temp"),
            "condition": data.get("weather", [{}])[0].get("main"),
            "humidity": data.get("main", {}).get("humidity"),
            "city_name": data.get("name"),
            "feels_like": data.get("main", {}).get("feels_like"),
            "wind_speed": data.get("wind", {}).get("speed"),
            "visibility": data.get("visibility"),
            "pressure": data.get("main", {}).get("pressure"),
        }
    except requests.RequestException as e:
        print(f"OpenWeather API Request Failed: {e}")
        return None