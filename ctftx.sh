#!/bin/bash

#Renk Komutları
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[0m"
YELLOW="\e[33m"

#Önemli Ayarlar
trap 'echo -e "\n${RED} İşlem Sonlandırıldı!${RESET}"; exit 1' INT
set -euo pipefail
IFS=$'\n\t'

cikis(){
  exit 0
}

#Devam Etmek İçin Enter'a Basma Fonksiyonu
pause(){
  read -rp "Devam etmek için Enter'a basın..."
}


# Basit hedef doğrulama / http prefix ekleme (gobuster için)
http_prefix() {
local t="$1"
if [[ "$t" =~ ^https?:// ]]; then
    echo "$t"
else
    echo "http://$t"
fi
}


nmap_menu (){
clear
local target="$1"
echo -e "${GREEN}Nmap Tarama Menüsü ${RESET}"
echo -e "---------------------------------"

while true; do
cat<<-EOF
Yapmak İstediğiniz İşlemi Seçin:
1)Script & Version Tespiti
2)Geniş Kapsamlı Tarama(Uzun Sürer)
3)Web Odaklı Derin Tarama
4)Ftp Keşfi
5)Servis Tabanlı Zaafiyet Taraması
6)Geri(exit)

EOF

read -rp "Seçiminiz: " secim2
case $secim2 in
1)
clear
echo -e "${GREEN} Script & Version Tespiti Başlatılıyor... ${RESET}"
    nmap -Pn -sCV "$target"
    cikis
;;

2)
clear
echo -e "${GREEN} Geniş Kapsamlı Tarama Başlatılıyor...${RESET}"
    nmap -sS -Pn -sV --script vuln -p- "$target"
    cikis
;;

3)
clear
echo -e "${GREEN} Web Odaklı Derin Tarama Başlatılıyor...${RESET}"
    sudo nmap -p 80,443,8080,8443 -sS -sV --version-all --script "http-*,ssl-*,default" "$target"
    cikis
;;

4)
clear
echo -e "${GREEN} Ftp Keşfi Başlatılıyor...${RESET}"
    sudo nmap -p 21 -sV --script "ftp-anon,ftp-syst,ftp-brute,ftp-vsftpd-backdoor" "$target"
    cikis
;;

5)
clear
echo -e "${GREEN} Servis Tabanlı Zaafiyet Taraması Başlatılıyor...${RESET}"
    sudo nmap -sV -p- --script vuln --script-args vulns.showall "$target"
    cikis
;;

6)
echo -e "${YELLOW} Ana Menüye Dönülüyor...${RESET}"; 
clear
break 
;;

*)echo -e "${RED}Geçersiz seçim! Lütfen geçerli bir seçenek girin.${RESET}" 
;;
esac
done
}


gobuster_menu () {
local target="$1"
clear
echo -e "${GREEN}Gobuster Gizli Dizin Bulma Menüsü ${RESET}"
echo -e "---------------------------------"

while true; do
cat<<-EOF
Yapmak İstediğiniz İşlemi Seçin:

1)Standart Gizli Dizin Bulma
2)Büyük ve Derin Dizin Tarama
3)php,html,txt Uzantılı Dosyaları Bulma
4)Subdirectory Listesi ile Tarama
5)Farklı HTTP Kodlarını Görüntüleme
6)Geri(exit)

EOF

read -rp "Seçiminiz: " secim3
case $secim3 in

1)
clear
echo -e "${GREEN} Standart Gizli Dizin Bulma Başlatılıyor...${RESET}"
   gobuster dir -u "$(http_prefix "$target")" -w /usr/share/seclists/Discovery/Web-Content/common.txt  
   cikis
;;

2)
clear
echo -e "${GREEN} Büyük ve Derin Dizin Tarama Başlatılıyor...${RESET}"
    gobuster dir -u "$(http_prefix "$target")" -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt
    cikis
;;

3)
clear
echo -e "${GREEN} php,html,txt Uzantılı Dosyaları Bulma Başlatılıyor...${RESET}"
    gobuster dir -u "$(http_prefix "$target")" -w /usr/share/seclists/Discovery/Web-Content/common.txt -x php,html,txt
    cikis
;;

4)
clear
echo -e "${GREEN} Subdirectory Listesi ile Tarama Başlatılıyor...${RESET}"
    gobuster dir -u "$(http_prefix "$target")" -w /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt
    cikis
;;

5)
clear
echo -e "${GREEN} Farklı HTTP Kodlarını Görüntüleme Başlatılıyor...${RESET}"
    gobuster dir -u "$(http_prefix "$target")" -w /usr/share/wordlists/dirb/common.txt -s "200,204,301,302,307,403"
    cikis
;;

6)
echo -e "${YELLOW} Ana Menüye Dönülüyor...${RESET}"; 
clear
break ;;

*)echo -e "${RED}Geçersiz seçim! Lütfen geçerli bir seçenek girin.${RESET}"
    ;;
esac
pause
done   
}

ffuf_menu () {
local target="$1"
clear
echo -e "${GREEN}Web Fuzz Menüsü ${RESET}"
echo -e "-----------------------------------"
while true; do
cat<<-EOF
Yapmak İstediğiniz İşlemi Seçin:
1)Directory Fuzz
2)Subdomain Fuzz
3)Dns Fuzz
4)Php,Asp,JS,HTML Vb. Uzantılı Dosyaları Bulma
5)Post Fuzz
6)Geri(exit)

EOF
read -rp "Seçiminiz: " secim4
case $secim4 in

