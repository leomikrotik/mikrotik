#!/usr/bin/env bash
# Lista nós do PNETLab (processos qemu) e pergunta se deseja encerrá-los.

set -euo pipefail

# Coleta qemu ligados ao PNETLab (unetlab/pnetlab nos argumentos do processo).
mapfile -t qemu_procs < <(pgrep -a -f 'qemu-system.*(unetlab|pnetlab)' || true)

if [[ ${#qemu_procs[@]} -eq 0 ]]; then
  echo "Nenhum nó do PNETLab em execução com qemu."
  exit 0
fi

echo "Nós do PNETLab em execução:"
for entry in "${qemu_procs[@]}"; do
  pid=${entry%% *}
  cmd=${entry#* }

  # Tenta extrair o nome do nó a partir do parâmetro -name, se existir.
  node_name=$(sed -n 's/.*-name[[:space:]]\([^[:space:]]*\).*/\1/p' <<<"$cmd")
  [[ -z $node_name ]] && node_name="(sem -name, ver comando abaixo)"

  echo
  echo "PID: $pid"
  echo "Nó: $node_name"
  echo "CMD: $cmd"

  read -r -p "Deseja desligar este nó? [s/N] " answer
  if [[ $answer =~ ^[sSyY]$ ]]; then
    if kill -SIGTERM "$pid"; then
      echo "Sinal SIGTERM enviado para $pid."
    else
      echo "Falha ao enviar sinal para $pid."
    fi
  else
    echo "Nó mantido em execução."
  fi
done
