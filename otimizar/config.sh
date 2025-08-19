#!/bin/bash
# Script de otimização: habilita zswap + cria swapfile
# Autor: @LaelsonCG
# Telegram: @LaelsonC

set -e

echo "🚀 Iniciando configuração de memória (zswap + swapfile)..."

# -------------------------------
# 0. Garantir dependências
# -------------------------------
echo "🔍 Verificando dependências necessárias..."

PKGS=("util-linux" "procps" "mount" "systemd" "e2fsprogs")
MISSING=()

for PKG in "${PKGS[@]}"; do
    if ! dpkg -s "$PKG" &>/dev/null; then
        MISSING+=("$PKG")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "📦 Instalando dependências: ${MISSING[*]}"
    apt-get update -y
    apt-get install -y "${MISSING[@]}"
else
    echo "✅ Todas as dependências estão presentes."
fi

# -------------------------------
# 1. Ativar zswap no GRUB
# -------------------------------
GRUB_FILE="/etc/default/grub"
ZSWAP_OPTS='zswap.enabled=1 zswap.compressor=zstd zswap.max_pool_percent=25'

if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"; then
    echo "🔍 Linha GRUB_CMDLINE_LINUX_DEFAULT encontrada, ajustando..."
    sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"${ZSWAP_OPTS}\"|" "$GRUB_FILE"
else
    echo "⚠️ Linha GRUB_CMDLINE_LINUX_DEFAULT não encontrada, adicionando..."
    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"${ZSWAP_OPTS}\"" >> "$GRUB_FILE"
fi

echo "✅ zswap configurado no GRUB."
update-grub

# -------------------------------
# 2. Criar swapfile
# -------------------------------
if swapon --show | grep -q '/swapfile'; then
    echo "ℹ️ Swapfile já existe e está ativa."
else
    RAM_GB=$(free -g | awk '/Mem:/ {print $2}')
    DISK_AVAIL=$(df --output=avail / | tail -n 1)
    DISK_AVAIL_GB=$((DISK_AVAIL/1024/1024))

    echo "💾 Memória física: ${RAM_GB}GB | Espaço livre em disco: ${DISK_AVAIL_GB}GB"
    echo "⚠️  Recomenda-se criar um swapfile com no máximo o mesmo tamanho da RAM física (${RAM_GB}GB)."
    echo "👉 Exemplo: Se você tem 4GB de RAM, crie swap entre 2 e 4 (digite apenas o número, sem 'GB')."
    
    while true; do
        read -rp "Digite o tamanho do swap desejado em GB: " SWAP_GB
    
        # Validação: só aceitar números inteiros positivos
        if [[ "$SWAP_GB" =~ ^[0-9]+$ ]]; then
            if [ "$SWAP_GB" -gt 0 ] && [ "$SWAP_GB" -le "$RAM_GB" ]; then
                break
            else
                echo "❌ Valor inválido! Digite um número entre 1 e ${RAM_GB}."
            fi
        else
            echo "❌ Entrada inválida! Digite apenas números inteiros (ex: 4)."
        fi
    done

    echo "📦 Criando swapfile de ${SWAP_GB}GB..."
    fallocate -l ${SWAP_GB}G /swapfile || dd if=/dev/zero of=/swapfile bs=1G count=${SWAP_GB}
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    # Persistência no fstab
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi

    echo "✅ Swapfile criado e ativado."
fi

# -------------------------------
# 3. Ajustar sysctl
# -------------------------------
SYSCTL_FILE="/etc/sysctl.conf"

add_or_update_sysctl() {
    local key=$1
    local value=$2
    if grep -q "^${key}" $SYSCTL_FILE; then
        sed -i "s|^${key}.*|${key}=${value}|" $SYSCTL_FILE
    else
        echo "${key}=${value}" >> $SYSCTL_FILE
    fi
}

echo "⚙️ Ajustando parâmetros de memória..."
add_or_update_sysctl vm.swappiness 60
add_or_update_sysctl vm.vfs_cache_pressure 50
add_or_update_sysctl vm.overcommit_memory 1
add_or_update_sysctl vm.overcommit_ratio 80
add_or_update_sysctl net.core.somaxconn 1024

sysctl -p
echo "✅ sysctl aplicado."

# -------------------------------
# 4. Finalização
# -------------------------------
echo
echo "🎉 Configuração concluída!"
echo "➡️ zswap habilitado no GRUB"
echo "➡️ Swapfile ativo (${SWAP_GB}GB)"
echo "➡️ Parâmetros do kernel ajustados"
echo
echo "🔄 É recomendado reiniciar agora para que o zswap entre em vigor."
read -p "Deseja reiniciar agora? (s/n): " RESP
if [[ "$RESP" == "s" || "$RESP" == "S" ]]; then
    reboot
else
    echo "⚠️ Lembre-se de reiniciar manualmente depois!"
fi
