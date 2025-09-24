#!/bin/bash

# Arquivo de configuração
SYSCTL_CONF="/etc/sysctl.conf"

# Configurações desejadas
CONFIGS=(
    "net.ipv6.conf.all.disable_ipv6 = 1"
    "net.ipv6.conf.default.disable_ipv6 = 1"
    "net.ipv6.conf.lo.disable_ipv6 = 1"
)

echo "Iniciando a configuração para priorizar IPv4..."

# Adicionar cabeçalho de seção (opcional, para organização)
if ! grep -q "# IPv4 Priority Configuration" "$SYSCTL_CONF"; then
    echo -e "\n# IPv4 Priority Configuration" | sudo tee -a "$SYSCTL_CONF" > /dev/null
fi


for LINE in "${CONFIGS[@]}"; do
    # Extrai a chave (ex: net.ipv6.conf.all.disable_ipv6)
    KEY=$(echo "$LINE" | awk '{print $1}')

    # Expressão regular para encontrar a chave, ignorando comentários e valores atuais.
    # Ex: ^[# ]*net\.ipv6\.conf\.all\.disable_ipv6[ ]*=[ ]*[01]
    REGEX="^[# ]*${KEY//./\\.}[ ]*=[ ]*[01]"

    if grep -qE "$REGEX" "$SYSCTL_CONF"; then
        # 1. A linha existe (comentada ou não, com valor 0 ou 1).
        echo "Ajustando: $KEY"
        # Usa 'sed' para substituir a linha existente pelo valor correto e descomentado.
        # Usa \x2F (/) para evitar problemas com barras no comando.
        sudo sed -i -r "/${REGEX}/c\\${LINE}" "$SYSCTL_CONF"
    else
        # 2. A linha não existe no arquivo.
        echo "Adicionando: $KEY"
        echo "$LINE" | sudo tee -a "$SYSCTL_CONF" > /dev/null
    fi
done

echo ""
echo "Aplicando as novas configurações do sysctl..."
# Aplica as novas configurações imediatamente
sudo sysctl -p

echo ""
echo "Verificação das configurações (deve retornar 1):"
# Verifica as chaves (exemplo)
sudo sysctl net.ipv6.conf.all.disable_ipv6

echo "Configuração concluída! A VPS deve agora priorizar o IPv4."
