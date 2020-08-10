# This is a fork that supports mounting network drives through Samba Share

[![GitHub Release][releases-shield]][releases]
[![License][license-shield]](LICENSE.md)

![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports i386 Architecture][i386-shield]

![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

If you want to mount an USB drive on Home Assistant and share it on the network, check out [Samba NAS Add-On by dianlight](https://github.com/dianlight/hassio-addons/tree/master/sambanas)

**PROTECTION MODE NEEDS TO BE DISABLED FOR NETWORK DRIVES TO WORK**

# Transmission NAS addon for Home Assistant

The torrent client for Home Assistant with OpenVPN and Samba Share support.

![Logo](transmission-nas/logo.png?raw=true "Logo")

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Home Assistant add-on.

1. [Add our Home Assistant add-ons repository][repository] to your Home Assistant instance.
1. Install the "Transmission NA" add-on.
1. Change the configuration files with the required values.
1. Start the "Transmission NA" add-on
1. Check the logs of the "Transmission NA" add-on to see if everything went well.
1. Click "OPEN WEB UI" to open the Transmission NA web interface.

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Transmission add-on configuration:

```yaml
log_level: info
authentication_required: false
username: 'your_username'
password: 'your_password'
openvpn_enabled: false
openvpn_config: ''
openvpn_username: ''
openvpn_password: ''
networkdisks:
  - //serverip/folder
cifsusername: 'your samba user'
cifspassword: 'password'
```

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`:  Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

### Option: `authentication_required`

This option can be used to password protect the web-ui.

### Option: `username`

The username for authentication.

### Option: `password`

The password for authentication.

### Option: `openvpn_enabled`

Enable OpenVPN to anonymize your torrent activity.

### Option: `openvpn_config`

The name of .ovpn file. You should put it in `/config/openvpn`.

### Option: `openvpn_username`

Your OpenVPN username.

### Option: `openvpn_password`

Your OpenVPN password.

### Option: `networkdisks`  

**PROTECTION MODE NEEDS TO BE DISABLED TO WORK**

Is the list of networks share to mount at boot. The mounted driver is on `/<SERVER>/<SHARE>` directory.

#### Option: `cifsusername` 

The username to use to mount the network shares

#### Option: `cifspassword` 

The password used to mount the networks shares


## Embedding into Home Assistant

This addon supports ingress, thus it can simply be integrated into Home Assistant without having to forward any additional ports.
Here is an example configuration:

```yaml
transmission:
  host: 1dd81675_transmission-nas
```

If you want, you can add an icon to the sidebar by toggling *Show in Sidebar* as well.

## Changelog & Releases

The format of the log is based on
[Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

Releases are based on [Semantic Versioning](http://semver.org/spec/v2.0.0.html), and use the format
of ``MAJOR.MINOR.PATCH``. In a nutshell, the version will be incremented
based on the following:

- ``MAJOR``: Incompatible or major changes.
- ``MINOR``: Backwards-compatible new features and enhancements.
- ``PATCH``: Backwards-compatible bugfixes and package updates.

## License

MIT License

Copyright (c) 2018 Pierrick Rouxel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[anchore-shield]: https://anchore.io/service/badges/image/67d1185473090e99d5ac5e1bb4d1aa2295117a9bd3d7abbf8cd8a71e331c8388
[anchore]: https://anchore.io/image/dockerhub/marciogranzotto%2Funifi%3Alatest
[armhf-shield]:  https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg
[buymeacoffee]: https://www.buymeacoffee.com/automarcio
[commits-shield]: https://img.shields.io/github/commit-activity/y/marciogranzotto/addon-transmission-nas.svg
[commits]: https://github.com/marciogranzotto/addon-transmission-nas/commits/master
[contributors]: https://github.com/marciogranzotto/addon-transmission-nas/graphs/contributors
[dockerhub]: https://hub.docker.com/r/marciogranzotto/transmission-nas
[home-assistant]: https://home-assistant.io
[issue]: https://github.com/marciogranzotto/addon-transmission-nas/issues
[keepchangelog]: http://keepachangelog.com/en/1.0.0/
[license-shield]: https://img.shields.io/github/license/marciogranzotto/addon-transmission-nas.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2020.svg
[releases-shield]: https://img.shields.io/github/release/marciogranzotto/addon-transmission-nas.svg
[releases]: https://github.com/marciogranzotto/addon-transmission-nas/releases
[repository]: https://github.com/marciogranzotto/addons-repository
[cgm-remote-monitor]: https://github.com/transmission-nas/cgm-remote-monitor
[marciogranzotto]: https://github.com/marciogranzotto
