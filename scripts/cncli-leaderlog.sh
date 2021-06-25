#!/usr/bin/env bash

epoch="${1:-next}"
timezone="${2:-UTC}"

function getStatus() {
    local result
    result=$(/usr/local/bin/cncli status \
        --db /root/scripts/cncli.db \
        --byron-genesis /home/cardano/files/mainnet-byron-genesis.json \
        --shelley-genesis /home/cardano/files/mainnet-shelley-genesis.json \
        | jq -r .status
    )
    echo "$result"
}

function getLeader() {
    /usr/local/bin/cncli leaderlog \
        --db /root/scripts/cncli.db \
        --pool-id \
        --pool-vrf-skey /home/cardano/files/vrf.skey \
        --byron-genesis /home/cardano/files/mainnet-byron-genesis.json \
        --shelley-genesis /home/cardano/files/mainnet-shelley-genesis.json \
        --ledger-set "$epoch" \
        --tz "$timezone"
}

statusRet=$(getStatus)

if [[ "$statusRet" == "ok" ]]; then
    mv /root/scripts/leaderlog.json /root/scripts/leaderlog."$(date +%F-%H%M%S)".json
    getLeader > /root/scripts/leaderlog.json
    find . -name "leaderlog.*.json" -mtime +15 -exec rm -f '{}' \;
else
    echo "CNCLI database not synced!!!"
fi

exit 0
