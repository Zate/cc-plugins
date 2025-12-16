---
name: remediation-library
description: Security fix patterns and remediation guidance for common vulnerabilities. Provides language-specific code examples showing both vulnerable and secure implementations, aligned with OWASP and ASVS requirements.
---

# Remediation Library

Actionable fix patterns for security vulnerabilities, organized by category with language-specific examples.

## When to Use This Skill

- **Generating fix suggestions** - After finding vulnerabilities in audits
- **Writing secure code** - Reference patterns for secure implementations
- **Code review feedback** - Provide remediation guidance with examples
- **Security training** - Show do/don't patterns for education

## When NOT to Use This Skill

- **Detecting vulnerabilities** - Use vulnerability-patterns skill
- **ASVS compliance mapping** - Use asvs-requirements skill
- **Full security audits** - Use domain auditor agents

---

## Remediation Categories

| Category | CWE | OWASP | Priority |
|----------|-----|-------|----------|
| Injection | CWE-89, CWE-78, CWE-79 | A03 | Critical |
| Authentication | CWE-287, CWE-798 | A07 | Critical |
| Cryptography | CWE-327, CWE-328, CWE-330 | A02 | High |
| Access Control | CWE-284, CWE-862 | A01 | Critical |
| Data Protection | CWE-311, CWE-312 | A02 | High |
| Configuration | CWE-16, CWE-489 | A05 | High |

---

## SQL Injection (CWE-89)

### Problem
User input directly concatenated into SQL queries allows attackers to manipulate database queries.

### Python (SQLAlchemy/psycopg2)

**Don't**:
```python
# VULNERABLE: String concatenation
def get_user_bad(user_id):
    query = f"SELECT * FROM users WHERE id = '{user_id}'"
    cursor.execute(query)
    return cursor.fetchone()

# VULNERABLE: Format strings
query = "SELECT * FROM users WHERE name = '%s'" % username
```

**Do**:
```python
# SECURE: Parameterized queries with psycopg2
def get_user_safe(user_id):
    query = "SELECT * FROM users WHERE id = %s"
    cursor.execute(query, (user_id,))
    return cursor.fetchone()

# SECURE: SQLAlchemy ORM
def get_user_orm(user_id):
    return db.session.query(User).filter(User.id == user_id).first()

# SECURE: SQLAlchemy with text() and bindparams
from sqlalchemy import text
query = text("SELECT * FROM users WHERE id = :user_id")
result = db.session.execute(query, {"user_id": user_id})
```

### JavaScript/TypeScript (Node.js)

**Don't**:
```javascript
// VULNERABLE: String concatenation
const query = `SELECT * FROM users WHERE id = '${userId}'`;
db.query(query);

// VULNERABLE: Template literals
const sql = `SELECT * FROM products WHERE name LIKE '%${searchTerm}%'`;
```

**Do**:
```javascript
// SECURE: Parameterized queries (mysql2)
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);

// SECURE: Parameterized with named placeholders (pg)
const query = 'SELECT * FROM users WHERE id = $1';
await client.query(query, [userId]);

// SECURE: Prisma ORM
const user = await prisma.user.findUnique({
  where: { id: userId }
});

// SECURE: Knex.js query builder
const user = await knex('users').where('id', userId).first();
```

### Java (JDBC)

**Don't**:
```java
// VULNERABLE: String concatenation
String query = "SELECT * FROM users WHERE id = '" + userId + "'";
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(query);
```

**Do**:
```java
// SECURE: PreparedStatement
String query = "SELECT * FROM users WHERE id = ?";
PreparedStatement pstmt = conn.prepareStatement(query);
pstmt.setString(1, userId);
ResultSet rs = pstmt.executeQuery();

// SECURE: JPA/Hibernate with named parameters
@Query("SELECT u FROM User u WHERE u.id = :userId")
User findByUserId(@Param("userId") String userId);
```

### Go

**Don't**:
```go
// VULNERABLE: fmt.Sprintf in queries
query := fmt.Sprintf("SELECT * FROM users WHERE id = '%s'", userID)
rows, err := db.Query(query)
```

