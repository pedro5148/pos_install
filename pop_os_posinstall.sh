#!/usr/bin/env bash
#
#   pop_os_posinstall - Automatizar a instalação de programas necessarios para o meu uso
#
#   Autor:      Pedro Eugenio
#   Manutenção: Pedro Eugenio
#
# ---------------------------------------------------------------------------------------------------------------- #
#   Este script ira instalar a mioria de progrmas que eu necessito no meu dia a dia como estudante de TI.
#   Ele remove tambem alguns programas previamente instalados que nao me sao necessarios.
#
# ---------------------------------------------------------------------------------------------------------------- #
#   Historico:
#
#   v1.0 24/10/2021, Pedro Eugenio
#           - Inicio do desenvolvimento
#
# ---------------------------------------------------------------------------------------------------------------- #
#   Testado em:
#       bash 5.0.17
#
# ---------------------------------------------------------------------------------------------------------------- #
#   Agredecimentos:
#       
#   Mateus Müller (@mateuslinux_) => 
#        Graças ao curso dele de shellscript tive a ideia de automatizar essas instalações, este modelo
#        tambem é de autoria dele.
#   Dionatan Simioni (@diolinux) =>  
#        Disponivel em seu github, utilizei a ideia dele de usar um for para instalar varios programas,
#        este mesmo script tem parceria do Mateus.
#
# ---------------------------------------------------------------------------------------------------------------- #
# 
# --------------------------------------- VARIAVEIS -------------------------------------------------------------- #
URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
LINK_DROIDCAM="https://www.dev47apps.com/droidcam/linux"
CODE="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
LINK_GOLANG="https://golang.org/dl/"

HOME_USER=$(grep 1000 /etc/passwd | cut -d ":" -f6)
NOME_USER=$(grep 1000 /etc/passwd | cut -d ":" -f1) 
DEV_NULL="1> /dev/null 2>&1"
LOG_INSTALL="$HOME_USER/loginstall.txt"

PROG_INSTALL=(
    pciutils
    grub-customizer
    progress
    vim
    linux-headers-`uname -r`
    gcc
    make
    unzip
    curl
    wget
    software-properties-common
    apt-transport-https
    neofetch
    flameshot
    most
    chrome-gnome-shell
    gnome-tweaks
    build-essential
    simplescreenrecorder
    ssh
    ntfs-3g
    vlc
    gnome-sound-recorder
    nemo
    adb
    tilix
    git
    p7zip-full
    python3-pip
    python3-wxgtk4.0
    grub2-common
    grub-pc-bin
    zsh
)

PROG_REMOVE=(
    gnome-calendar
    gnome-contacts
    gnome-weather
    geary
    totem-*
    simple-scan
    firefox*
)

# ------------------------------------------ TESTE --------------------------------------------------------------- #

### --> Is Root?
[ "$UID" != "0" ] && {
    echo "Voce precisa estar logado como root para continuar..."
    exit 1
}

### --> Removendo travas do apt
eval rm /var/lib/dpkg/lock-frontend "$DEV_NULL" 
eval rm /var/cache/apt/archives/lock "$DEV_NULL"

# ------------------------------------------- EXECUCAO ----------------------------------------------------------- #
echo "Atualizando sistema..."
eval apt update "$DEV_NULL" && eval apt upgrade -y "$DEV_NULL"
echo ""
### --> Instala os programas.
echo "Instalando programas..."
for PROG in "${PROG_INSTALL[@]}" ; do
    eval apt install $PROG -y "$DEV_NULL" 
    [ "$?" = "0" ] && echo "$PROG instalado com sucesso!" >> $LOG_INSTALL || echo "$PROG nao foi instalado!" >> $LOG_INSTALL
done

### --> Desinstala programas desnecessarios para mim
echo "Removendo programas desnecessarios..."
for REMOVE in "${PROG_REMOVE[@]}"; do
    eval apt purge $REMOVE -y "$DEV_NULL"
    [ "$?" = "0" ] && echo "$REMOVE desinstalado!" >> $LOG_INSTALL || echo "Erro ao desinstalar $REMOVE" >> $LOG_INSTALL
