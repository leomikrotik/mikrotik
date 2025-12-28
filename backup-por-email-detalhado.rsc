# Script de Backup Automatizado RouterOS v7
# Autor: Leonardo Vieira - Sistema de Backup Sixcore
# Descricao: Realiza backup completo e envia por e-mail

:local identity [/system identity get name];
:local date [/system clock get date];
:local time [/system clock get time];
:local dateFormatted ([:pick $date 7 11] . [:pick $date 0 3] . [:pick $date 4 6]);
:local backupName ($identity . "-" . $dateFormatted);
:local version [/system resource get version];
:local model [/system resource get board-name];

# Configuracoes de e-mail (AJUSTE CONFORME SEU SERVIDOR)
:local emailTo "seu-email@example.com";
:local emailSubject ("Backup " . $identity . " - " . $date);
:local emailBody ("Backup RouterOS\r\n\r\n" . \
"Roteador: " . $identity . "\r\n" . \
"Versao RouterOS: " . $version . "\r\n" . \
"Modelo: " . $model . "\r\n" . \
"Data/Hora: " . $date . " " . $time . "\r\n\r\n" . \
"Backup realizado com sucesso!\r\n\r\n" . \
"Sixcore - sixcore.com.br");

:do {
    # Remove backups anteriores
    :log info "Removendo backups anteriores...";
    :foreach i in=[/file find where name~".backup"] do={/file remove $i};
    :foreach i in=[/file find where name~".rsc"] do={/file remove $i};
    
    # Aguarda remocao dos arquivos
    :delay 2s;
    
    # Cria arquivo .backup
    :log info "Criando arquivo .backup...";
    /system backup save name=$backupName dont-encrypt=no;
    
    # Aguarda criacao do backup
    :delay 3s;
    
    # Cria arquivo de exportacao .rsc
    :log info "Criando arquivo de exportacao .rsc...";
    /export terse show-sensitive file=$backupName;
    
    # Aguarda criacao da exportacao
    :delay 3s;
    
    # Envia arquivos por e-mail
    :log info "Enviando backup por e-mail...";
    /tool e-mail send to=$emailTo subject=$emailSubject body=$emailBody file=($backupName . ".backup",$backupName . ".rsc");
    
    # Aguarda envio do e-mail
    :delay 5s;
    
    # Remove arquivos apos envio
    :log info "Removendo arquivos locais apos envio...";
    /file remove ($backupName . ".backup");
    /file remove ($backupName . ".rsc");
    
    :log info ("Backup concluido com sucesso! Arquivos enviados para " . $emailTo);
    
} on-error={
    :log error "ERRO ao realizar backup! Verifique as configuracoes.";
}