**Do**:
```go
// SECURE: Parameterized queries
query := "SELECT * FROM users WHERE id = $1"
rows, err := db.Query(query, userID)

// SECURE: With sqlx
var user User
err := db.Get(&user, "SELECT * FROM users WHERE id = $1", userID)
```

**ASVS**: V1.2.1, V1.2.2
**References**: [OWASP SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)

---

## Command Injection (CWE-78)

### Problem
User input passed to shell commands allows attackers to execute arbitrary system commands.

### Python

**Don't**:
```python
# VULNERABLE: shell=True with user input
import subprocess
subprocess.run(f"grep {pattern} {filename}", shell=True)

# VULNERABLE: os.system
import os
os.system(f"convert {input_file} {output_file}")
```

**Do**:
```python
# SECURE: subprocess with argument list (no shell)
import subprocess
import shlex

result = subprocess.run(
    ['grep', pattern, filename],
    capture_output=True,
    text=True
)

# SECURE: If shell is required, use shlex.quote
if shell_required:
    safe_filename = shlex.quote(filename)
    subprocess.run(f"process {safe_filename}", shell=True)

# SECURE: Use libraries instead of shell commands
from PIL import Image
img = Image.open(input_file)
img.save(output_file)
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: exec with user input
const { exec } = require('child_process');
exec(`grep ${pattern} ${filename}`);

// VULNERABLE: String interpolation in shell command
exec(`convert ${inputFile} ${outputFile}`);
```

**Do**:
```javascript
// SECURE: execFile with argument array
const { execFile } = require('child_process');
execFile('grep', [pattern, filename], (error, stdout) => {
  console.log(stdout);
});

// SECURE: spawn with arguments
const { spawn } = require('child_process');
const grep = spawn('grep', [pattern, filename]);

// SECURE: Use libraries instead of shell commands
const sharp = require('sharp');
await sharp(inputFile).toFile(outputFile);
```

### Java

**Don't**:
```java
// VULNERABLE: Runtime.exec with concatenation
String cmd = "grep " + pattern + " " + filename;
Runtime.getRuntime().exec(cmd);
```

**Do**:
```java
// SECURE: ProcessBuilder with argument list
ProcessBuilder pb = new ProcessBuilder("grep", pattern, filename);
pb.redirectErrorStream(true);
Process process = pb.start();
```

**ASVS**: V1.2.3
**References**: [OWASP OS Command Injection](https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html)

---

## Cross-Site Scripting (XSS) (CWE-79)

### Problem
User input rendered in HTML without proper encoding allows script injection.

### JavaScript (DOM)

**Don't**:
```javascript
// VULNERABLE: innerHTML with user input
element.innerHTML = userInput;

// VULNERABLE: document.write
document.write(userData);

// VULNERABLE: jQuery html()
$('#content').html(userInput);
```

**Do**:
```javascript
// SECURE: textContent for plain text
element.textContent = userInput;

// SECURE: DOMPurify for HTML content
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userHtml);

// SECURE: Create elements programmatically
const link = document.createElement('a');
link.href = sanitizeUrl(userUrl);
link.textContent = userText;
parent.appendChild(link);

// SECURE: jQuery text()
$('#content').text(userInput);
```

### React

**Don't**:
```jsx
// VULNERABLE: dangerouslySetInnerHTML without sanitization
function Comment({ content }) {
  return <div dangerouslySetInnerHTML={{ __html: content }} />;
}

// VULNERABLE: href with user input (javascript: URLs)
<a href={userUrl}>Click here</a>
```

**Do**:
```jsx
// SECURE: React auto-escapes by default
function Comment({ content }) {
  return <div>{content}</div>;
}

// SECURE: Sanitize if HTML is required
import DOMPurify from 'dompurify';
function RichContent({ html }) {
  const clean = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: clean }} />;
}

// SECURE: Validate URLs
function SafeLink({ url, text }) {
  const isValid = /^https?:\/\//.test(url);
  if (!isValid) return <span>{text}</span>;
  return <a href={url}>{text}</a>;
}
```

### Python (Flask/Jinja2)

