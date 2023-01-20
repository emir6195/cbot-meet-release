docker-compose exec prosody /bin/bash
prosodyctl --config /config/prosody.cfg.lua register emir6195 meet.jitsi Msal.550550
#to delete
#prosodyctl --config /config/prosody.cfg.lua unregister emir6195 meet.jitsi
find /config/data/meet%2ejitsi/accounts -type f -exec basename {} .dat \;