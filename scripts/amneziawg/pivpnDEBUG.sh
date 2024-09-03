#!/bin/bash

### Constants

setupVars="/etc/pivpn/amneziawg/setupVars.conf"

# shellcheck disable=SC1090
source "${setupVars}"

### Funcions

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

### Script

# This scripts runs as root
if [[ ! -f "${setupVars}" ]]; then
  err "::: Missing setup vars file!"
  exit 1
fi

echo -e "::::\t\t\e[4mPiVPN debug\e[0m\t\t ::::"
printf "=============================================\n"
echo -e "::::\t\t\e[4mLatest commit\e[0m\t\t ::::"
echo -n "Branch: "

git --git-dir /usr/local/src/pivpn/.git rev-parse --abbrev-ref HEAD
git \
  --git-dir /usr/local/src/pivpn/.git log -n 1 \
  --format='Commit: %H%nAuthor: %an%nDate: %ad%nSummary: %s'

printf "=============================================\n"
echo -e "::::\t    \e[4mInstallation settings\e[0m    \t ::::"

# Disabling SC2154 warning, variable is sourced externaly and may vary
# shellcheck disable=SC2154
sed "s/${pivpnHOST}/REDACTED/" < "${setupVars}"

printf "=============================================\n"
echo -e "::::  \e[4mServer configuration shown below\e[0m   ::::"

cd /etc/amnezia/amneziawg/keys || exit
cp ../amn0.conf ../amn0.tmp

# Replace every key in the server configuration with just its file name
for k in *; do
  sed "s#$(< "${k}")#${k}#" -i ../amn0.tmp
done

cat ../amn0.tmp
rm ../amn0.tmp

printf "=============================================\n"
echo -e "::::  \e[4mClient configuration shown below\e[0m   ::::"

EXAMPLE="$(head -1 /etc/amnezia/amneziawg/configs/clients.txt | awk '{print $1}')"

if [[ -n "${EXAMPLE}" ]]; then
  cp ../configs/"${EXAMPLE}".conf ../configs/"${EXAMPLE}".tmp

  for k in *; do
    sed "s#$(< "${k}")#${k}#" -i ../configs/"${EXAMPLE}".tmp
  done

  sed "s/${pivpnHOST}/REDACTED/" < ../configs/"${EXAMPLE}".tmp
  rm ../configs/"${EXAMPLE}".tmp
else
  echo "::: There are no clients yet"
fi

printf "=============================================\n"
echo -e ":::: \t\e[4mRecursive list of files in\e[0m\t ::::"
echo -e "::::\t\e[4m/etc/amnezia/amneziawg shown below\e[0m\t ::::"

ls -LR /etc/amnezia/amneziawg

printf "=============================================\n"
echo -e "::::\t\t\e[4mSelf check\e[0m\t\t ::::"

/opt/pivpn/self_check.sh "${VPN}"

printf "=============================================\n"
echo -e ":::: Having trouble connecting? Take a look at the FAQ:"
echo -e ":::: \e[1mhttps://docs.pivpn.io/faq\e[0m"
printf "=============================================\n"
echo -ne ":::: \e[1mWARNING\e[0m: This script should have "
echo -e "automatically masked sensitive       ::::"
echo -ne ":::: information, however, still make sure that "
echo -e "\e[4mPrivateKey\e[0m, \e[4mPublicKey\e[0m      ::::"
echo -ne ":::: and \e[4mPresharedKey\e[0m are masked before "
echo -e "reporting an issue. An example key ::::"
echo -n ":::: that you should NOT see in this log looks like this:"
echo "                  ::::"
echo -n ":::: YIAoJVsdIeyvXfGGDDadHh6AxsMRymZTnnzZoAb9cxRe"
echo "                          ::::"
printf "=============================================\n"
echo -e "::::\t\t\e[4mDebug complete\e[0m\t\t ::::"
