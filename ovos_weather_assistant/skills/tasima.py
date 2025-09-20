import shutil
import os

kaynak = os.path.expanduser('/home/kaan_/ovos-docker/ovos_weather_assistant/skills/setup.py')
hedef_dizin = os.path.expanduser('ovos-docker/ovos_weather_assistant/skills/my_weather_skill/')

os.makedirs(hedef_dizin, exist_ok=True)

yeni_yol = shutil.move(kaynak, hedef_dizin)

print(f"Dosya taşındı: {yeni_yol}")
