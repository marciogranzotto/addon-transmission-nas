#!/usr/bin/with-contenv bashio
# ==============================================================================

declare CONFIG
declare authentication_required
declare username
declare password
declare download_dir

if ! bashio::fs.directory_exists '/data/transmission'; then
  mkdir '/data/transmission'
fi

if ! bashio::fs.file_exists '/data/transmission/settings.json'; then
  echo "{}" > /data/transmission/settings.json
fi

CONFIG=$(</data/transmission/settings.json)

# Defaults
CONFIG=$(bashio::jq "${CONFIG}" ".\"incomplete-dir-enabled\"=false")
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-whitelist-enabled\"=false")
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-host-whitelist-enabled\"=false")
CONFIG=$(bashio::jq "${CONFIG}" ".\"bind-address-ipv4\"=\"0.0.0.0\"")

download_dir="/share/plex"
if bashio::config.has_value 'networkdisks'; then
    MOREDISKS=$(bashio::config 'networkdisks')
    for disk in $MOREDISKS 
    do
      download_dir=$disk
      bashio::log.info "Setting default download folder to: ${download_dir}"
      break 
    done
fi

CONFIG=$(bashio::jq "${CONFIG}" ".\"download-dir\"=\"${download_dir}\"")


authentication_required=$(bashio::config 'authentication_required')
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-authentication-required\"=${authentication_required}")


username=$(bashio::config 'username')
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-username\"=\"${username}\"")


password=$(bashio::config 'password')
CONFIG=$(bashio::jq "${CONFIG}" ".\"rpc-password\"=\"${password}\"")

echo "${CONFIG}" > /data/transmission/settings.json
