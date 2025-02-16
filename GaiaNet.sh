#!/bin/bash

# ----------------------------
# Color and Icon Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

CHECKMARK="✅"
ERROR="❌"
PROGRESS="⏳"
INSTALL="🛠️"
STOP="⏹️"
RESTART="🔄"
LOGS="📄"
EXIT="🚪"
INFO="ℹ️"
ID="🆔"

# ----------------------------
# Install Docker
# ----------------------------
install_docker() {
    echo -e "${INSTALL} Installing Docker...${RESET}"
    
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo -e "${CHECKMARK} Docker installed successfully.${RESET}"
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Install Gaianet Node
# ----------------------------
install_node() {
    echo -e "${INSTALL} Installing Gaianet Node...${RESET}"
    
    # Run installation script
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
    
    # Update environment
    source $HOME/.bashrc

    # Configuration
    default_config="https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen2-0.5b-instruct/config.json"
    echo -e "default config config.json https://raw.githubusercontent.com/GaiaNet-AI/node-configs/main/qwen2-0.5b-instruct/config.json"
    read -p "Use default config? [Y/n] " use_default
    case $use_default in
        [nN][oO]|[nN])
            read -p "Enter custom config URL: " custom_config
            gaianet init --config $custom_config
            ;;
        *)
            source $HOME/.bashrc
            gaianet init --config $default_config
            ;;
    esac

    echo -e "${CHECKMARK} Node installed successfully."
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Start Node
# ----------------------------
start_node() {
    echo -e "${INSTALL} Starting Gaianet Node...${RESET}"
    gaianet start
    echo -e "${CHECKMARK} Node started successfully."
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# View Device ID
# ----------------------------
view_deviceid() {
    echo -e "${ID} Device ID:${RESET}"
    cat ~/gaianet/deviceid.txt
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# View Node ID
# ----------------------------
view_nodeid() {
    echo -e "${ID} Node ID:${RESET}"
    cat ~/gaianet/nodeid.json
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Start Bot
# ----------------------------
start_bot() {
    echo -e "${INSTALL} Starting Bot...${RESET}"
    
    read -p "Enter your NODE_ID: " node_id
    if [ -z "$node_id" ]; then
        echo -e "${ERROR} NODE_ID cannot be empty!"
        read -p "Press Enter to return to the main menu."
        return
    fi
    
    echo "NODE_ID=$node_id" > .env
    docker compose up --build -d
    
    echo -e "${CHECKMARK} Bot started successfully."
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# View Bot Logs
# ----------------------------
view_bot_logs() {
    echo -e "${LOGS} Showing last 100 lines of bot logs...${RESET}"
    docker compose logs --tail=100
    read -p "Press Enter to return to the main menu."
}

update_node(){
    echo -e "${STOP} Update Node...${RESET}"
    gaianet stop

    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash

    source $HOME/.bashrc

    gaianet start
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Stop Node
# ----------------------------
stop_node() {
    echo -e "${STOP} Stopping Node...${RESET}"
    gaianet stop
    echo -e "${CHECKMARK} Node stopped successfully."
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Stop Bot
# ----------------------------
stop_bot() {
    echo -e "${STOP} Stopping Bot...${RESET}"
    docker compose down
    echo -e "${CHECKMARK} Bot stopped successfully."
    read -p "Press Enter to return to the main menu."
}

delete_node(){
    echo -e "${ERROR} Delete Node...${RESET}"
    docker compose down
    rm -r ~/gaianet/
    echo -e "${CHECKMARK} Node stopped successfully and delete"
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Display ASCII Art
# ----------------------------
display_ascii() {
    clear
    echo -e "    ${RED}    ____  __ __    _   ______  ____  ___________${RESET}"
    echo -e "    ${GREEN}   / __ \\/ //_/   / | / / __ \\/ __ \\/ ____/ ___/${RESET}"
    echo -e "    ${BLUE}  / / / / ,<     /  |/ / / / / / / / __/  \\__ \\ ${RESET}"
    echo -e "    ${YELLOW} / /_/ / /| |   / /|  / /_/ / /_/ / /___ ___/ / ${RESET}"
    echo -e "    ${MAGENTA}/_____/_/ |_|  /_/ |_/\____/_____/_____//____/  ${RESET}"
    echo -e "    ${MAGENTA}🚀 Follow us on Telegram: https://t.me/dknodes${RESET}"
    echo -e "    ${MAGENTA}📢 Follow us on Twitter: https://x.com/dknodes${RESET}"
    echo -e "    ${GREEN}Welcome to the Gaianet Node Management System!${RESET}"
    echo -e ""
}



# ----------------------------
# Main Menu
# ----------------------------
show_menu() {
    clear
    display_ascii
    echo -e "    ${YELLOW}Choose an operation:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} Install Docker"
    echo -e "    ${CYAN}2.${RESET} ${INSTALL} Install Node"
    echo -e "    ${CYAN}3.${RESET} ${RESTART} Start Node"
    echo -e "    ${CYAN}4.${RESET} ${ID} View Device ID"
    echo -e "    ${CYAN}5.${RESET} ${ID} View Node ID"
    echo -e "    ${CYAN}6.${RESET} ${INSTALL} Start Bot"
    echo -e "    ${CYAN}7.${RESET} ${LOGS} View Bot Logs"
    echo -e "    ${CYAN}8.${RESET} ${STOP} Stop Node"
    echo -e "    ${CYAN}9.${RESET} ${STOP} Stop Bot"
    echo -e "    ${CYAN}10.${RESET} ${ERROR} DELETE Node"
    echo -e "    ${CYAN}11.${RESET} ${INSTALL} Update node"
    echo -e "    ${CYAN}12.${RESET} ${EXIT} Exit"
    echo -ne "    ${YELLOW}Enter your choice [1-10]: ${RESET}"
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    show_menu
    read choice
    case $choice in
        1) install_docker;;
        2) install_node;;
        3) start_node;;
        4) view_deviceid;;
        5) view_nodeid;;
        6) start_bot;;
        7) view_bot_logs;;
        8) stop_node;;
        9) stop_bot;;
        10) delete_node;;
        11) update_node;;
        12)
            echo -e "${EXIT} Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${ERROR} Invalid option. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
