Users CRUD + Controlled Brute-Force (FastAPI)

Educational use only. All tests must be run only against this local API and with practice accounts created for the exercise.

Requirements

Python 3.10+

(Windows) Git Bash or WSL to run brute.sh

Setup
# In the project folder
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install --upgrade pip
py -m pip install -r requirements.txt

Run the API
py -m uvicorn main:app --reload


Swagger UI: http://127.0.0.1:8000/docs

ReDoc: http://127.0.0.1:8000/redoc

Note: The “database” is in-memory. If the server reloads (e.g., due to --reload), users are cleared and must be created again.

Endpoints

POST /users — create user (receives plain-text password)

GET /users — list users (passwords not returned)

GET /users/{id} — get user by id

PUT /users/{id} — update (everything except password)

DELETE /users/{id} — delete

POST /login — authenticate (returns only login successful or Invalid credentials)

Quick CRUD test (in /docs)

POST /users

{ "username": "demo", "password": "pass123", "email": "demo@mail.com", "is_active": true }


GET /users

GET /users/1

PUT /users/1

{ "email": "new@mail.com", "is_active": false }


(Conflict test) Also create admin, then try:

{ "username": "admin" }


on PUT /users/1 → should respond username ya existe (username already exists).

POST /login

{ "username": "demo", "password": "pass123" }

Controlled brute-force (bash)

File: brute.sh (included). Run in Git Bash while the API is running:

chmod +x brute.sh
./brute.sh


By default it attacks USER="demo" using a short internal wordlist.
You can switch the user or read from a file:

Create wordlist.txt:

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


(Optional) Adjust brute.sh to read wordlist.txt:

while IFS= read -r pwd; do
  # ... POST with curl ...
done < wordlist.txt


Keep a small delay (e.g., sleep 0.2) to make it controlled and avoid overwhelming the local API.

What to report (example)

Target user: admin

Wordlist size: 12

Delay between attempts: 0.2 s

Result: found secret in 6 attempts, ~2 s

Conclusion: weak/common passwords are cracked very quickly.

Mitigations (mention in your write-up)

Rate limiting per IP/username

Backoff after failed attempts (growing delays)

Strong password policy (length/entropy)

Password hashing (e.g., bcrypt) instead of plain text

CAPTCHA / MFA to slow automation

Project structure
first-term-exam/
├─ main.py           # FastAPI (CRUD + login), in-memory "DB"
├─ brute.sh          # Bash brute-force script (controlled, uses curl)
├─ requirements.txt  # Dependencies
└─ README.md

(Optional) .gitignore

If you want one, add a .gitignore with:

.venv/
__pycache__/
*.pyc
*.log
.DS_Store
Thumbs.db
