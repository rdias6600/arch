#!/bin/bash

# openbox

__A=$(echo -e "\e[34;1m");__O=$(echo -e "\e[m");_g="\e[32;1m";_o="\e[m";_w="\e[37;1m";_am="\e[33;1m";

[ "$EUID" -ne 0 ] && echo -e "${_am}É necessário rodar o script como root!${_o}\n${_g}Use:${_o} ${_w}sudo ./xfce.sh${_o}" && exit 1

echo -en "\n${_g}Qual o nome do seu usuário:${_o}${_w} "; read _user

echo

cat /etc/passwd | grep ${_user} >/dev/null 2>&1
[ $? -ne 0 ] && { echo -e "${_am}Usuário não existe! Digite um usuário válido.\n${_o}"; exit 1; }

echo -en "${_g}Você está instalando em uma VM? Didigte S para (Sim) ou N para (Não):${_o}${_w} "; read _vm
[[ "$_vm" != @(s|S|n|N) ]] && { echo -e "\n${_am}Digite uma opção válida! s/S ou n/N\n${_o}"; exit 1; }

if [[ "$_vm" == @(s|S) ]]; then
	_virtualbox="s"
elif [[ "$_vm" == @(n|N) ]]; then
	echo -en "\n${_g}Você está instalando em um notebook?  Didigte S para (Sim) ou N para (Não)${_o}:${_w} "; read _not
	[[ "$_not" != @(s|S|n|N) ]] && { echo -e "\n${_am}Digite uma opção válida! s/S ou n/N\n${_o}"; exit 1; }
	if [[ "$_not" == @(s|S) ]]; then
		_notebook="s"
	fi
fi

echo

tput reset

cat <<STI
 ${__A}======================
 Iniciando a Instalação
 ======================${__O}
STI

echo -e "\nVocê está instalando o openbox com suporte de drivers para:\n"

if [[ "$_notebook" == "s" ]]; then
	echo -e "${_am}Notebook${_o}"
elif [[ "$_virtualbox" == "s" ]]; then
	echo -e "${_am}VM (máquina virtual)${_o}"
else
	echo -e "${_am}PC${_o}"
fi

echo -en "\n${_g}Digite s/S para continuar ou n/N para cancelar: ${_o}:${_w} "; read _go
[[ "$_go" != @(s|S) ]] && { echo -e "\n${_ver}Script cancelado\n${_o}"; exit 1; }

# xorg
echo -e "\n${_g}==>Instalando xorg${_o}"; sleep 1
pacman -S xorg-xinit xorg-server xf86-input-keyboard xf86-input-mouse xf86-video-intel --noconfirm

if [[ "$_notebook" == "s" ]]; then # notebook
	echo -e "${_g}==> Instalando drivers para notebook${_o}"; sleep 1
	pacman -S xf86-input-synaptics xf86-input-libinput --noconfirm; sleep 1
	echo -e "${_g}==> Configurando tap-to-click${_o}"; sleep 1
	curl -s -o /etc/X11/xorg.conf.d/30-touchpad.conf 'https://raw.githubusercontent.com/leoarch/arch/master/xfce/config/touchpad'
elif [[ "$_virtualbox" == "s" ]]; then # virtualbox
	echo -e "${_g}==> Guest Utils Virtuabox${_o}"; sleep 1
	pacman -S virtualbox-guest-utils --noconfirm
fi

# xfce
echo -e "${_g}==> Instalando xfce e lightdm${_o}"; sleep 1
pacman -S openbox obconf lxappearance-obconf lightdm lightdm-gtk-greeter --noconfirm

# essenciais
echo -e "${_g}==> Instalando programas essenciais${_o}"; sleep 1
pacman -S sudo gvfs xterm zip unzip unrar pcmanfm nitrogen geany tint2 xarchiver --noconfirm

# firefox
echo -e "${_g}==> Instalando firefox${_o}"; sleep 1
pacman -S firefox firefox-i18n-pt-br --noconfirm

# audio
echo -e "${_g}==> Instalando audio${_o}"; sleep 1
pacman -S alsa-utils pulseaudio pavucontrol --noconfirm

# network
echo -e "${_g}==> Instalando utilitários de rede${_o}"; sleep 1
pacman -S networkmanager network-manager-applet --noconfirm

# criar diretórios
echo -e "${_g}==> Criando diretórios${_o}"; sleep 1
pacman -S xdg-user-dirs --noconfirm && xdg-user-dirs-update

# openbox files
mkdir /${_user}/.config/openbox
echo -e '\ntint2 &\nnitrogen --restore &\n'

# start xfce
echo -e "${_g}==> Configurando pra iniciar o xfce${_o}"; sleep 1
echo 'exec openbox' > ~/.xinitrc; sleep 1

# keyboard X11 br abnt2
echo -e "${_g}==> Setando keymap br abnt2 no ambiente X11${_o}"; sleep 1
localectl set-x11-keymap br abnt2

# keyboard
echo -e "${_g}==> Criando arquivo de configuração para keyboard br abnt${_o}"; sleep 1
curl -s -o /etc/X11/xorg.conf.d/10-evdev.conf 'https://raw.githubusercontent.com/leoarch/arch/master/xfce/config/keyboard'

# configurando lightdm
echo -e "${_g}==> Configurando gerenciador de login lightdm${_o}"; sleep 1
sed -i 's/^#greeter-session.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
sed -i '/^#greeter-hide-user=/s/#//' /etc/lightdm/lightdm.conf
curl -s -o /usr/share/pixmaps/arch-01.jpg 'https://raw.githubusercontent.com/leoarch/arch/master/xfce/images/arch-01.jpg'
echo -e "[greeter]\nbackground=/usr/share/pixmaps/arch-01.jpg" > /etc/lightdm/lightdm-gtk-greeter.conf

# echo -e "${_g}===>Usando dhclient${_o}"; sleep 1
# echo -e "[main]\ndhcp=dhclient" > /etc/NetworkManager/conf.d/dhclient.conf

# enable services
echo -e "${_g}==>Habilitando serviços para serem iniciados com o sistema${_o}"; sleep 1
systemctl enable lightdm
systemctl enable NetworkManager

cat <<EOI
 ${__A}=============
      FIM!    
 =============${__O}
EOI