done
echo "Limpando..."
apt autoclean -y "$DEV_NULL"

cd /tmp

### --> Instalar DroidCam
echo ""
echo "Instalando DroidCam..."
URL_DROIDCAM=$(wget -q $LINK_DROIDCAM -O -)
INSTALL_DROIDCAM=$(echo "$URL_DROIDCAM" | grep files.dev47apps.net/linux | sed 's/wget.*zip  //;s/<br.*//')
wget -c "`echo $INSTALL_DROIDCAM`" -q --show-progress -O droidcam_latest.zip
unzip -q droidcam_latest.zip -d droidcam && eval cd droidcam && eval ./install-client "$DEV_NULL"

if [ -e "$(which droidcam)" ]; then
    eval ./install-video "$DEV_NULL"
### --> Ajustando resolução do droidCam
    sed -i 's/640/1280/;s/480/720/' /etc/modprobe.d/droidcam.conf
    [ "$?" = "0" ] && echo "DroidCam instalado com sucesso!" >> $LOG_INSTALL
else
    echo "Falha na instalação do Droidcam" >> $LOG_INSTALL
fi
# sed -i 's/^/#/' arquivo.conf

### --> Instalando Chrome
echo ""
echo "Instalando Google Chrome..."
wget -c "$URL_GOOGLE_CHROME" -q --show-progress -O chrome.deb && eval apt install ./chrome.deb -y "$DEV_NULL"
[ -e "$(which google-chrome)" ] && echo "Google Chrome instalado com sucesso!" >> $LOG_INSTALL || echo "Falha na instalação do Google Chrome" >> $LOG_INSTALL
# if [ -e "$(which google-chrome)" ]; then
#     echo "Google Chrome instalado com sucesso!" >> $LOG_INSTALL
# else
#     echo "Falha na instalação do Google Chrome" >> $LOG_INSTALL
# fi 

#### --> Instalando Visual Code
echo ""
echo "Instalando Visual Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
eval apt update -y "$DEV_NULL" && eval apt install code -y "$DEV_NULL"

[ -e "$(which code)" ] && echo "VSCode Instalado com sucesso!" >> $LOG_INSTALL || echo "Falha na instalação do VSCode" >> $LOG_INSTALL

#wget -c "$CODE" -q --show-progress -O visualcode.deb && eval apt install ./visualcode.deb -y "$DEV_NULL"
#if [ -e "$(which code)" ]; then
#    echo "Visual Code instalado com Sucesso!" >> $LOG_INSTALL
#else
#    echo "Falha na instalação do Visual Code" >> $LOG_INSTALL
#fi

### --> Instalando o Virtual Box
echo ""
echo "Instalando Virtual Box..."
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | eval apt-key add - "$DEV_NULL"
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | eval apt-key add - "$DEV_NULL"
eval apt update "$DEV_NULL" && eval apt install virtualbox -y "$DEV_NULL"
#Deu certo!
[ -e "$(which virtualbox)" ] && echo "VirtualBox Instalado com sucesso!" >> $LOG_INSTALL || echo "Falha na instalação do VirtualBox" >> $LOG_INSTALL

### --> Instalar binario Golang
echo ""
echo "Instalando GO!..."
URL_GOLANG=$(wget -q $LINK_GOLANG -O -)
INSTALL_GOLANG=$(echo "$URL_GOLANG" | grep -E "downloadBox.*linux"  | sed 's/<a class.*ref="//;s/">//')
GO_LINK=$(echo "https://golang.org$INSTALL_GOLANG")
wget -c "$GO_LINK" -q --show-progress -O binarioGO.tar.gz 
eval tar -C /usr/local -xzf binarioGO.tar.gz "$DEV_NULL"
echo "export PATH=$PATH:/usr/local/go/bin" >> "$HOME_USER/.profile"
source "$HOME_USER/.profile" 

[ -e "$(which go)" ] && echo "Binario GO Instalados com sucesso!" >> $LOG_INSTALL || echo "Falha na instalação dos Binarios Go" >> $LOG_INSTALL

