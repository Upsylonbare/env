#!/bin/bash
# AUTHOR:   tot0k https://github.com/tot0k

RESET='\033[0m'

RED='\033[00;31m'
LRED='\033[01;31m'
GREEN='\033[00;32m'
LGREEN='\033[01;32m'
YELLOW='\033[00;33m'
LYELLOW='\033[01;33m'
BLUE='\033[00;34m'
LBLUE='\033[01;34m'
PURPLE='\033[00;35m'
LPURPLE='\033[01;35m'
WHITE='\033[01;37m'
CYAN='\033[00;36m'
LCYAN='\033[01;36m'
LIGHTGRAY='\033[00;37m'

BOLD=$(tput bold)
NORM=$(tput sgr0)

# 0 = fatal
# 1 = error
# 2 = warning
# 3 = info
# 4 = debug
LOG_LEVEL=3

echo_err() {
    if [ $LOG_LEVEL -ge 1 ]; then
        echo -e "${RED}${BOLD}[ERROR] ${1}${RESET}"
    fi
}

echo_warn() {
    if [ $LOG_LEVEL -ge 2 ]; then
        echo -e "${YELLOW}${BOLD}[WARNING] ${1}${RESET}"
    fi
}

echo_ok() {
    if [ $LOG_LEVEL -ge 3 ]; then
        echo -e "${GREEN}${BOLD}[OK]${NORM} ${1}${RESET}"
    fi
}

echo_info() {
    if [ $LOG_LEVEL -ge 3 ]; then
        echo -e "${WHITE}${BOLD}[INFO]${NORM} ${1}${RESET}"
    fi
}

echo_debug() {
    if [ $LOG_LEVEL -ge 4 ]; then
        echo -e "${LIGHTGRAY}${BOLD}[DEBUG]${NORM} ${1}${RESET}"
    fi
}
