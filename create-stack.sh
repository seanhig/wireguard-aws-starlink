aws cloudformation create-stack --stack-name wireguard-vpn \
    --template-body file://wireguard-cf.yml \
    --parameters file://wireguard-params.json
