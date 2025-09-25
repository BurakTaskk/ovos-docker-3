# OVOS Weather Assistant - Terminal CLI

Bu proje, OVOS (Open Voice Operating System) kullanarak terminal'den hava durumu ve saat bilgisi almanızı sağlayan bir Docker tabanlı CLI aracıdır.

## Özellikler

- **Terminal'den OVOS komutları** - Shell script ile kolay kullanım
- **Hava durumu sorgusu** - Gerçek zamanlı hava durumu bilgisi
- **Saat sorgusu** - Mevcut saat bilgisi
- **Docker tabanlı** - Kolay kurulum ve çalıştırma
- **Türkçe dil desteği** - Türkçe komutlar ile sorgu



## Nasıl Çalışır?



### 1. MessageBus Event Sistemi

OVOS, skill'ler arası iletişim için MessageBus kullanır:

```python
# Event gönderme
message = Message('my_weather_skill:get_weather', {'city': 'İstanbul'})
bus.emit(message)

# Event dinleme
def handle_get_weather(self, message):
    city = message.data.get('city', 'İstanbul')
    # Hava durumu işleme...
```

### 2. Skill Yapısı

```python
class WeatherSkill(OVOSSkill):
    def __init__(self, bus=None, skill_id=''):
        super().__init__(bus=bus, skill_id=skill_id)
        
        # MessageBus handler'ları
        self.bus.on("my_weather_skill:get_weather", self.handle_get_weather)
        self.bus.on("my_weather_skill:get_time", self.handle_get_time)
    
    def handle_get_weather(self, message):
        # Hava durumu işleme
        pass
```

## Kurulum ve Kullanım

### Gereksinimler

- Docker
- WSL (Windows için)
- Linux/macOS terminal

### Kurulum

1. **Repository'yi klonlayın:**
```bash
git clone <repository-url>
cd ovos_weather_assistant
```

2. **Docker image'ını build edin:**
```bash
docker build --no-cache -t ovos_weather .
```

3. **Container'ı çalıştırın:**
```bash
docker run -it -p 8181:8181 <docker-name>
```

4. **2-3 dakika bekleyin** (OVOS'un başlaması için)

### Kullanım

```bash
# Hava durumu sorguları
./ovos-cli.sh "hava durumu İstanbul"
./ovos-cli.sh "hava durumu Ankara"
./ovos-cli.sh "hava durumu İzmir"

# Saat sorgusu
./ovos-cli.sh "saat kaç"

# Yardım
./ovos-cli.sh --help
```

### Örnek Çıktılar

```bash
$ ./ovos-cli.sh "hava durumu İstanbul"
İstanbul şehrinde hava az bulutlu, sıcaklık 24.31°C.

$ ./ovos-cli.sh "saat kaç"
Şu an saat 15:30:45
```

## Teknik Detaylar

### Shell Script İşleyişi

1. **Parametre kontrolü** - Komut ve seçenekleri parse eder
2. **Container kontrolü** - Docker container'ın çalışıp çalışmadığını kontrol eder
3. **Python script çalıştırma** - Container içinde Python kodu çalıştırır
4. **MessageBus bağlantısı** - OVOS MessageBus'a bağlanır
5. **Event gönderme** - Skill'e uygun event'i gönderir
6. **Yanıt dinleme** - Skill'in yanıtını bekler ve gösterir

### Docker Container Yapısı

```dockerfile
FROM python:3.12-slim

# OVOS Core kurulumu
RUN git clone https://github.com/OpenVoiceOS/ovos-core.git
WORKDIR /app/ovos-core
RUN python3 -m venv .venv
RUN /app/ovos-core/.venv/bin/pip install -r requirements/requirements.txt

# Skill kurulumu
COPY skills/my_weather_skill /root/.local/share/mycroft/skills/my_weather_skill.skill/
RUN /app/ovos-core/.venv/bin/pip install /root/.local/share/mycroft/skills/my_weather_skill.skill

# OVOS başlatma
CMD ["bash", "start.sh"]
```

### API Entegrasyonu

OpenWeatherMap API kullanılır:
- **Endpoint:** `http://api.openweathermap.org/data/2.5/weather`
- **Parametreler:** `q` (şehir), `appid` (API key), `units` (metric), `lang` (tr)
- **Yanıt:** JSON formatında hava durumu verisi


### Debug Modu

Debug mesajlarını görmek için shell script'i düzenleyin:
```python
# Debug mesajlarını etkinleştir
print(f'🔍 Mesaj alındı: {msg_type} - {msg_data}')
```

## Sorun Giderme

### Container Başlamıyor
```bash
# Container loglarını kontrol edin
docker logs ovos-weather

# Container'ı yeniden başlatın
docker restart ovos-weather
```

### Skill Yanıt Vermiyor
```bash
# Container içinde skill'leri kontrol edin
docker exec -it ovos-weather ls -la /root/.local/share/mycroft/skills/

# OVOS loglarını kontrol edin
docker exec -it ovos-weather tail -f /var/log/ovos.log
```

### API Hatası
- Internet bağlantısını kontrol edin
- OpenWeatherMap API key'inin geçerli olduğundan emin olun
- Container'ın `--network host` ile çalıştığından emin ol


## Kaynak

- [OVOS Community](https://github.com/OpenVoiceOS) - Açık kaynak sesli asistan

- [OpenWeatherMap](https://openweathermap.org/) - Hava durumu API

