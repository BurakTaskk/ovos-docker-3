# OVOS CLI - Shell Script Kullanım Kılavuzu

Bu kılavuz, Docker ve WSL ortamında OVOS CLI shell script'ini nasıl kullanacağınızı açıklar.

## 🐳 Docker ile Kullanım

### 1. Container'ı Başlatın
```bash
# Container'ı arka planda çalıştırın
docker run -d --name ovos-weather your-image-name

# Veya port mapping ile
docker run -d --name ovos-weather -p 8181:8181 your-image-name
```

### 2. CLI Aracını Kullanın

#### Yöntem 1: Shell Script ile (Önerilen)
```bash
# WSL terminalinde shell script'i çalıştırın
./ovos-cli.sh "hava durumu İstanbul"

# Farklı dil ile
./ovos-cli.sh "what's the weather" --lang en-us

# Daha uzun bekleme süresi ile
./ovos-cli.sh "saat kaç" --wait 5
```

#### Yöntem 2: Docker exec ile
```bash
# Container içinde shell script'i çalıştırın
docker exec -it ovos-weather /app/ovos-cli.sh "hava durumu İstanbul"
```

## 🐧 WSL ile Kullanım

### 1. WSL'de Docker'ı Başlatın
```bash
# WSL terminalinde
cd /mnt/c/Users/kaan_/OneDrive/Masaüstü/ovos-docker/ovos_weather_assistant

# Docker image'ını build edin
docker build -t ovos-weather .

# Container'ı çalıştırın
docker run -d --name ovos-weather ovos-weather
```

### 2. CLI Komutları
```bash
# Script'i çalıştırılabilir yapın
chmod +x ovos-cli.sh

# Hava durumu sorgusu
./ovos-cli.sh "hava durumu İstanbul"

# Saat sorgusu
./ovos-cli.sh "saat kaç"

# İngilizce komut
./ovos-cli.sh "what time is it" --lang en-us
```

## 📋 Kullanılabilir Parametreler

- `utterance`: Gönderilecek komut (zorunlu)
- `--lang, -l`: Dil kodu (varsayılan: tr-tr)
- `--wait, -w`: Yanıt bekleme süresi saniye (varsayılan: 3)
- `--version, -v`: Versiyon bilgisi

## 🔧 Örnek Kullanımlar

```bash
# Temel kullanım
./ovos-cli.sh "hava durumu"

# Farklı şehir
./ovos-cli.sh "hava durumu Ankara"

# İngilizce
./ovos-cli.sh "weather in London" --lang en-us

# Uzun bekleme süresi
./ovos-cli.sh "kompleks işlem" --wait 10

# Yardım
./ovos-cli.sh --help
```

## 🚀 Hızlı Başlangıç Scripti

WSL'de kullanımı kolaylaştırmak için bir alias oluşturabilirsiniz:

```bash
# ~/.bashrc dosyasına ekleyin
alias ovos="./ovos-cli.sh"

# Kullanım
ovos "hava durumu İstanbul"
ovos "saat kaç"
ovos "what's the weather" --lang en-us
```

## 🐛 Sorun Giderme

### Container çalışmıyor
```bash
# Container durumunu kontrol edin
docker ps -a

# Logları kontrol edin
docker logs ovos-weather

# Container'ı yeniden başlatın
docker restart ovos-weather
```

### CLI aracı çalışmıyor
```bash
# Script'in çalıştırılabilir olduğunu kontrol edin
ls -la ovos-cli.sh

# Script'i çalıştırılabilir yapın
chmod +x ovos-cli.sh

# OVOS servisinin çalıştığını kontrol edin
docker exec -it ovos-weather ps aux | grep ovos
```

### Skill yanıt vermiyor
- Container'ın tam olarak başladığından emin olun (2-3 dakika bekleyin)
- `--wait` parametresini artırın
- Skill'in doğru yüklendiğini kontrol edin

## 📝 Notlar

- İlk başlatmada container'ın tam olarak hazır olması 2-3 dakika sürebilir
- Shell script MessageBus üzerinden çalışır, bu yüzden OVOS servisinin çalışıyor olması gerekir
- Script'i çalıştırmadan önce `chmod +x ovos-cli.sh` yapmayı unutmayın
- Container'ı durdurmak için: `docker stop ovos-weather`
- Container'ı silmek için: `docker rm ovos-weather`