**Don't**:
```python
# VULNERABLE: Marking as safe without sanitization
from markupsafe import Markup
return Markup(f"<div>{user_input}</div>")

# VULNERABLE: Disabling autoescaping
{% autoescape false %}
  {{ user_content }}
{% endautoescape %}
```

**Do**:
```python
# SECURE: Let Jinja2 auto-escape (default)
return render_template('page.html', content=user_input)

# Template: auto-escaped by default
<div>{{ content }}</div>

# SECURE: Use bleach for allowing specific HTML
import bleach
allowed_tags = ['b', 'i', 'u', 'a']
allowed_attrs = {'a': ['href']}
clean = bleach.clean(user_html, tags=allowed_tags, attributes=allowed_attrs)
```

**ASVS**: V3.3.1, V1.3.1
**References**: [OWASP XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)

---

## Insecure Deserialization (CWE-502)

### Problem
Deserializing untrusted data can lead to remote code execution.

### Python

**Don't**:
```python
# VULNERABLE: pickle with untrusted data
import pickle
data = pickle.loads(user_input)

# VULNERABLE: yaml.load without SafeLoader
import yaml
data = yaml.load(user_input, Loader=yaml.Loader)
```

**Do**:
```python
# SECURE: JSON for untrusted data
import json
data = json.loads(user_input)

# SECURE: yaml.safe_load
import yaml
data = yaml.safe_load(user_input)

# SECURE: If pickle is required, use hmac signing
import pickle
import hmac
import hashlib

def secure_loads(data, key):
    signature, payload = data[:64], data[64:]
    expected = hmac.new(key, payload, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(signature, expected):
        raise ValueError("Invalid signature")
    return pickle.loads(payload)
```

### Java

**Don't**:
```java
// VULNERABLE: ObjectInputStream with untrusted data
ObjectInputStream ois = new ObjectInputStream(inputStream);
Object obj = ois.readObject();
```

**Do**:
```java
// SECURE: Use JSON instead
ObjectMapper mapper = new ObjectMapper();
MyClass obj = mapper.readValue(jsonString, MyClass.class);

// SECURE: If Java serialization required, use allowlist
ObjectInputFilter filter = ObjectInputFilter.Config.createFilter(
    "com.myapp.*;java.util.*;!*"
);
ObjectInputStream ois = new ObjectInputStream(inputStream);
ois.setObjectInputFilter(filter);
```

