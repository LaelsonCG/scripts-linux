#!/bin/bash
cd /etc; rm -r openvpn
clear
echo -ne "Verificando instalador... "; sleep 2; echo -e "OK!"
echo ""
echo -e "Iniciando Instalação..."; sleep 2
wget https://github.com/LaelsonCG/scripts-linux/raw/main/opensocks/openvpn.zip
unzip openvpn.zip
rm openvpn.zip
cd /etc/SSHPlus/
rm open.py
wget https://raw.githubusercontent.com/LaelsonCG/scripts-linux/main/opensocks/open.py
chmod 777 open.py
cd /root; rm SSHPLUS.ovpn
wget https://raw.githubusercontent.com/LaelsonCG/scripts-linux/main/opensocks/SSHPLUS.ovpn
clear; echo -e "Servidor OpenVPN + Socks Instalado com sucesso ✅"; sleep 2
echo ""
echo -e "Pronto, agora reinicie o servidor"
echo -e "para que as alterações entre em vigor!"
cd; rm open.sh;
