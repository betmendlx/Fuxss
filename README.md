# FuXss: Automated XSS Toolchain

## Overview

**FuXss** is a Bash script designed to automate the installation of essential tools for XSS (Cross-Site Scripting) assessment and to streamline the process of collecting relevant data from a target domain. This script installs necessary Go and Python tools, gathers subdomains, and checks for vulnerabilities, generating comprehensive output files.

## Features

- Automated installation of essential tools.
- Checks for existing files and skips redundant operations.
- Provides options for custom payload lists.
- Color-coded output for better user experience.
- Logs all outputs and errors for troubleshooting.

## Requirements

- **Go**: Make sure Go is installed and properly configured on your system.
- **Python 3**: The script uses `pip3` to install Python packages.
- **Bash**: The script should be run in a Unix-like environment.

## Installation

1. Clone the repository or download the script file.
2. Ensure that `go` and `pip3` are installed on your system.
3. Make the script executable:

   ```bash
   chmod +x fuxss.sh
   ```

## Usage

Run the script with the following command:

```bash
./fuxss.sh
```

### Steps

1. The script will prompt you to enter a domain name for analysis.
2. You will have the option to provide a custom payload list for `dalfox`.
3. The script will automatically install any missing tools and begin processing the domain.
4. Results will be stored in a directory named `results/<your_domain>`.

## Output

The script generates various output files, including:

- `wayback.txt`
- `gau.txt`
- `subdomains.txt`
- `activesubs.txt`
- `gospider.txt`
- `hakrawler.txt`
- `katana.txt`
- `paths.txt`
- `uro1.txt`
- `live_uro1.txt`
- `xss_ready.txt`
- `Vulnerable_XSS.txt`

You can find all generated files in the `results/<your_domain>` directory.

## Logging

All script output and errors are logged in `script.log`, which is created in the same directory as the script. Check this file for any issues during execution.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Disclaimer

This script is intended for educational purposes and should only be used in accordance with the law. Always obtain proper authorization before testing any domain for vulnerabilities.
