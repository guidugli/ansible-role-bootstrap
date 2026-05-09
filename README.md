Ansible Role: Bootstrap
=========

Adds the appropriate packages/libraries to allow ansible to run most common roles (like package management roles).

Requirements
------------

This role runs on RedHat/Fedora/Debian/Ubuntu systems.

Role Variables
--------------

No role variables defined.

Dependencies
------------

No dependencies.

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: guidugli.bootstrap }

License
-------

MIT / BSD

Author Information
------------------

This role was created in 2026 by Carlos Guidugli.
