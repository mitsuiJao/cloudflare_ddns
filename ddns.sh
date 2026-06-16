#!/bin/bash

cd $(dirname $0)

source ./.env

# IPアドレス取得サービスのリスト
services=(
  "https://api.ipify.org/"
  "https://checkip.amazonaws.com/"
  "https://ipv4.icanhazip.com/"
  "https://4.icanhazip.com/"
)

ip_address=""

# IPアドレスを取得する関数
get_ip_address() {
  local url="$1"
  ip_address=$(curl -s "$url")
}

# IPアドレスの正規表現パターン
ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

# 正規表現でIPアドレスが検証できるかチェック
is_valid_ip() {
  [[ $ip_address =~ $ip_pattern ]]
}

# IPアドレス取得のループ
for service in "${services[@]}"; do
  get_ip_address "$service"

  if is_valid_ip; then
    break
  fi
done

# ipアドレス更新テスト
# ip_address = 8.8.8.8

# CloudFlare API Aレコード更新
curl --request PUT \
  --url https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID \
  --header 'Content-Type: application/json' \
  --header "X-Auth-Email: $EMAIL" \
  --header "Authorization: Bearer $TOKEN" \
  --data '{
    "content": "'"$ip_address"'",
    "name": "'"$DOMAIN"'",
    "proxied": false,
    "type": "A",
    "comment": "Domain verification record"
  }'>> ./ddns.log 2>&1
