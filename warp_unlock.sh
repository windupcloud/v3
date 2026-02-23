#!/usr/bin/env bash
# 更换为非自制剧(版权剧)进行检测，以区分"仅自制剧"和"完美解锁"
# URL1: Breaking Bad (绝命毒师)
NETFLIX_URL1="https://www.netflix.com/title/81278456"
# URL2: Better Call Saul (风骚律师)
NETFLIX_URL2="https://www.netflix.com/title/81726714"
NETFLIX_INTERFACE="WARPv6"
NETFLIX_USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
NETFLIX_MAX_TIME=10

# Debug mode check
DEBUG=false
if [[ "$1" == "-debug" ]]; then
  DEBUG=true
  echo "Debug mode enabled. Showing detailed detection info."
fi

netflix_check() {
  local result1 result2 body1 body2
  
  # --- 检测 URL 1 ---
  local tmp_body1="/tmp/nf_check_1.html"
  
  result1=$(curl --interface "$NETFLIX_INTERFACE" -6 --user-agent "$NETFLIX_USER_AGENT" -fsL \
    --write-out "%{http_code}|%{url_effective}" --output "$tmp_body1" --max-time "$NETFLIX_MAX_TIME" "$NETFLIX_URL1" || echo "000|error")
  
  if $DEBUG; then echo "[Debug] URL1 Result: $result1"; fi

  if [[ "$result1" == "200|"*"/title/"* ]]; then
    if grep -qE '"@type":"VideoObject"|"trailer"|contentUrl' "$tmp_body1"; then
       if $DEBUG; then echo "[Debug] URL1 Content check passed (Found VideoObject/Trailer info)."; fi
       rm -f "$tmp_body1"
       return 0
    else
       if $DEBUG; then echo "[Debug] URL1 Content check failed (No VideoObject found)."; fi
    fi
  else
    if $DEBUG; then echo "[Debug] URL1 Redirected or Failed."; fi
  fi
  rm -f "$tmp_body1"

  # --- 检测 URL 2 (备用) ---
  local tmp_body2="/tmp/nf_check_2.html"
  
  result2=$(curl --interface "$NETFLIX_INTERFACE" -6 --user-agent "$NETFLIX_USER_AGENT" -fsL \
    --write-out "%{http_code}|%{url_effective}" --output "$tmp_body2" --max-time "$NETFLIX_MAX_TIME" "$NETFLIX_URL2" || echo "000|error")
  
  if $DEBUG; then echo "[Debug] URL2 Result: $result2"; fi

  if [[ "$result2" == "200|"*"/title/"* ]]; then
    if grep -qE '"@type":"VideoObject"|"trailer"|contentUrl' "$tmp_body2"; then
       if $DEBUG; then echo "[Debug] URL2 Content check passed (Found VideoObject/Trailer info)."; fi
       rm -f "$tmp_body2"
       return 0
    fi
  fi
  rm -f "$tmp_body2"

  return 1
}

warp_restart() {
  echo "start重启"
  if ip link show dev WARPv6 >/dev/null 2>&1; then
    rm -f /opt/warp-go/wgcf-account.toml
    k=0
    until [[ -e /opt/warp-go/wgcf-account.toml ]]; do
      echo "$k"
      ((k++)) || true
      if [[ $k -ge 11 ]]; then
        rm -f /opt/warp-go/wgcf-account.toml
        echo -e " Failed to register warp account. Script aborted. "
        exit 1
      fi
      wgcf register --accept-tos --config /opt/warp-go/wgcf-account.toml >/dev/null 2>&1
      [[ $? != 0 ]] && sleep 30
    done
    echo "注册完成"
    access_token=$(awk -F "'" '/^access_token/ {print $2}' /opt/warp-go/wgcf-account.toml)
    device_id=$(awk -F "'" '/^device_id/ {print $2}' /opt/warp-go/wgcf-account.toml)
    private_key=$(awk -F "'" '/^private_key/ {print $2}' /opt/warp-go/wgcf-account.toml)

    sed -i "s/^Device[[:space:]]*=.*/Device = ${device_id}/" /opt/warp-go/warp.conf
    sed -i "s/^PrivateKey[[:space:]]*=.*/PrivateKey = ${private_key}/" /opt/warp-go/warp.conf
    sed -i "s/^Token[[:space:]]*=.*/Token = ${access_token}/" /opt/warp-go/warp.conf

    pm2 restart warpv6
    ss -nltp | grep 'dnsmasq' >/dev/null 2>&1 && systemctl restart dnsmasq >/dev/null 2>&1
    sleep 30
  else
    echo "未找到WARP网卡"
    pm2 restart warpv6
    sleep 2
    ss -nltp | grep 'dnsmasq' >/dev/null 2>&1 && systemctl restart dnsmasq >/dev/null 2>&1
    sleep 2
  fi
  echo "restart结束"
}

while true
  do
  echo 'Script runs.'
  if netflix_check; then
    echo "yes" > /root/nf.log
    echo "解锁"
    sleep 1800s
  else
    echo "no" > /root/nf.log
    echo "不解锁"
    warp_restart
    sleep 120s
  fi
done
