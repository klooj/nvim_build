Role Name
=========

Clone and update the repos used for building, configuring, or otherwise supplementing neovim.
Install dependencies and various packages for your neovim build and configuration.

TODO
----

1. configure yamllint; run autoformat on save
2. figure out that plugin that auto formats tables/lists etc
3. make sure certain variables are available to all roles, such as `nvrc_dir` or whatever, by putting them in the playbook vars/defaults in addition to the individual role.
4. make a "pre" roles role that checks/installs/updates the package managers themselves.
    - npm
    - gem
    - homebrew
    - cpanm
    - yarn

Requirements
------------

It is not required but is strongly recommended to get your virtual environment affairs in order before running this play.

Role Variables
--------------

nvim_dir
nvrc_repo
nvim_source
pull_method
gits_dir
gits

nvrc_repo
brews
nodes, npmexe
yarns, yarnexe
apts
pipexe (installs from nvim/requirements.txt)
gems
perls
lx_rtp_packs

Dependencies
------------

ansible-galaxy collection install community.general

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------
