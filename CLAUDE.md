# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Home Assistant add-on that runs the Transmission BitTorrent daemon with two extras: optional OpenVPN tunneling, and mounting CIFS/Samba network shares as the download target. It is a fork of the upstream Transmission add-on; the *NAS* additions are the CIFS mount logic in `services.d/transmission/run` and the `networkdisks` / `cifs*` config options.

There is no application source code — the add-on is built entirely from configuration, shell scripts (bashio), nginx config, and AppArmor rules layered on top of `ghcr.io/hassio-addons/base` (Alpine + s6-overlay).

## Build / test commands

Builds use Home Assistant's `homeassistant/amd64-builder` Docker image — it cross-builds the addon for the target arch using `build.json` + `config.json`. To build a single arch locally for testing:

```sh
docker run --rm --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.docker:/root/.docker \
  -v "$(pwd)":/data \
  homeassistant/amd64-builder -t transmission-nas --amd64 --test
```

Replace `--amd64` with `--armv7 | --aarch64 | --i386 | --armhf` for other arches (all five are built in CI). Lint the Dockerfile with `docker run --rm -i hadolint/hadolint < transmission-nas/Dockerfile`.

CI runs `hadolint` + a multi-arch test build on every PR (`.github/workflows/test.yml`); a GitHub release triggers `.github/workflows/publish.yml`, which builds + pushes images to Docker Hub (`marciogranzotto/addon-transmission-nas-{arch}`) and then dispatches the `marciogranzotto/addons-repository` updater.

## Release flow — important

**Do not bump `transmission-nas/config.json` `version` manually for a release.** The publish workflow uses `patch-files-action` to overwrite that field with the GitHub release tag (with the leading `v` stripped) at build time. The version committed to master is the "in-development" version. Cutting a release = creating a GitHub release with tag `vX.Y.Z`; everything else is automatic.

## Architecture — how the container is wired

1. **`Dockerfile`** installs pinned Alpine packages (transmission-daemon, openvpn, nginx, cifs-utils) and copies the `rootfs/` overlay over the base image. It also patches `/usr/share/transmission/web/javascript/remote.js` with a `sed` so the web UI resolves the RPC endpoint correctly under Home Assistant ingress (which strips the `/transmission/` URL prefix that Transmission normally relies on). If you touch the Transmission package version or that `remote.js` path, re-verify this sed still matches.

2. **s6-overlay init phase** (`rootfs/etc/cont-init.d/*`) — runs once at startup in filename order:
   - `10-requirements.sh` — validates user config (`authentication_required` ⇒ user/pass, `openvpn_enabled` ⇒ creds + ovpn file exists).
   - `20-transmission-configuration.sh` — merges Home Assistant addon options into `/data/transmission/settings.json` using `bashio::jq`. Settings.json is preserved across restarts because `/data` is the addon's persistent volume. If `networkdisks` is set, the **first** entry becomes Transmission's `download-dir`.
   - `21-openvpn-configuration.sh` — copies user's `.ovpn` from `/config/openvpn/`, writes credentials, injects a hook into `up.sh` that calls `up-transmission.sh`.
   - `30-nginx.sh` — templates `ingress.conf` with the assigned ingress IP + port from `bashio::addon.ingress_*`.

3. **s6-overlay services** (`rootfs/etc/services.d/*`) — long-running:
   - `transmission/run` — mounts each entry in `networkdisks` via `mount -t cifs` (path on host = `/<server>/<share>`, matching the config notation), then `exec`s either openvpn (which itself launches transmission via the up-script) or `transmission-daemon` directly.
   - `nginx/run` — waits for Transmission's port 9091, then runs nginx in the foreground.

4. **VPN ↔ Transmission interaction** — when OpenVPN is enabled, `transmission/run` execs *openvpn* instead of transmission. OpenVPN's up-script (`/etc/openvpn/up-transmission.sh`) receives the tun interface address as `$4`, writes it into `settings.json` as `bind-address-ipv4`, and *then* execs transmission. This binds Transmission to the VPN interface so torrent traffic can't leak if the tunnel drops. Don't "simplify" this by starting transmission in parallel with openvpn.

5. **Nginx + ingress** — `ingress.conf` is the only enabled server. It rewrites `/` → upstream `/transmission/web/`, plus passthrough for `/rpc` and `/upload`. The `direct.conf` / `direct-ssl.disabled` switcheroo in `30-nginx.sh` only kicks in if the user explicitly maps port 80 — normal usage is ingress-only on port 8099.

## Network share mount — non-obvious constraints

CIFS mounts require capabilities that Home Assistant's "Protection Mode" blocks. The README documents this loudly: **Protection Mode must be disabled** for `networkdisks` to work. This is also why `config.json` declares `privileged: ["SYS_ADMIN", "DAC_READ_SEARCH"]`, `full_access: true`, and `apparmor: true` with a custom profile (`transmission-nas/apparmor.txt`) that explicitly allows `mount`/`umount`/`remount`. When changing mount behavior, verify the AppArmor profile still permits the operation — capability changes need matching entries in both `config.json` and `apparmor.txt`.

`cifsversion` is an optional dropdown (3.0 / 2.1 / 2.0 / 1.0) appended as `,vers=…` to the mount options when present; some NAS devices need a specific SMB protocol version.

## Config schema lives in `config.json`

The `options` block defines defaults shown to users; the `schema` block defines validation (Home Assistant rejects invalid configs before starting the addon). When adding a new user-facing option you must update **both** (`options` and `schema`), expose it via `bashio::config 'key'` in the init scripts, and document it in `README.md`.

## Style / lint

- `.yamllint` enforces YAML style; `.editorconfig` enforces whitespace; `.mdlrc` configures markdownlint.
- Shell scripts use the `#!/usr/bin/with-contenv bashio` shebang and the [`bashio`](https://github.com/hassio-addons/bashio) helper library (`bashio::config`, `bashio::log.*`, `bashio::jq`, `bashio::fs.*`, etc.) — prefer these over raw `jq` / `echo` / `test` for consistency with the rest of the codebase.
