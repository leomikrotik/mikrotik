# Script de Controle de Banda Automático para DHCP Leases
# Autor: Leonardo Vieira - sixcore.com.br Treinamentos de Redes
# RouterOS v7 - MikroTik
# Cria e gerencia Simple Queues baseadas em leases DHCP ativos

# ===== PARTE 1: PROCESSAR LEASES DHCP E CRIAR/ATUALIZAR QUEUES =====
/ip/dhcp-server/lease;

:foreach lease in=[find] do={
    # Obter informações do lease
    :local leaseAddr ([get $lease address] . "/32");
    :local leaseMac [get $lease mac-address];
    :local leaseHostname [get $lease host-name];
    :local leaseComment [get $lease comment];
    :local leaseInQueue false;
    
    # Processar queues existentes
    /queue/simple;
    :foreach queue in=[find] do={
        :local queueTarget [get $queue target];
        :local queueComment [get $queue comment];
        
        # Verificar se o comentário tem o formato esperado (mínimo 21 caracteres)
        :if ([:len $queueComment] >= 21) do={
            # Extrair MAC e Hostname do comentário
            :local queuePrefix [:pick $queueComment 0 4];
            
            :if ($queuePrefix = "ctti") do={
                :local queueMac [:pick $queueComment 5 22];
                :local queueHostname [:pick $queueComment 23 [:len $queueComment]];
                
                # CASO 1: MAC corresponde - atualizar IP e informações
                :if ($queueMac = $leaseMac) do={
                    :local newComment ("ctti," . $leaseMac . "," . $leaseHostname);
                    :local newName;
                    
                    # Definir nome da queue
                    :if ([:len $leaseComment] > 0) do={
                        :set newName ($leaseComment . " (" . $leaseMac . ")");
                    } else={
                        :if ([:len $leaseHostname] > 0) do={
                            :set newName ($leaseHostname . " (" . $leaseMac . ")");
                        } else={
                            :set newName $leaseMac;
                        }
                    }
                    
                    # Atualizar queue
                    set $queue target=$leaseAddr comment=$newComment name=$newName;
                    :set leaseInQueue true;
                }
                
                # CASO 2: IP corresponde mas MAC diferente - atualizar MAC e resetar
                :if ($queueTarget = $leaseAddr && $queueMac != $leaseMac) do={
                    :local newComment ("ctti," . $leaseMac . "," . $leaseHostname);
                    :local newName;
                    
                    # Definir nome da queue
                    :if ([:len $leaseComment] > 0) do={
                        :set newName ($leaseComment . " (" . $leaseMac . ")");
                    } else={
                        :if ([:len $leaseHostname] > 0) do={
                            :set newName ($leaseHostname . " (" . $leaseMac . ")");
                        } else={
                            :set newName $leaseMac;
                        }
                    }
                    
                    # Atualizar queue e resetar contadores
                    set $queue comment=$newComment name=$newName;
                    reset-counters $queue;
                    :set leaseInQueue true;
                }
            }
        }
    }
    
    # CASO 3: Lease não tem queue - criar nova
    :if ($leaseInQueue = false) do={
        :local newComment ("ctti," . $leaseMac . "," . $leaseHostname);
        :local newName;
        
        # Definir nome da queue
        :if ([:len $leaseComment] > 0) do={
            :set newName ($leaseComment . " (" . $leaseMac . ")");
        } else={
            :if ([:len $leaseHostname] > 0) do={
                :set newName ($leaseHostname . " (" . $leaseMac . ")");
            } else={
                :set newName $leaseMac;
            }
        }
        
        # Criar nova queue
        /queue/simple/add \
            target=$leaseAddr \
            max-limit=100M/100M \
            comment=$newComment \
            name=$newName;
        
        :log info ("Queue criada para: " . $newName);
    }
}

# ===== PARTE 2: LIMPAR QUEUES DE LEASES INATIVOS =====
/queue/simple;

:foreach queue in=[find] do={
    :local queueComment [get $queue comment];
    :local queueName [get $queue name];
    
    # Verificar se é uma queue gerenciada (prefixo "ctti")
    :if ([:len $queueComment] >= 21) do={
        :local queuePrefix [:pick $queueComment 0 4];
        
        :if ($queuePrefix = "ctti") do={
            :local queueMac [:pick $queueComment 5 22];
            
            # Verificar se o MAC ainda existe nos leases ativos
            :if ([/ip/dhcp-server/lease/find mac-address=$queueMac] = "") do={
                :log info ("Removendo queue obsoleta: " . $queueName . " (MAC: " . $queueMac . ")");
                remove $queue;
            }
        }
    }
}