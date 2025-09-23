#!/bin/bash

#Back
set -euo pipefail
IFS=$'\n\t'

# Renk Kodları
MAGNET="\e[35m"
YELLOW="\e[33m"
RESET="\e[0m"
RED="\e[31m"

# Ctrl+C Yakalama
trap 'echo -e "\n${RED} İşlem Sonlandırıldı!${RESET}"; exit 1' INT

#Bağımlılık Kontrolü ve Yükleme
program_check(){
echo -e "${MAGNET}Eksik Bağımlılıklar Yükleniyor...${RESET}"
echo -e "${YELLOW}Not:Sudo Gerekli Olabilir.${RESET}"

sudo apt update && sudo apt upgrade -y
sudo apt full-upgrade -y
sudo apt install python3 -y

#NMAP Download
if ! command -v nmap >/dev/null 2>&1; then
    sudo apt install nmap -y
fi

#GOBUSTER Download
if ! command -v gobuster >/dev/null 2>&1; then
    sudo apt install gobuster -y
fi

#Wordlist Download
if ! command -v seclists >/dev/null 2>&1; then
    sudo apt install seclists -y
fi

if ! command -v netcat >/dev/null 2>&1; then
    sudo apt install netcat-traditional -y
fi

echo -e "${MAGNET}Tüm Bağımlılıklar Yüklendi!${RESET}"
    

}   


program_check