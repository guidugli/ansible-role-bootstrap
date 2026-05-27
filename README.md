# Ansible Role: bootstrap

[![CI](https://github.com/guidugli/ansible-role-bootstrap/actions/workflows/CI.yml/badge.svg)](https://github.com/guidugli/ansible-role-bootstrap/actions/workflows/CI.yml)
[![Release](https://github.com/guidugli/ansible-role-bootstrap/actions/workflows/release.yml/badge.svg)](https://github.com/guidugli/ansible-role-bootstrap/actions/workflows/release.yml)
[![Galaxy](https://img.shields.io/badge/galaxy-guidugli.bootstrap-blue)](https://galaxy.ansible.com/guidugli/bootstrap)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Overview

This role bootstraps a Linux host so Ansible can manage it using Python-based modules.

It installs the minimum Python runtime and package-manager bindings required for Ansible to operate. It is designed for:

- fresh servers  
- minimal OS images  
- container environments  
- first-touch provisioning  

---

## Features

- Detects package manager using raw shell (no Python required)  
- Installs required Python runtime and bindings for:
  - apt  
  - dnf  
  - dnf5  
  - yum  
- Works across Ubuntu, Debian, and Fedora  
- Supports SSH and container (Podman/Molecule) environments  
- Idempotent and fully Molecule tested  
- Clean separation of concerns (role does not enforce become)  

---

## Supported Platforms

| Distribution | Versions |
|--------------|---------|
| Ubuntu       | Latest 2 LTS |
| Debian       | Stable + Oldstable |
| Fedora       | Latest 2 supported |

---

## Requirements

None (bootstrap-safe by design).

---

## Role Variables

### `bootstrap_detect_ssh_port`

```yaml
bootstrap_detect_ssh_port: true
```

- Enables SSH port auto-detection before fact gathering  
- Only used for SSH/paramiko connections  

---

### `bootstrap_fail_on_unknown_pkg_mgr`

```yaml
bootstrap_fail_on_unknown_pkg_mgr: true
```

- Fail if package manager cannot be detected  

---

### `bootstrap_extra_packages`

```yaml
bootstrap_extra_packages: []
```

Additional packages installed after bootstrap.

Example:

```yaml
bootstrap_extra_packages:
  - sudo
  - ca-certificates
```

---

## Built-in Package Sets

### APT
- python3  
- python3-apt  

### DNF / YUM
- python3  
- python-dnf  

### DNF5
- python3  
- python3-dnf  
- python3-libdnf5  

---

## How It Works

1. Optional SSH port detection  
2. Detect package manager using raw shell  
3. Install required Python runtime and bindings  
4. Reset connection (SSH-like transports only)  

---

## Usage

### Minimal Example

```yaml
- name: Bootstrap hosts
  hosts: all
  gather_facts: false
  become: true

  roles:
    - role: guidugli.bootstrap
```

---

### With Extra Packages

```yaml
- name: Bootstrap hosts
  hosts: all
  gather_facts: false
  become: true

  roles:
    - role: guidugli.bootstrap

  vars:
    bootstrap_extra_packages:
      - sudo
      - ca-certificates
```

---

### Container / Molecule Usage

Disable SSH port detection:

```yaml
bootstrap_detect_ssh_port: false
```

Use this in container-based Molecule scenarios (for example with `containers.podman.podman`) because SSH port detection is not applicable to that connection type.

---

## Important Design Notes

### Privilege Escalation

This role does not enforce privilege escalation internally.

Set `become: true` in the calling play when package installation requires elevated privileges.

---

### Use of `raw`

This role uses `raw` intentionally because:

- Python may not exist yet  
- Package modules cannot run initially  

---

## Molecule Testing

Scenarios:

- default  
- systemd  

Run:

```bash
molecule test -s default
molecule test -s systemd
```

---

## Release Workflow

```bash
./scripts/update_release_metadata.sh
```

This updates:

- OS matrix  
- inventories  
- meta/main.yml  

---

## Repository Structure

```text
defaults/
vars/
tasks/
meta/
molecule/
  shared/
  default/
  systemd/
scripts/
templates/
```

---

## License

MIT

---

## Author

Carlos Guidugli
