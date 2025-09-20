
from ovos_bus_client.message import Message
from ovos_workshop.skills import OVOSSkill
from ovos_workshop.decorators import intent_handler
import requests
from datetime import datetime


class WeatherSkill(OVOSSkill):
    def __init__(self, bus=None, skill_id=''):
        super().__init__(bus=bus, skill_id=skill_id)
        
        # Artık self.settings ve self.bus güvenle kullanılabilir
        self.api_key = self.settings.get("openweather_api_key", "f172988e58e4f3578106c053eec5ae7d")
        
        # MessageBus handler ekle
        self.bus.on("my_weather_skill:get_weather", self.handle_get_weather)
        self.bus.on("my_weather_skill:get_time", self.handle_get_time)

    @intent_handler("hava_durumu.intent")
    def handle_weather_intent(self, message: Message):
        city = message.data.get("city", "Istanbul")
        self.fetch_weather(city)

    @intent_handler("saat.intent")
    def handle_time_intent(self, message: Message):
        self.get_current_time()

    def handle_get_weather(self, message: Message):
        city = message.data.get("city", "Istanbul")
        self.fetch_weather(city)

    def handle_get_time(self, message: Message):
        self.get_current_time()

    def fetch_weather(self, city):
        url = "http://api.openweathermap.org/data/2.5/weather"
        params = {"q": city, "appid": self.api_key, "units": "metric", "lang": "tr"}
        try:
            data = requests.get(url, params=params, timeout=10).json()
        except Exception:
            self.speak("Hava durumu erişilemedi")
            return

        if data.get("main"):
            temp = data["main"]["temp"]
            desc = data.get("weather", [{}])[0].get("description", "")
            self.speak(f"{city} şehrinde hava {desc}, sıcaklık {temp}°C.")
        else:
            self.speak("Şehir bulunamadı.")

    def get_current_time(self):
        now = datetime.now().strftime("%H:%M:%S")
        self.speak(f"Şu an saat {now}")
