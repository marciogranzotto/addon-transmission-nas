#!/usr/bin/with-contenv bashio
# ==============================================================================
# This files check if all user configuration requirements are met
# ==============================================================================

# Check authentication requirements, if enabled
if bashio::config.true 'authentication_required'; then
    if ! bashio::config.has_value 'username'; then
        bashio::log.fatal 'Transmission authentication is enabled, but no username was specified'
        bashio::exit.nok
    fi

    if ! bashio::config.has_value 'password'; then
        bashio::log.fatal 'Transmission authentication is enabled, but no password was specified'
        bashio::exit.nok
    fi
fi

# Check OpenVPN requirements, if enabled
if bashio::config.true 'openvpn_enabled'; then
    if ! bashio::config.has_value 'openvpn_username'; then
        bashio::log.fatal 'OpenVPN is enabled, but no username was specified'
        bashio::exit.nok
    fi

    if ! bashio::config.has_value 'openvpn_password'; then
        bashio::log.fatal 'OpenVPN is enabled, but no password was specified'
        bashio::exit.nok
    fi

    if ! bashio::fs.file_exists "/config/openvpn/$(bashio::config 'openvpn_config').ovpn"; then
        bashio::log.fatal "The configured /config/openvpn/$(bashio::config 'openvpn_config').ovpn file is not found"
        bashio::exit.nok
    fi
fi
