#!/bin/bash

# ==> Autor: leo.arch 
# ==> Email: leo.arch@bol.com.br 
# ==> Script: chroot.sh v1.0 
# ==> Descrição: executa arch-chroot

# variables user and pass root/user
_user="ramon"
_proot="6600"
_puser="6600"

# cores
_r="\e[31;1m";_w="\e[37;1m";_g="\e[32;1m";_o="\e[m";

# start script

# language, keyboard, hour, hostname, hosts, multilib ...
echo -e "${_g}==> Idioma, Teclado, Hora, Hostname, Hosts, Multilib, Sudoers${_o}"; sleep 1

echo -e "${_g}==> Inserindo pt_BR.UTF-8 em locale.gen${_o}"; sleep 1
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen

echo -e "${_g}==> Inserindo pt_BR.UTF-8 em /etc/locale.conf${_o}"; sleep 1
echo LANG=pt_BR.UTF-8 > /etc/locale.conf

echo -e "${_g}==> Exportando LANG=pt_BR.UTF-8${_o}"; sleep 1
export LANG=pt_BR.UTF-8

echo -e "${_g}==> Inserindo KEYMAP=br-abnt2 em /etc/vconsole.conf${_o}"; sleep 1
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

echo -e "${_g}==> Configurando Horário America/Fortaleza${_o}"; sleep 1
ln -sf /usr/share/zoneinfo/America/Fortaleza /etc/localtime && hwclock --systohc --utc

echo -e "${_g}==> Inserindo hostname Inspiron-7472 em /etc/hostname${_o}"; sleep 1
echo "Inspiron-7472" > /etc/hostname

echo -e "${_g}==> Inserindo dados em /etc/hosts${_o}"; sleep 1
echo -e "127.0.0.1\tlocalhost.localdomain\tlocalhost\n::1\tlocalhost.localdomain\tlocalhost\n127.0.1.1\tarch.localdomain\tarch\n" > /etc/hosts

echo -e "${_g}==> Habilitando Multilib${_o}"; sleep 1
echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" >> /etc/pacman.conf

echo -e "${_g}==> Criando grupo wheel${_o}"; sleep 1
echo -e "%wheel ALL=(ALL) ALL\n" >> /etc/sudoers

echo -e "${_g}==> Gerando Locale${_o}"
locale-gen

# password
echo -e "${_g}==> Criando senha root${_o}"
passwd << EOF
$_proot
$_proot
EOF
sleep 0.5

echo -e "${_g}==> Criando senha user${_o}"
useradd -m -g users -G wheel -s /bin/bash $_user
passwd $_user << EOF
$_puser
$_puser
EOF
sleep 0.5

echo -e "${_g}==> Sincronizando a base de dados${_o}"; sleep 1
pacman -Syu --noconfirm

# no meu caso, o dhclient funciona pro meu roteador e dhcpcd não (altere a vontade)
	 echo -e "${_g}==> Instalando dhcpcd${_o}"
	 pacman -S wget nano --noconfirm # remove dhclient dhcpcd

# grub configuration
if [[ "$_uefi" != "" ]]; then
	echo -e "${_g}==> bootctl UEFI mode${_o}"
	bootctl --path=/boot install
	echo -e "default arch\ntimeout 5\n" > /boot/loader/loader.conf
	echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=${_root} rw\n" > /boot/loader/entries/arch.conf
else
	echo -e "${_g}==> Instalando e Configurando o GRUB${_o}"
	pacman -S grub iwd --noconfirm
	# dual boot
	# [[ "$_dualboot" == "s" ]] && { pacman -S os-prober --noconfirm; }
	grub-install --target=i386-pc --recheck /dev/${_disk}
	cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
	grub-mkconfig -o /boot/grub/grub.cfg
fi

if [[ "$_notebook" == "s" ]]; then
	echo -e "${_g}==> Instalando drivers para notebook${_o}"; sleep 1
	pacman -S networkmanager iwd --noconfirm
fi

echo -e "${_g}==> mkinitcpio${_o}"
mkinitcpio -p linux

echo -e "${_g}==> Fim do script chroot.sh${_o}"

exit
