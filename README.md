<!-- START README -->

# Users CRUD + Controlled Brute-Force (FastAPI)

> **Educational use only.** All tests must be run **only** against this **local** API and with **practice accounts** created for the exercise.

## Requirements
- Python 3.10+
- (Windows) Git Bash or WSL to run `brute.sh`

## Setup

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
- ReDoc:       http://127.0.0.1:8000/redoc

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
    List all users.
**3) GET /users/{id} (e.g., {id} = 1)**
    Get a single user by id.

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
It iterates over a small wordlist, sends a POST to `/login` for each guess, and **stops on the first success**.  
You can safely tweak:
- `API` → URL of your local server (change port if needed)
- `USER` → the username to test (e.g., `demo`, `admin`, `leo`)
- `WORDLIST` → the candidate passwords you want to try
- `sleep 0.2` → delay between attempts to keep the test controlled

```bash
# brute.sh — controlled brute-force demo
# How it works:
# 1) Reads candidate passwords from WORDLIST (array below).
# 2) For each candidate, sends POST /login to your local API.
# 3) If the response contains "login successful", it prints the finding and exits.
# Safety:
# - Small, fixed delay between attempts (sleep 0.2) to avoid overwhelming the API.
# - Intended ONLY for your local practice API and accounts created for this exercise.
# You can change:
# - API:  if your server runs on a different host/port.
# - USER: which username to test (demo/admin/leo/...).
# - WORDLIST: add/remove candidate passwords.

#!/usr/bin/env bash
API="http://127.0.0.1:8000/login"
USER="leo"   # change to 'demo' or 'admin' if you want

WORDLIST=(pass123 123456 admin admin123 demo secret qwerty password adios) #Add here the weak passwords

attempts=0
start=$(date +%s)

for pwd in "${WORDLIST[@]}"; do
  attempts=$((attempts+1))
  resp=$(curl -s -X POST "$API" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$USER\",\"password\":\"$pwd\"}")
  echo "[$attempts] Trying '$pwd' -> $resp"
  if [[ "$resp" == *"login successful"* ]]; then
    end=$(date +%s)
    echo "FOUND: password='$pwd' in $attempts attempts, $((end-start))s"
    exit 0
  fi
  sleep 0.2
done

end=$(date +%s)
echo "NOT found after $attempts attempts in $((end-start))s"
exit 1

```
> Keep a small delay (e.g., `sleep 0.2`) so the test is **controlled** and you don’t overwhelm the local API.

### What to report (example)
- Target user: `admin`  
- Wordlist size: 12  
- Delay between attempts: 0.2 s  
- **Result**: found `secret` in 6 attempts, ~2 s  
- Conclusion: weak/common passwords are cracked very quickly.

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
