# Keep serv00 alive

> [简体中文](README.md) | ENGLISH

This script is used to keep serv00.com free accounts active by periodically establishing SSH connections, preventing deactivation due to prolonged inactivity.

## Usage

### 1. Prepare the server list file

Write the username, server, and password in `$HOME/.serv00_alive_servers`.

Format:

```text
username@hostname:password
```

Example:

```text
user1@s1.serv00.com:password1
user2@s2.serv00.com:password2
```

> **Note:** Ensure server file permissions are set correctly to protect password security.

### 2. Run the script

#### Run with `pm2`

```bash
pm2 start bash --name serv00_alive -- -c "curl -sS https://raw.githubusercontent.com/PJ-568/serv00_alive/refs/heads/master/serv00_alive_runner | bash"
pm2 save
```

View logs (very nice):

```bash
pm2 log serv00_alive
```

#### Run directly

```bash
# Download the script
curl -sS https://raw.githubusercontent.com/PJ-568/serv00_alive/refs/heads/master/serv00_alive -o serv00_alive
chmod +x serv00_alive

# Run the script
./serv00_alive
```

## Features

- Support for multiple server configurations
- Support for bilingual output (Chinese and English)
- Automatically detect system language and display corresponding information
- Easy-to-configure server list file
- Customizable configuration via command-line arguments
- Can be run via process management tools like `pm2`

## Command-line arguments

```text
-h, --help     Show this help information
-v, --version  Show version information
-f, --file     Specify the file containing the server list (default: $HOME/.serv00_alive_servers)
```

## Script description

- `serv00_alive`: The main script, responsible for reading the server list and performing SSH connection tests.
- `serv00_alive_runner`: The runner script, responsible for periodically executing the main script. It fetches the latest version of the `serv00_alive` script from GitHub and executes it.

## Appendix

Install pm2: `bash <(curl -s https://raw.githubusercontent.com/k0baya/alist_repl/main/serv00/install-pm2.sh)`

[Node.js elegant keep alive](https://forum.naixi.net/thread-2797-1-1.html)

## License

[CC Attribution-ShareAlike 4.0 International](LICENSE)
