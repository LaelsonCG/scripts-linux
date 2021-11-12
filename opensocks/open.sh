#!/bin/bash

cd /etc/ && rm -r openvpn &&
wget https://github.com/LaelsonCG/scripts-linux/raw/main/opensocks/openvpn.zip &&
unzip openvpn.zip &&
rm openvpn.zip &&
cd /etc/SSHPlus/ &&
rm open.py &&
wget https://raw.githubusercontent.com/LaelsonCG/scripts-linux/main/opensocks/open.py &&
