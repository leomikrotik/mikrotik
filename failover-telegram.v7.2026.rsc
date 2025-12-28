# ============================================
# CONFIGURAÇÕES - EDITE APENAS ESTA SEÇÃO - Leo Vieira sixcore.com.br
# ============================================

# Nome do provedor/link (usado no comment das rotas)
:local provedor "Avanza"

# Configurações de Email
:local emailDestino "seuemail@hotmail.com"
:local emailAssunto "GMC L1 ATIVO Link Avanza"

# Configurações do Telegram
:local telegramBotID "80:AAGXlDJrEbcvstZHGd5KJN8KrugGUqPPJ9k"
:local telegramChatID "8384826"
:local telegramMensagem "O link AVANZA MATRIZ voltou a pingar, o status agora e UP"

# ============================================
# EXECUÇÃO - NÃO ALTERAR ABAIXO
# ============================================

# Ajuste de Rotas IPv4
/ip route enable [find comment=$provedor]

# Ajuste de Rotas IPv6
/ipv6 route enable [find comment=$provedor]

# Elimina possivel problema de rastreamento de conexao
/ipv6 firewall connection remove [find]
/ip firewall connection remove [find]

# Envia aviso por email
/tool e-mail send to=$emailDestino subject=$emailAssunto

# Envia aviso pelo Telegram
/tool fetch \
url=("https://api.telegram.org/bot".$telegramBotID."/sendMessage") \
http-method=post \
http-data=("chat_id=".$telegramChatID."&text=".$telegramMensagem) \
keep-result=no