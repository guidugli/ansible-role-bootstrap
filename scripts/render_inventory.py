#!/usr/bin/env python3
"""Render molecule inventories from molecule/shared/vars.yml."""

from __future__ import annotations

from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
VARS = ROOT / "molecule" / "shared" / "vars.yml"
SCENARIOS = ["default", "systemd"]


class IndentSafeDumper(yaml.SafeDumper):
    def increase_indent(self, flow=False, indentless=False):
        return super().increase_indent(flow, False)


def host_block(name: str, image: str, version: str) -> dict:
    return {
        name: {
            "ansible_connection": "containers.podman.podman",
            "container_image": f"{image}:{version}",
            "container_command": "sleep 1d",
        }
    }


def dump_yaml(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    text = yaml.dump(
        data,
        Dumper=IndentSafeDumper,
        sort_keys=False,
        default_flow_style=False,
        explicit_start=True,
        indent=4,
    )
    path.write_text(text, encoding="utf-8")


def main() -> None:
    cfg = yaml.safe_load(VARS.read_text(encoding="utf-8"))
    matrix = cfg["platform_matrix"]
    images = cfg["images"]

    hosts: dict = {}
    for distro, versions in matrix.items():
        for version in versions:
            hostname = f"{distro}{version.replace('.', '')}"
            hosts.update(host_block(hostname, images[distro], version))

    inventory = {
        "all": {
            "children": {
                "molecule": {
                    "hosts": hosts,
                }
            }
        }
    }

    for scenario in SCENARIOS:
        output = ROOT / "molecule" / scenario / "inventory" / "hosts.yml"
        dump_yaml(output, inventory)
        print(f"Wrote {output}")


if __name__ == "__main__":
    main()