### --> Alias do neoftech
echo "alias dellconfig='/usr/bin/neofetch'" >> "$HOME_USER/.bashrc"
source "$HOME_USER/.profile"
### --> Habilitar o man colorido e numero da linha no VIM
#echo "export PAGER='most -s'" >> "$HOME_USER/.bashrc"
echo "set number" >> /etc/vim/vimrc

### --> Remover comando antigo do print
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '[]'

### --> Definindo o Nemo como gerenciador padrao
sudo -u "$NOME_USER" xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search && \
gsettings set org.gnome.desktop.background show-desktop-icons false && \
gsettings set org.nemo.desktop show-desktop-icons true && \
eval xdg-mime query default inode/directory "$DEV_NULL"

if [ "$?" = "0" ]; then
    echo "Neno é seu gerenciador de arquivos padrao" >> $LOG_INSTALL
else
    echo "Falha ao setar Nemo como Default Directory" >> $LOG_INSTALL
fi

### --> Instalar WoeUSB-ng, para fazer pendrive bootavel de windows
echo ""
echo "Instalando WoeUSB-ng..."
eval pip3 install WoeUSB-ng "$DEV_NULL"
[ -e "$(which woeusbgui)" ] && echo "WoeUSB-ng instalado com Sucesso!" >> $LOG_INSTALL || echo "Falha na instalação do WoeUSB-ng" >> $LOG_INSTALL






####### Falta configurar ZSH e abaixos





### --> configurando ZSH
ZSH=$(which zsh)
usermod -s $ZSH $NOME_USER

## --> Instalando o Oh My ZSH
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# plugin comando colorido
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
colocar dentro de plugins => zsh-syntax-highlighting

#autocomplete
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
colocar dentro de plugins => zsh-autosuggestions

   colored-man-pages
   sudo
   zsh-syntax-highlighting
   zsh-autosuggestions



### --> Pacotes Flatpack
flatpak install spotify anydesk discord telegram warpinator -y
echo "Instalando programas Flatpak"
eval sudo -u "$NOME_USER" flatpak install anydesk discord telegram spotify warpinator -y "$DEV_NULL"





### --> Ajustar grub pop os Valido somente para Pop OS 20.04
#
#   Caso seu sistema seja o Pop OS e voce utilize Dual boot, é necessario ajustar 
#   o boot com esses comandos.
#
#   apt install grub-efi grub2-common -y && grub-install
#   
#   if [ "$?" = "0"]; then
#   cp /boot/grub/x86_64-efi/grub.efi /boot/efi/EFI/pop/grubx64.efi
#   echo "Grub corrigido com sucesso!, adicione no Grub Customizer, \
#   acesse Arquivos->Alterar ambiente e em OUTPUT_FIle, adicione a linha: \
#   /boot/efi/EFI/pop/grub.cfg" >> $LOG_INSTALL
#else
#    echo "Falha na correção do Grub" >> $LOG_INSTALL

### --> Montar HD
#   mkdir /media/DADOS/
#   IDHD=$(blkid | grep /dev/sda1 | sed 's/\/dev.*" UUID="//;s/" TYPE.*//')
#   echo "UUID="$IDHD"   /media/DADOS    ntfs-3g gid=1000,uid=1000,dmask=022,fmask=133	0	0" >> /etc/fstab

### --> Instalar Java
#apt install ./jdk-13*.deb -y "$DEV_NULL"
#echo "JAVA_HOME=/usr/lib/jvm/jdk-13.0.2/" >> "$HOME_USER/.profile"
#update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-13.0.2/bin/java 1
#update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-13.0.2/bin/javac 1

#### tirar lag aumentar volume

#sudo vim /usr/share/X11/xkb/symbols/br 
#comentar a linha modifier_map Mod3 { Scroll_Lock }; 
echo "Instalação finalizada, verifique o arquivo de log armazenado em $LOG_INSTALL"
echo "Reinicialização necessaria, deseja reiniciar agora? S = Sim | N = Não"
read VALOR
if [ "$VALOR" = "S" -o "$VALOR" = "s" ]; then
    shutdown -r now
else
    echo "Assim que possivel reinicia o computador para concluir a instalação"
fi