**ASVS**: V1.5.1, V1.5.2
**References**: [OWASP Deserialization](https://cheatsheetseries.owasp.org/cheatsheets/Deserialization_Cheat_Sheet.html)

---

## Weak Cryptography (CWE-327)

### Problem
Using deprecated algorithms (MD5, SHA1, DES) or insecure modes (ECB) compromises data protection.

### Python

**Don't**:
```python
# VULNERABLE: MD5/SHA1 for security purposes
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()

# VULNERABLE: DES encryption
from Crypto.Cipher import DES
cipher = DES.new(key, DES.MODE_ECB)
```

**Do**:
```python
# SECURE: bcrypt for password hashing
import bcrypt
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

# SECURE: argon2 (preferred)
from argon2 import PasswordHasher
ph = PasswordHasher()
hashed = ph.hash(password)

# SECURE: SHA-256+ for data integrity
import hashlib
file_hash = hashlib.sha256(data).hexdigest()

# SECURE: AES-GCM for encryption
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
key = AESGCM.generate_key(bit_length=256)
aesgcm = AESGCM(key)
nonce = os.urandom(12)
ciphertext = aesgcm.encrypt(nonce, plaintext, associated_data)
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: MD5/SHA1
const crypto = require('crypto');
const hash = crypto.createHash('md5').update(data).digest('hex');

// VULNERABLE: Weak password hashing
const hash = crypto.createHash('sha256').update(password).digest('hex');
```

**Do**:
```javascript
// SECURE: bcrypt for passwords
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash(password, 12);

// SECURE: argon2 (preferred)
const argon2 = require('argon2');
const hash = await argon2.hash(password);

// SECURE: SHA-256 for data integrity
const crypto = require('crypto');
const hash = crypto.createHash('sha256').update(data).digest('hex');

// SECURE: AES-GCM for encryption
const algorithm = 'aes-256-gcm';
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);
const cipher = crypto.createCipheriv(algorithm, key, iv);
```

### Java

**Don't**:
```java
// VULNERABLE: MD5/SHA1
MessageDigest md = MessageDigest.getInstance("MD5");
byte[] hash = md.digest(data);

// VULNERABLE: DES/ECB
Cipher cipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
```

**Do**:
```java
// SECURE: BCrypt for passwords
import org.mindrot.jbcrypt.BCrypt;
String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));

// SECURE: SHA-256 for integrity
MessageDigest md = MessageDigest.getInstance("SHA-256");
byte[] hash = md.digest(data);

// SECURE: AES-GCM for encryption
Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
SecretKeySpec keySpec = new SecretKeySpec(key, "AES");
GCMParameterSpec gcmSpec = new GCMParameterSpec(128, iv);
cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec);
```

**ASVS**: V11.4.1, V11.5.1, V11.5.2
**References**: [OWASP Cryptographic Storage](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)

---

## Insecure Randomness (CWE-330)

### Problem
Using predictable random number generators for security-sensitive values allows attackers to predict tokens.

### Python

**Don't**:
```python
# VULNERABLE: random module for security
import random
token = ''.join(random.choices('abcdef0123456789', k=32))
session_id = random.randint(0, 999999)
```

**Do**:
```python
# SECURE: secrets module
import secrets
token = secrets.token_urlsafe(32)
api_key = secrets.token_hex(32)
otp = ''.join(secrets.choice('0123456789') for _ in range(6))

# SECURE: os.urandom for raw bytes
import os
random_bytes = os.urandom(32)
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: Math.random()
const token = Math.random().toString(36).substring(2);
const sessionId = Math.floor(Math.random() * 1000000);
```

**Do**:
```javascript
// SECURE: crypto.randomBytes (Node.js)
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
const sessionId = crypto.randomUUID();

// SECURE: Web Crypto API (Browser)
const buffer = new Uint8Array(32);
crypto.getRandomValues(buffer);
const token = Array.from(buffer, b => b.toString(16).padStart(2, '0')).join('');
```

### Java

**Don't**:
```java
// VULNERABLE: java.util.Random
Random rand = new Random();
int token = rand.nextInt();
```

**Do**:
```java
// SECURE: SecureRandom
SecureRandom random = new SecureRandom();
byte[] bytes = new byte[32];
random.nextBytes(bytes);

// SECURE: Generate random string
String token = new BigInteger(256, random).toString(16);
```

**ASVS**: V11.3.1
**References**: [OWASP Secure Random](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html#secure-random-number-generation)

---

## Hardcoded Credentials (CWE-798)

### Problem
Credentials in source code are exposed in version control and can be extracted from compiled code.

### All Languages

**Don't**:
```python
# VULNERABLE: Hardcoded credentials
API_KEY = "sk-1234567890abcdef"
DB_PASSWORD = "admin123"
JWT_SECRET = "mysupersecretkey"
```

**Do**:
```python
# SECURE: Environment variables
import os
API_KEY = os.environ.get('API_KEY')
DB_PASSWORD = os.environ.get('DB_PASSWORD')

# SECURE: Configuration file (not in git)
import configparser
config = configparser.ConfigParser()
config.read('/etc/myapp/secrets.ini')
api_key = config['api']['key']

# SECURE: Secret manager (AWS Secrets Manager)
import boto3
client = boto3.client('secretsmanager')
response = client.get_secret_value(SecretId='myapp/api-key')
api_key = response['SecretString']

# SECURE: Vault
import hvac
client = hvac.Client(url='https://vault.example.com')
secret = client.secrets.kv.read_secret_version(path='myapp/api-key')
api_key = secret['data']['data']['value']
```

### Configuration Files

**Don't**:
```yaml
# VULNERABLE: .env committed to git
# .env
DATABASE_URL=postgres://admin:password123@localhost/db
API_SECRET=sk-live-abcdef123456

# VULNERABLE: docker-compose.yml with secrets
environment:
  - DB_PASSWORD=admin123
```

**Do**:
```yaml
# SECURE: .env.example (template, no real values)
# .env.example
DATABASE_URL=postgres://user:password@host/database
API_SECRET=your-api-secret-here

# SECURE: docker-compose with external secrets
environment:
  - DB_PASSWORD_FILE=/run/secrets/db_password
secrets:
  db_password:
    external: true

# SECURE: Use secret references
environment:
  - DB_PASSWORD=${DB_PASSWORD}  # Set at runtime
```

**ASVS**: V13.3.1, V13.3.2
**References**: [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

## Path Traversal (CWE-22)

### Problem
User-controlled file paths can escape intended directories to access sensitive files.

### Python

**Don't**:
```python
# VULNERABLE: Direct path concatenation
def get_file(filename):
    return open(f'/app/uploads/{filename}').read()

# VULNERABLE: No validation
path = os.path.join(base_dir, user_filename)
```

**Do**:
```python
# SECURE: Validate path is within allowed directory
from pathlib import Path

UPLOAD_DIR = Path('/app/uploads').resolve()

def safe_file_access(filename: str) -> Path:
    # Resolve to absolute path
    requested = (UPLOAD_DIR / filename).resolve()

    # Verify it's within allowed directory
    if not requested.is_relative_to(UPLOAD_DIR):
        raise ValueError("Path traversal attempt detected")

    return requested

# SECURE: Alternative with os.path
def safe_file_access_os(filename):
    base = os.path.abspath(UPLOAD_DIR)
    requested = os.path.abspath(os.path.join(UPLOAD_DIR, filename))

    if not requested.startswith(base + os.sep):
        raise ValueError("Path traversal attempt detected")

    return requested
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: Direct path join
const filepath = path.join(uploadDir, userFilename);
fs.readFile(filepath);
```

**Do**:
```javascript
// SECURE: Validate path is within directory
const path = require('path');
const fs = require('fs');

const UPLOAD_DIR = path.resolve('/app/uploads');

function safeFilePath(filename) {
  const requested = path.resolve(UPLOAD_DIR, filename);

  if (!requested.startsWith(UPLOAD_DIR + path.sep)) {
    throw new Error('Path traversal attempt detected');
  }

  return requested;
}
```

**ASVS**: V5.4.1
**References**: [OWASP Path Traversal](https://owasp.org/www-community/attacks/Path_Traversal)

---

## TLS Certificate Validation (CWE-295)

### Problem
Disabling TLS certificate validation allows man-in-the-middle attacks.

### Python

**Don't**:
```python
# VULNERABLE: Disabled verification
import requests
response = requests.get(url, verify=False)

# VULNERABLE: Environment variable
os.environ['REQUESTS_CA_BUNDLE'] = ''
```

**Do**:
```python
# SECURE: Default verification (enabled)
import requests
response = requests.get(url)  # verify=True by default

# SECURE: Custom CA bundle
response = requests.get(url, verify='/path/to/ca-bundle.crt')

# SECURE: Certificate pinning
import ssl
import socket

def verify_certificate(host, expected_fingerprint):
    context = ssl.create_default_context()
    with socket.create_connection((host, 443)) as sock:
        with context.wrap_socket(sock, server_hostname=host) as ssock:
            cert = ssock.getpeercert(binary_form=True)
            fingerprint = hashlib.sha256(cert).hexdigest()
            if fingerprint != expected_fingerprint:
                raise ssl.SSLError("Certificate fingerprint mismatch")
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: Disabled verification
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

// VULNERABLE: rejectUnauthorized false
const https = require('https');
https.get(url, { rejectUnauthorized: false });
```

**Do**:
```javascript
// SECURE: Default verification
const https = require('https');
https.get(url);  // Verification enabled by default

// SECURE: Custom CA
const fs = require('fs');
const https = require('https');

const agent = new https.Agent({
  ca: fs.readFileSync('/path/to/ca.crt')
});
https.get(url, { agent });
```

### Go

**Don't**:
```go
// VULNERABLE: Skip verification
client := &http.Client{
    Transport: &http.Transport{
        TLSClientConfig: &tls.Config{
            InsecureSkipVerify: true,
        },
    },
}
```

**Do**:
```go
// SECURE: Default client (verification enabled)
client := &http.Client{}
resp, err := client.Get(url)

// SECURE: Custom CA pool
caCert, _ := ioutil.ReadFile("/path/to/ca.crt")
caCertPool := x509.NewCertPool()
caCertPool.AppendCertsFromPEM(caCert)

client := &http.Client{
    Transport: &http.Transport{
        TLSClientConfig: &tls.Config{
            RootCAs: caCertPool,
        },
    },
}
```

**ASVS**: V12.3.1
**References**: [OWASP TLS Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html)

---

## Debug Mode in Production (CWE-489)

### Problem
Debug mode exposes sensitive information and may enable additional attack vectors.

### Python (Flask/Django)

**Don't**:
```python
# VULNERABLE: Debug in production
app.run(debug=True)

# VULNERABLE: Django DEBUG
# settings.py
DEBUG = True

# VULNERABLE: Verbose errors
@app.errorhandler(Exception)
def handle_error(e):
    return str(e), 500
```

**Do**:
```python
# SECURE: Environment-based configuration
import os

DEBUG = os.environ.get('FLASK_DEBUG', 'false').lower() == 'true'
app.run(debug=DEBUG)

# SECURE: Django settings
DEBUG = os.environ.get('DJANGO_DEBUG', 'False') == 'True'

# SECURE: Generic error messages
@app.errorhandler(Exception)
def handle_error(e):
    app.logger.error(f"Error: {e}")  # Log details
    return {"error": "Internal server error"}, 500  # Generic response
```

### JavaScript (Express)

**Don't**:
```javascript
// VULNERABLE: Stack traces exposed
app.use((err, req, res, next) => {
  res.status(500).send(err.stack);
});

// VULNERABLE: NODE_ENV not set
// No environment check
```

**Do**:
```javascript
// SECURE: Environment-aware error handling
app.use((err, req, res, next) => {
  console.error(err);  // Log full error

  if (process.env.NODE_ENV === 'production') {
    res.status(500).json({ error: 'Internal server error' });
  } else {
    res.status(500).json({ error: err.message, stack: err.stack });
  }
});
```

**ASVS**: V13.2.1, V16.4.1
**References**: [OWASP Error Handling](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html)

---

## JWT Security (CWE-347)

### Problem
Weak JWT configuration allows token forgery or manipulation.

### All Languages

**Don't**:
```javascript
// VULNERABLE: "none" algorithm accepted
const decoded = jwt.verify(token, secret);  // May accept alg: "none"

// VULNERABLE: Weak secret
const token = jwt.sign(payload, 'secret');

// VULNERABLE: HS256 with RSA public key
const decoded = jwt.verify(token, publicKey);  // Algorithm confusion
```

**Do**:
```javascript
// SECURE: Explicit algorithm specification
const jwt = require('jsonwebtoken');

// Signing
const token = jwt.sign(payload, privateKey, {
  algorithm: 'RS256',
  expiresIn: '1h',
  issuer: 'myapp',
  audience: 'myapp-users'
});

// Verification with explicit options
const decoded = jwt.verify(token, publicKey, {
  algorithms: ['RS256'],  // Explicitly allow only RS256
  issuer: 'myapp',
  audience: 'myapp-users'
});

// SECURE: Strong symmetric key (if using HS256)
const crypto = require('crypto');
const secret = crypto.randomBytes(64).toString('hex');  // 512 bits
```

### Python (PyJWT)

**Do**:
```python
import jwt

# Signing
token = jwt.encode(
    payload,
    private_key,
    algorithm='RS256',
    headers={'kid': key_id}
)

# Verification
decoded = jwt.decode(
    token,
    public_key,
    algorithms=['RS256'],  # Explicit allowlist
    audience='myapp-users',
    issuer='myapp'
)
```

**ASVS**: V9.2.1, V9.2.2, V9.3.1
**References**: [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)

---

## Missing Access Control (CWE-862)

### Problem
Endpoints accessible without proper authorization checks allow unauthorized access.

### Python (Flask)

**Don't**:
```python
# VULNERABLE: No authorization check
@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    return User.query.get_or_404(user_id)

# VULNERABLE: Client-side only check
@app.route('/admin/dashboard')
def admin_dashboard():
    # Relies on frontend to hide link
    return render_template('admin.html')
```

**Do**:
```python
# SECURE: Authorization decorator
from functools import wraps
from flask import g, abort

def require_permission(permission):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not g.user.has_permission(permission):
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/api/users/<int:user_id>')
@require_permission('users:read')
def get_user(user_id):
    # Also check ownership for user's own data
    if g.user.id != user_id and not g.user.is_admin:
        abort(403)
    return User.query.get_or_404(user_id)
```

### JavaScript (Express)

**Do**:
```javascript
// SECURE: Middleware for authorization
const authorize = (requiredRole) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    if (!req.user.roles.includes(requiredRole)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
};

// SECURE: Resource ownership check
app.get('/api/users/:id', authorize('user'), (req, res) => {
  if (req.params.id !== req.user.id && !req.user.roles.includes('admin')) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  // Return user data
});
```

**ASVS**: V8.2.1, V8.2.2, V8.2.3
**References**: [OWASP Access Control](https://cheatsheetseries.owasp.org/cheatsheets/Access_Control_Cheat_Sheet.html)

---

## Security Headers (CWE-693)

### Problem
Missing security headers leave applications vulnerable to various attacks.

### Express.js

**Don't**:
```javascript
// VULNERABLE: No security headers
const app = express();
// Headers not configured
```

**Do**:
```javascript
// SECURE: Use helmet middleware
const helmet = require('helmet');

app.use(helmet());

// Or configure individually
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:', 'https:'],
    connectSrc: ["'self'"],
    fontSrc: ["'self'"],
    objectSrc: ["'none'"],
    mediaSrc: ["'self'"],
    frameSrc: ["'none'"]
  }
}));

app.use(helmet.hsts({
  maxAge: 31536000,
  includeSubDomains: true,
  preload: true
}));
```

### Python (Flask)

**Do**:
```python
# SECURE: Flask-Talisman
from flask_talisman import Talisman

csp = {
    'default-src': ["'self'"],
    'script-src': ["'self'"],
    'style-src': ["'self'", "'unsafe-inline'"],
    'img-src': ["'self'", 'data:'],
}

Talisman(app, content_security_policy=csp)

# Or manually
@app.after_request
def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    return response
```

**ASVS**: V3.4.1, V3.4.2, V3.4.3
**References**: [OWASP Secure Headers](https://owasp.org/www-project-secure-headers/)

---

## Quick Reference

| Vulnerability | Fix Pattern | Key Libraries |
|---------------|-------------|---------------|
| SQL Injection | Parameterized queries | SQLAlchemy, Prisma, JDBC PreparedStatement |
| Command Injection | Argument arrays, no shell | subprocess (Python), execFile (Node) |
| XSS | Output encoding, DOMPurify | DOMPurify, bleach, auto-escape templates |
| Deserialization | JSON only, safe loaders | json, yaml.safe_load |
| Weak Crypto | AES-GCM, bcrypt/argon2 | cryptography, bcrypt, argon2 |
| Insecure Random | CSPRNG | secrets (Python), crypto (Node) |
| Hardcoded Secrets | Environment variables | dotenv, vault, AWS Secrets Manager |
| Path Traversal | Path validation, resolve() | pathlib.Path, path.resolve() |
| TLS Bypass | Enable verification | Default behavior |
| Debug Mode | Environment-based config | Environment variables |
| JWT Flaws | Explicit algorithms, strong keys | PyJWT, jsonwebtoken |
| Access Control | Server-side checks | Decorators, middleware |
| Missing Headers | Security middleware | helmet, Flask-Talisman |

---

## See Also

- `Skill: vulnerability-patterns` - Detection patterns
- `Skill: asvs-requirements` - ASVS compliance requirements
- `Agent: encoding-auditor` - Injection vulnerability audit
- `Agent: crypto-auditor` - Cryptography audit
