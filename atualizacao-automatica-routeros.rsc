# ============================================
# Script de Auto-Update RouterOS com Notificação por Email
# Versão: 2.0
# Compatível com: RouterOS v7.x
# Autor: Leonardo Vieira - sixcore.com.br Treinamento em Redes
# ============================================

# -------------------- CONFIGURAÇÕES --------------------
# Defina o endereço de email do destinatário
:local email "seu-email@exemplo.com"

# -------------------- INÍCIO DO SCRIPT --------------------

# Obtém o nome do roteador configurado no sistema
:local nomeRoteador [/system identity get name]

# Registra no log o início da verificação de atualizações
:log info "Auto-Update: Iniciando verificação de atualizações para o roteador $nomeRoteador"

# Verifica se existem atualizações disponíveis
/system package update check-for-updates once

# Aguarda 3 segundos para o sistema processar a verificação
:delay 3s

# Obtém o status da atualização
:local statusUpdate [/system package update get status]

# Obtém a versão atual instalada
:local versaoAtual [/system package update get installed-version]

# Obtém a versão disponível (se houver)
:local versaoDisponivel [/system package update get latest-version]

# Registra no log o resultado da verificação
:log info "Auto-Update: Status da verificação: $statusUpdate"
:log info "Auto-Update: Versão atual: $versaoAtual | Versão disponível: $versaoDisponivel"

# Verifica se existe nova versão disponível
:if ($statusUpdate = "New version is available") do={
    
    # Registra no log que uma nova versão foi encontrada
    :log warning "Auto-Update: Nova versão encontrada! Preparando para instalar $versaoDisponivel"
    
    # Prepara o assunto do email com o nome do roteador
    :local assuntoEmail "RouterOS Atualizado - $nomeRoteador"
    
    # Prepara o corpo do email com informações detalhadas
    :local corpoEmail "Notificacao Automatica de Atualizacao\n\n"
    :set corpoEmail ($corpoEmail . "Roteador: $nomeRoteador\n")
    :set corpoEmail ($corpoEmail . "Versao Anterior: $versaoAtual\n")
    :set corpoEmail ($corpoEmail . "Nova Versao: $versaoDisponivel\n\n")
    :set corpoEmail ($corpoEmail . "O roteador sera atualizado e reiniciado automaticamente.\n")
    :set corpoEmail ($corpoEmail . "Data/Hora: " . [/system clock get date] . " " . [/system clock get time] . "\n\n")
    :set corpoEmail ($corpoEmail . "Este e um email automatico. Nao responda.")
    
    # Envia o email de notificação antes da instalação
    :do {
        /tool e-mail send to=$email subject=$assuntoEmail body=$corpoEmail
        :log info "Auto-Update: Email de notificação enviado com sucesso para $email"
    } on-error={
        # Se houver erro no envio do email, registra no log mas continua com a atualização
        :log error "Auto-Update: Falha ao enviar email de notificação para $email"
    }
    
    # Aguarda 5 segundos para garantir o envio do email
    :delay 5s
    
    # Registra no log que a instalação será iniciada
    :log warning "Auto-Update: Iniciando instalação da versão $versaoDisponivel. O sistema será reiniciado."
    
    # Inicia a instalação da atualização (o sistema reiniciará automaticamente)
    /system package update install
    
} else={
    # Registra no log que não há atualizações disponíveis
    :log info "Auto-Update: Sistema já está atualizado na versão $versaoAtual. Nenhuma ação necessária."
}

# -------------------- FIM DO SCRIPT --------------------
