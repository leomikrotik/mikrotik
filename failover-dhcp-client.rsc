#  Script para failover quando o link e DHCP Client
#  SIXCORE - Leonardo Vieira
#  Whatsapp (31) 99739-3126
# 
# Desative no dhcp client a opcao de add rota default e use rota recursiva
#
######################################################################################
{
    :local count [/ip route print count-only where comment="Monitoramento-NET"]
    :if ($bound=1) do={
        :if ($count = 0) do={
            /ip route add ds=8.8.4.4 gateway=$"gateway-address" comment="Monitoramento-NET" scope=10
        } else={
            :if ($count = 1) do={
                :local test [/ip route find where comment="Monitoramento-NET"]
                :if ([/ip route get $test gateway] != $"gateway-address") do={
                    /ip route set $test gateway=$"gateway-address"
                }
            } else={
                :error "Multiple routes found"
            }
        }
    } else={
        /ip route remove [find comment="Monitoramento-NET"]
    }
}
