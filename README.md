# ansible-role-dpb

Creates `chroot` for bulk package build and configures `dpb` build environment.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `dpb_build_user` | build user | `_pbuild` |
| `dpb_build_group` | build group | `{{ dpb_build_user }}` |
| `dpb_fetch_user` | fetch user | `_pfetch` |
| `dpb_fetch_group` | fetch group | `{{ dpb_fetch_user }}` |
| `dpb_conf_dir` | path to directory to keep configuration files | `/etc/dpb` |
| `dpb_conf_file` | files that contains a list of packages to build | `{{ dpb_conf_dir }}/packages` |
| `dpb_proot_conf_file` | path to configuration file of `proot` | `{{ dpb_conf_dir }}/proot.conf` |
| `dpb_proot_chroot` | path to `chroot(2)` directory | `/usr/local/build` |
| `dpb_proot_config` | dict of `proot` configuration | see below |

## `dpb_proot_config`

This is a dict for `proot`. Each key is described in
[`proot(1)`](http://man.openbsd.org/proot) man page.

Values are string except `actions`. `actions` is a list of actions.

```yaml
dpb_proot_config:
  chroot: "{{ dpb_proot_chroot }}"
  BUILD_USER: "{{ dpb_build_user }}"
  FETCH_USER: "{{ dpb_fetch_user }}"
  chown_all: 1
  actions:
    - unpopulate_light
    - resolve
    - copy_ports
```

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-dpb
  vars:
    dpb_packages:
      - net/rsync
      - sysutils/ansible
      - net/curl
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
