#!/bin/bash
# OVOS ortamını aktive et

source /app/ovos-core/.venv/bin/activate

if command -v ovos-messagebus >/dev/null 2>%1; then 
    ovos-messagebus --host 0.0.0.0 &
else 
    python -m ovos_messagebus.service &
fi

sleep 5

echo "Skills dir: ${OVOS_SKILLS_DIR:-$MYCROFT_SKILLS_DIR}"
ls -la ${OVOS_SKILLS_DIR:-$MYCROFT_SKILLS_DIR}
echo "mycroft.conf:"
cat /root/.config/mycroft/mycroft.conf || true 

python -m ovos_core

tail -f /dev/null

