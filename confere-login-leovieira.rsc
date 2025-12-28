# Script para verificação e criação automática de usuário no RouterOS v7
# Autor leonardo vieira - sixcore.com.br  treinamentos de redes
# Configuração do email
:local emailTo "seu-email@exemplo.com"

# Nome do usuário a ser verificado/criado
:local userName "leovieira"
:local userGroup "full"

# Gera senha aleatória (12 caracteres)
:local chars "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
:local password ""
:local charsLen [:len $chars]
:for i from=1 to=12 do={
    :local timeStr [/system clock get time]
    :local randIndex ([:pick $timeStr 6 8] % $charsLen)
    :set password ($password . [:pick $chars $randIndex ($randIndex + 1)])
    :delay 100ms
}

# Verifica se o usuário existe
:local userExists false
:foreach user in=[/user find name=$userName] do={
    :set userExists true
}

# Se o usuário não existir, cria e envia email
:if (!$userExists) do={
    # Gera senha aleatória (12 caracteres)
    :local chars "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    :local password ""
    :local charsLen [:len $chars]
    :for i from=1 to=12 do={
        :local timeStr [/system clock get time]
        :local randIndex ([:pick $timeStr 6 8] % $charsLen)
        :set password ($password . [:pick $chars $randIndex ($randIndex + 1)])
        :delay 100ms
    }
    
    :local newPassword $password
    
    # Cria o usuário
    /user add name=$userName group=$userGroup password=$newPassword
    :log info "Usuario $userName criado com sucesso"
    
    # Coleta informações do equipamento
    :local routerModel [/system resource get board-name]
    :local rosVersion [/system resource get version]
    :local identity [/system identity get name]
    
    # Verifica e ativa IP Cloud se necessário
    :local cloudDNS ""
    :local cloudEnabled [/ip cloud get ddns-enabled]
    
    :if (!$cloudEnabled) do={
        /ip cloud set ddns-enabled=yes
        :log info "IP Cloud ativado"
        :delay 5s
    }
    
    :set cloudDNS [/ip cloud get dns-name]
    
    # Monta o corpo do email
    :local emailBody "Notificacao: Usuario criado no MikroTik\r\n\r\n"
    :set emailBody ($emailBody . "Usuario: $userName\r\n")
    :set emailBody ($emailBody . "Senha: $newPassword\r\n")
    :set emailBody ($emailBody . "Grupo: $userGroup\r\n\r\n")
    :set emailBody ($emailBody . "Informacoes do Equipamento:\r\n")
    :set emailBody ($emailBody . "Modelo: $routerModel\r\n")
    :set emailBody ($emailBody . "Versao RouterOS: $rosVersion\r\n")
    :set emailBody ($emailBody . "Identity: $identity\r\n")
    :set emailBody ($emailBody . "DNS Cloud: $cloudDNS\r\n\r\n")
    :set emailBody ($emailBody . "Data/Hora: ")
    :set emailBody ($emailBody . [/system clock get date])
    :set emailBody ($emailBody . " ")
    :set emailBody ($emailBody . [/system clock get time])
    
    # Envia o email
    /tool e-mail send to=$emailTo subject="[MikroTik] Usuario $userName criado - $identity" body=$emailBody
    :log info "Email de notificacao enviado para $emailTo"
    
} else={
    :log info "Usuario $userName ja existe, nenhuma acao necessaria"
}