
# Otimização de Memória Linux (zswap + swapfile)

🚀 **Script de otimização para VPS e servidores Linux**  

Este script automatiza a configuração de otimização de memória em sistemas Linux, combinando **zswap** e **swapfile**, além de ajustar parâmetros de kernel para melhorar desempenho e gerenciamento de memória.

---

## 🔹 O que ele faz

1. **Verifica e instala dependências essenciais** (`util-linux`, `procps`, `mount`, `systemd`, `e2fsprogs`).  
2. **Habilita zswap** no GRUB com compressão `zstd` e limite de pool ajustável.  
3. **Cria swapfile** de tamanho configurável pelo usuário, ativando-o e garantindo persistência no `fstab`.  
4. **Ajusta parâmetros do kernel** via `sysctl`:
   - `vm.swappiness=60`
   - `vm.vfs_cache_pressure=50`
   - `vm.overcommit_memory=1`
   - `vm.overcommit_ratio=80`
   - `net.core.somaxconn=1024`

5. Sugere reinício para ativar o zswap.

---

## 🔹 Requisitos

- Sistema Linux (Debian/Ubuntu testado)  
- Acesso root ou `sudo`  
- Internet para instalar pacotes e baixar o script  

---

## 🔹 Instalação / Execução

```bash
bash <(wget -qO- https://raw.githubusercontent.com/LaelsonCG/scripts-linux/refs/heads/main/otimizar/config.sh)
```
O script solicitará que você informe o tamanho da swap (em GB) e ajustará automaticamente as configurações do sistema.

---

## 🔹 Observações ⚠️

- Recomenda-se criar swap com tamanho até igual à RAM física.
- Após a execução, é necessário reiniciar para que o zswap entre em vigor.

**Script feito para ser simples, seguro e funcional, mas usuários leigos podem precisar de ajuda para interpretar mensagens ou reiniciar o servidor.**

**Autor:** LaelsonCG
**Telegram:** https://t.me/LaelsonC
