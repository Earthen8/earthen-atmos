import requests

def fetch_weather(city_name):
    # This is an example call to OpenWeatherMap API
    # Normally you would put the API key in settings or environment variables
    # For demonstration, assuming a generic or placeholder structure, but let's pass an api key
    api_key = "PLACEHOLDER_KEY"  # To be replaced with an actual key or env var
    url = f"https://api.openweathermap.org/data/2.5/weather?q={city_name}&appid={api_key}&units=metric"
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        # Return only necessary fields
        return {
            "temperature": data.get("main", {}).get("temp"),
            "condition": data.get("weather", [{}])[0].get("main"),
            "humidity": data.get("main", {}).get("humidity"),
            "city_name": data.get("name")
        }
    except requests.RequestException:
        # In a real app we might want to handle this more gracefully
        return None
