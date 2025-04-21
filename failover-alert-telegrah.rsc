#  Script para failover quando o link e DHCP Client
#  SIXCORE - Leonardo Vieira
#  Whatsapp (31) 99739-3126
# 
# 1 - Crie uma rota para o IP 1.0.0.1 com o gateway do provedor que vc deseja monitorar
# 2 - Crie um netwhatch em host coloque o IP 1.0.0.1
#
######################################################################################


######## Abaixo coloque na guia DOWN  ##############
# Cria as variavei coloque as informacoes de botid e chatid do telegram
:global botid
:global chat_id
#
#
/ip route enable [find comment="PRIMARIO"]
/log warning message="O LINK PRIMARIO VOLTOU"
/delay 3s
/tool fetch url="https://api.telegram.org/bot$botid/sendMessage\?chat_id=$chatid&text=ALERTA - VOLTOU o Link PRIMARIO da Prefeitura" keep-result=no
/tool e-mail send to="leonardo@contractti.com.br" subject="O Link PRIMARIO voltou a funcionar"


########## Abaixo coloque na guia UP ##############
# Cria as variavei coloque as informacoes de botid e chatid do telegram
:global botid
:global chat_id
#
/ip route enable [find comment="PRIMARIO"]
/log warning message="O LINK PRIMARIO VOLTOU"
/delay 3s
/tool fetch url="https://api.telegram.org/bot$botid/sendMessage\?chat_id=$chatid&text=ALERTA - VOLTOU o Link PRIMARIO da Prefeitura" keep-result=no
/tool e-mail send to="leonardo@contractti.com.br" subject="O Link PRIMARIO voltou a funcionar"