1)
clear
echo -e "${GREEN} Directory Fuzz Başlatılıyor...${RESET}"
   ffuf -u "$(http_prefix "$target")/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/common.txt
   cikis
;;

2)
clear
echo -e "${GREEN} Subdomain Fuzz Başlatılıyor...${RESET}"
    ffuf -u "$(http_prefix "FUZZ.$target")" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -H "Host:FUZZ.$target" -mc 200,403
  cikis
   ;;

3)
clear
echo -e "${GREEN} Dns Fuzz Başlatılıyor...${RESET}"
    ffuf -u "$(http_prefix "$target")" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -H "Host:FUZZ.$target" -mc 200,403
    cikis
    ;;

4)
clear
echo -e "${GREEN} Php,Asp,JS,HTML Vb. Uzantılı Dosyaları Bulma Başlatılıyor...${RESET}"
    ffuf -u "$(http_prefix "$target")/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -e .php,.asp,.js,.html,.txt
    cikis
    ;;

5)
clear
echo -e "${GREEN} Post Fuzz Başlatılıyor...${RESET}"
    ffuf -u "$(http_prefix "$target")/login" -X POST -d "username=admin&password=FUZZ" -w /usr/share/seclists/Passwords/rockyou.txt -mc 200
    cikis
    ;;

6)echo -e "${YELLOW} Ana Menüye Dönülüyor...${RESET}"; 
clear
break ;;
*)echo -e "${RED}Geçersiz seçim! Lütfen geçerli bir seçenek girin.${RESET}"
  ;; 

esac
pause
done    
}

ek_araclar(){
clear
    echo -e "${GREEN}Ek Araçlar Menüsü ${RESET}"
    echo -e "-----------------------------------"
    while true; do
        cat<<-EOF
Yapmak İstediğiniz İşlemi Seçin:
1)Netcat İle Port Dinleme 
2)Netcat İle Bağlantı Gönderme 
3)Python Basit HTTP Sunucusu Başlatma
4)Geri

EOF

        read -rp "Seçiminiz: " secim5
        case $secim5 in
        1)
        read -rp "Dinlemek İstediğiniz Port Numarası: " target
        clear
        echo -e "${GREEN} Port Dinleniyor...${RESET}"
          nc -lvnp "$target"
          
        ;;
        2)
        read -rp "Dinlemek İstediğiniz İp Adresi: " ip_adresi
          read -rp "Dinlemek İstediğiniz Port Numarası: " port_numarasi
          clear
          echo -e "${GREEN} Bağlantı Gönderiliyor...${RESET}"
          nc "$ip_adresi" "$port_numarasi"
          cikis
        ;;
        3)
        clear
        echo -e "${GREEN} Basit HTTP Sunucusu Başlatılıyor...${RESET}"
        echo -e "${YELLOW} Sunucu 8000 Portunda Başlatıldı. Tarayıcıdan http://localhost:8000 adresine gidin.${RESET}"
        python3 -m http.server 8000
        ;;
        4)
        echo -e "${YELLOW} Ana Menüye Dönülüyor...${RESET}"; 
          clear
          break
        ;;
        *)echo -e "${RED}Geçersiz seçim! Lütfen geçerli bir seçenek girin.${RESET}"
        ;;
        esac
        pause
    done
}


brute_force_menu(){
clear
echo -e "${GREEN}Brute-Force Menüsü ${RESET}"
echo -e "-----------------------------------"
while true; do
cat<<-EOF
Yapmak İstediğiniz İşlemi Seçin:
1)FTP Password Brute-Force
2)SSH Password Brute-Force
3)Geri(exit)
EOF

read -rp "Seçiminiz: " secim6
case $secim6 in
1)
read -rp "Hedef IP/Domain: " target
read -rp "Kullanıcı Adı: " username
hydra -l "$username" -P /usr/share/wordlists/rockyou.txt ftp://"${target}" -t 4
;;

2)
read -rp "Hedef IP: " target
read -rp "Kullanıcı Adı: " username2
hydra -l "$username2" -P /usr/share/wordlists/rockyou.txt ssh://"${target}" -t 4
;;
3)
echo -e "${YELLOW} Ana Menüye Dönülüyor...${RESET}"; 
clear
break
;;
*)echo -e "${RED}Geçersiz seçim! Lütfen geçerli bir seçenek girin.${RESET}"
;;
esac
pause
done    
}   


#Ana Menü
main_menu (){  
echo -e "${BLUE}Ctftx'e Hoş Geldiniz. 
${RESET}"


echo -e "${YELLOW}Yapmak İstediğiniz İşlemi Seçin: ${RESET}"
while true; do
cat<<-EOF
1)Nmap Tarama Menüsü
2)Gobuster Gizli Dizin Bulma Menüsü
3)Web Fuzz Menüsü
4)Brute-Force Menüsü
5)Ek Araçlar Menüsü
6)Çıkış(exit)

EOF

read -rp "Seçiminiz: " secim
case $secim in
1)read -rp "Hedef IP/Domain: " target
    nmap_menu "$target" ;;

2)read -rp "Hedef IP/Domain: " target
    gobuster_menu "$target" ;;

3)read -rp "Hedef IP/Domain: " target
    ffuf_menu "$target" ;;

4)brute_force_menu

;;

5)ek_araclar

;;

6)echo -e "${RED}Çıkış Yapılıyor...${RESET}"; 
    exit 0 ;;

*)echo -e "${RED}Geçersiz seçim! Lütfen geçerli bir seçenek girin.${RESET}" 
;;

esac
done
}


main_menu




