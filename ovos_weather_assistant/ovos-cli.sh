#!/bin/bash
# OVOS CLI - Shell Script Versiyonu
# Kullanım: ./ovos-cli.sh "hava durumu İstanbul"

# Renkli çıktı için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Container adı
CONTAINER_NAME="ovos-weather"

# Varsayılan parametreler
LANG="tr-tr"
WAIT_TIME=3

# Yardım fonksiyonu
show_help() {
    echo -e "${BLUE}🎤 OVOS CLI - Shell Script Versiyonu${NC}"
    echo "=================================="
    echo ""
    echo "Kullanım:"
    echo "  $0 \"komut\" [seçenekler]"
    echo ""
    echo "Örnekler:"
    echo "  $0 \"hava durumu İstanbul\""
    echo "  $0 \"saat kaç\""
    echo "  $0 \"what's the weather\" --lang en-us"
    echo "  $0 \"merhaba\" --wait 5"
    echo ""
    echo "Seçenekler:"
    echo "  --lang, -l    Dil kodu (varsayılan: tr-tr)"
    echo "  --wait, -w    Bekleme süresi saniye (varsayılan: 3)"
    echo "  --help, -h    Bu yardım mesajını göster"
    echo ""
}

# Parametreleri işle
UTTERANCE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --lang|-l)
            LANG="$2"
            shift 2
            ;;
        --wait|-w)
            WAIT_TIME="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            if [[ -z "$UTTERANCE" ]]; then
                UTTERANCE="$1"
            else
                echo -e "${RED}❌ Hata: Bilinmeyen parametre: $1${NC}"
                exit 1
            fi
            shift
            ;;
    esac
done

# Utterance kontrolü
if [[ -z "$UTTERANCE" ]]; then
    echo -e "${RED}❌ Hata: Komut belirtilmedi!${NC}"
    echo "Kullanım: $0 \"komut\""
    echo "Yardım için: $0 --help"
    exit 1
fi

echo -e "${BLUE}🎤 OVOS CLI - Shell Script${NC}"
echo "=============================="
echo ""

# Container'ın çalışıp çalışmadığını kontrol et
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Hata: '$CONTAINER_NAME' container'ı çalışmıyor!${NC}"
    echo "Container'ı başlatmak için:"
    echo "  docker start $CONTAINER_NAME"
    echo "Veya yeni container oluşturmak için:"
    echo "  docker run -d --name $CONTAINER_NAME your-image-name"
    exit 1
fi

echo -e "${GREEN}✅ Container '$CONTAINER_NAME' çalışıyor${NC}"
echo -e "${YELLOW}📤 Komut gönderiliyor: '$UTTERANCE'${NC}"

# Python script ile MessageBus'a komut gönder (virtual environment kullan)
docker exec -it "$CONTAINER_NAME" /app/ovos-core/.venv/bin/python -c "
import time
import threading
from ovos_bus_client import MessageBusClient, Message

responses = []
response_received = threading.Event()

def on_message(message):
    global responses, response_received
    try:
        if hasattr(message, 'msg_type'):
            msg_type = message.msg_type
            msg_data = getattr(message, 'data', {})
        else:
            import json
            try:
                msg_dict = json.loads(message)
                msg_type = msg_dict.get('type', 'unknown')
                msg_data = msg_dict.get('data', {})
            except:
                msg_type = 'unknown'
                msg_data = str(message)
        if msg_type == 'speak':
            utterance = msg_data.get('utterance', '')
            if utterance:
                print(utterance)
                response_received.set()
    except Exception:
        pass

bus = MessageBusClient()
bus.run_in_thread()

if not bus.connected_event.wait(5):
    print('❌ Hata: MessageBus\\'a bağlanılamadı!')
    exit(1)

bus.on('message', on_message)

# 81 il listesi (küçük harf)
cities = [
    'adana','adiyaman','afyonkarahisar','ağrı','amasya','ankara','antalya','artvin','aydın','balıkesir','bilecik','bingöl','bitlis','bolu','burdur','bursa','çanakkale','çankırı','çorum','denizli','diyarbakır','edirne','elazığ','erzincan','erzurum','eskişehir','gaziantep','giresun','gümüşhane','hakkari','hatay','ısparta','mersin','istanbul','izmir','kars','kastamonu','kayseri','kırklareli','kırşehir','kocaeli','konya','kütahya','malatya','manisa','kahramanmaraş','mardin','muğla','muş','nevşehir','niğde','ordu','rize','sakarya','samsun','siirt','sinop','sivas','tekirdağ','tokat','trabzon','tunceli','şanlıurfa','uşak','van','yozgat','zonguldak','aksaray','bayburt','karaman','kırıkkale','batman','şırnak','bartın','ardahan','ığdır','yalova','karabük','kilis','osmaniye','düzce'
]

utterance = '$UTTERANCE'.lower()

if 'hava' in utterance:
    city_found = None
    for city in cities:
        if city in utterance:
            city_found = city.capitalize()
            break
    if not city_found:
        city_found = 'İstanbul'  # varsayılan şehir
    weather_message = Message('my_weather_skill:get_weather', {'city': city_found})
    bus.emit(weather_message)
elif 'saat' in utterance:
    time_message = Message('my_weather_skill:get_time', {})
    bus.emit(time_message)

if not response_received.wait($WAIT_TIME):
    print('Yanıt alınamadı')
"

# Çıkış kodu kontrolü
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}🎉 İşlem tamamlandı!${NC}"
else
    echo -e "${RED}💥 İşlem başarısız!${NC}"
    exit 1
fi
