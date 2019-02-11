#!/bin/bash

_g="\e[32;1m";_e="\e[m";_w="\e[37;1m";_y="\e[33;1m";

echo -e "${_y}Instalando programas pacman\n${_e}"

# instalar programas comuns
sudo pacman -S galculator flatpak engrampa go conky --noconfirm

# instalar flatpak
echo -e "\n${_y}Instalando programas flatpak\n${_e}"
flatpak install com.discordapp.Discord 			\
				org.telegram.desktop 			\
				org.remmina.Remmina 			\
				org.videolan.VLC 				\
				org.filezillaproject.Filezilla 	\
				com.anydesk.Anydesk 			\
				com.valvesoftware.Steam

# instalar sublime-text
echo -e "\n${_y}Instalando sublime-text\n${_e}"
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg; sleep 1
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf; sleep 1
sudo pacman -Syu sublime-text

# instalar AUR Helper "yay"
echo -e "\n${_y}Instalando yay\n${_e}"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# instalar programas AUR
echo -e "\n${_y}Instalando google-chrome\n${_e}"
yay -S google-chrome --noconfirm





