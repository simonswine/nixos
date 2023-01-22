#!/usr/bin/env python3

from prometheus_client import CollectorRegistry, Gauge, Info, write_to_textfile
import os
import subprocess
import json
import argparse
import sys


def rewrite_key(s):
    out = ''
    for c in s:
        if c.isupper():
            out += '_'
            out += c.lower()
        else:
            out += c
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--destination-path',
                        default='./nixos.prom')
    args = parser.parse_args(sys.argv[1:])

    # prefer the nixos-verison from current-system
    versionPath = '/run/current-system/sw/bin/nixos-version'
    if not os.path.exists(versionPath):
        versionPath = '/nix/var/nix/profiles/system/sw/bin/nixos-version'

    # load versions from command
    versions = json.loads(
        subprocess.run(
            [versionPath, '--json'],
            stdout=subprocess.PIPE,
        ).stdout.decode('utf-8'),
    )

    versions = {rewrite_key(k): v for k, v in versions.items()}

    # figure out current generation
    current_system = os.readlink(os.path.dirname(os.path.dirname(os.path.dirname(versionPath))))
    time_system = 0
    profiles_dir = '/nix/var/nix/profiles'
    for f in os.listdir(profiles_dir):
        fpath = os.path.join(profiles_dir, f)
        if not os.path.islink(fpath):
            continue
        dest = os.readlink(fpath)
        if dest != current_system:
            continue
        parts = f.split('-')
        if len(parts) != 3:
            continue
        versions['generation'] = parts[1]
        time_system = os.stat(fpath).st_ctime

    registry = CollectorRegistry()
    info = Info(
        name='nixos',
        documentation='NixOS version information',
        labelnames=versions.keys(),
        registry=registry,
    )
    info.labels(*versions.values())

    last_deployed = Gauge(
        name='nixos_last_deployed',
        documentation='Last time NixOS has been rebuild',
        registry=registry,
    )
    last_deployed.set(time_system)

    write_to_textfile(args.destination_path, registry)


if __name__ == '__main__':
    main()
