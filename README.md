[![CI](https://github.com/guidugli/ansible-role-bootstrap/actions/workflows/CI.yml/badge.svg)](https://github.com/guidugli/ansible-role-bootstrap/actions/workflows/CI.yml)
[![Release](https://img.shields.io/github/v/tag/guidugli/ansible-role-bootstrap?display_name=tag&sort=semver)](https://github.com/guidugli/ansible-role-bootstrap/tags)
[![Galaxy](https://img.shields.io/badge/galaxy-guidugli.bootstrap-blue)](https://galaxy.ansible.com/ui/standalone/roles/guidugli/bootstrap/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

# Ansible Role: bootstrap

Bootstraps supported Linux hosts with the minimum Python runtime and package-manager bindings required for normal Ansible module execution. The role is suitable for first-touch provisioning, minimal images, and root-running container tests.

## Requirements

- Ansible Core 2.14 or newer, as declared by role metadata.
- A supported target with `apt-get`, `dnf5`, `dnf`, or `yum`.
- A POSIX shell and the package manager's native query command.
- Root-level package-management permission supplied externally by the caller.
- `containers.podman` 1.10.0 or newer for the bundled Molecule scenarios.

## Features

- Detects the package manager before Python is available.
- Installs Python 3 and the package-manager bindings needed by Ansible.
- Optionally discovers whether SSH is reachable on port 22 or the inventory-defined port.
- Supports extra bootstrap packages with strict package-name validation.
- Uses deterministic package lists and reports changes only when installation occurs.
- Keeps privilege escalation outside the role.

## Supported platforms

The shared Molecule matrix covers Ubuntu 26.04 and 24.04, Debian 13 and 12, and Fedora 44 and 43. Generated Galaxy metadata is controlled by `molecule/shared/vars.yml` and `templates/meta_main.yml.j2`.

## Variables

All public inputs are defined in `defaults/main.yml` and mirrored by `meta/argument_specs.yml`.

| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| `bootstrap_detect_ssh_port` | `bool` | `true` | Checks port 22 and the inventory-defined SSH port from the controller before deferred fact gathering. It runs only for `ssh` and `paramiko` connections. Set it to `false` for direct container transports. |
| `bootstrap_fail_on_unknown_pkg_mgr` | `bool` | `true` | Fails when the detected package manager is not in the supported internal package map. When `false`, no package installation is attempted for an unknown backend. |
| `bootstrap_extra_packages` | `list[str]` | `[]` | Adds packages after the backend-specific bootstrap set. Entries must be non-empty package names containing letters, digits, plus, underscore, period, colon, or hyphen. |

Internal variable `_bootstrap_packages` maps each supported backend to its required Python packages and is not a caller-facing input.

## Example playbook

```yaml
---
- name: Bootstrap Linux hosts
  hosts: all
  gather_facts: false
  become: true
  roles:
    - role: guidugli.bootstrap
      vars:
        bootstrap_extra_packages:
          - ca-certificates
```

For a direct Podman connection, set `bootstrap_detect_ssh_port: false` and omit `become` when the container already runs as root.

## Molecule testing instructions

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
ansible-galaxy collection install -r requirements.yml
molecule test -s default
molecule test -s systemd
```

The shared converge play disables SSH port detection for container transports. The shared verify play checks Python availability and verifies the backend-specific package set through package facts.

## Execution notes

- **Privilege model:** The role never sets `become`, `become_user`, or `become_method`. Package installation requires the caller to provide sufficient privileges. Use `become: true` in real-host plays when required.
- **Container behavior:** Molecule containers execute as root and therefore do not need privilege escalation. SSH port detection is disabled in the shared converge play because the Podman connection does not use SSH.
- **Systemd behavior:** The role does not manage services, units, mounts, sysctl values, or init state. The systemd scenario still exercises the role in a systemd-capable container, while restricted scenario files remain generator-compatible.
- **Bootstrap behavior:** Raw commands are intentional because Python may not exist yet. Each install path first queries package state and uses explicit `changed_when` handling.

## Release workflow

Generated metadata and scenario inventories are refreshed by the repository scripts before a release:

```bash
./scripts/update_release_metadata.sh
./scripts/release.sh --version v1.2.0 --message "Release v1.2.0"
```

The metadata generator reads the shared platform matrix and renders `meta/main.yml`. Do not edit generated outputs directly.

## License

MIT

## Author

Carlos Guidugli
