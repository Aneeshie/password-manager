# Bash Password Manager

A secure, CLI-based password manager built with **Bash**, **SQLite**, and **OpenSSL**.

## Features

- **Secure Encryption**: Uses `AES-256-CBC` with `PBKDF2` key derivation.
- **Local Storage**: All data is stored locally in `~/.vault/vault.db`.
- **Session Management**: Unlock once, keep using until you lock or timeout (session file based).
- **Audit Trail**: Logs every action (access, modification, deletion) for security auditing.
- **Backup & Restore**: Built-in encrypted backup and restore functionality.
- **Clipboard Support**: Automatically copies passwords to clipboard (`pbcopy` on macOS, `xclip` on Linux).

## Prerequisites

Ensure you have the following installed:
- `bash`
- `sqlite3`
- `openssl`
- `pbcopy` (macOS) or `xclip` (Linux) for clipboard support.

## Installation

1. Clone the repository or download the `vault` script.
2. Make the script executable:
   ```bash
   chmod +x vault
   ```

## Usage

### 1. Initialization
First-time setup. You will be prompted to create a master password.
```bash
./vault init
```

### 2. Unlock Vault
Unlock the vault to start a session.
```bash
./vault unlock
```

### 3. Add a Password
Add a new entry. You can generate a secure password automatically.
```bash
./vault add <service_name>
# Example: ./vault add google
```

### 4. Retrieve a Password
Get a password. You can reveal it or copy it to the clipboard.
```bash
./vault get <service_name>
```

### 5. List & Search
See what's in your vault.
```bash
./vault list
./vault search <term>
```

### 6. Edit & Delete
Manage your entries.
```bash
./vault edit <service_name>
./vault delete <service_name>
```

### 7. Audit & Backup
View logs or create a backup.
```bash
./vault audit
./vault backup
```

### 8. Lock Vault
Close your session.
```bash
./vault lock
```

## Security Details

- **Master Password**: Hashed using `SHA-256` with a random salt for verification.
- **Data Encryption**: Entries are encrypted using `openssl enc -aes-256-cbc -pbkdf2`.
- **Session**: A temporary session file containing the master password is created in `~/.vault/.session` with `600` permissions (read/write only by owner) upon unlocking. It is removed upon locking.

## License

MIT
