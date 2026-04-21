from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .services import fetch_weather

class WeatherAPIView(APIView):
    def get(self, request):
        city = request.query_params.get("city")
        if not city:
            return Response({"error": "City parameter is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        weather_data = fetch_weather(city)
        if weather_data:
            return Response(weather_data, status=status.HTTP_200_OK)
        
        return Response({"error": "Could not fetch weather for the provided city"}, status=status.HTTP_404_NOT_FOUND)
