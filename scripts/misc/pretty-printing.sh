RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'  

RESET='\033[00m'
BOLD='\033[01m'

function print_error {
    echo -e "${BOLD}${RED}###${RESET} ${BOLD}$1 ${RED}###${RESET}"
}

function print_select {
    echo -e "${BOLD}${BLUE}###${RESET} ${BOLD}$1 ${BLUE}###${RESET}"
}

function print_info {
    echo -e "${BOLD}${YELLOW}###${RESET} ${BOLD}$1 ${YELLOW}###${RESET}"
}

function print_milestone {
    echo -e "${BOLD}${GREEN}###${RESET} ${BOLD}$1 ${GREEN}###${RESET}\n"
}
