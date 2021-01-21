Role Name
=========

Install the dependencies and packages and clone or update the repos used for building and configuring neovim.

Requirements
------------

It is not required but is strongly recommended to get your virtual environment affairs in order before running this play.

Role Variables w/default value
--------------

variable               | description or default
-----------------------|--------------------------------------------------------------------|
  - `apts`             | list of apt packs
  - `brews`            | list of homebrew packs
  - `exe_gem`          | os dependent path to executable
  - `exe_make`         | os dependent path to executable
  - `exe_pip`          | ~/.pyenv/versions/neovim3.9/bin/pip
  - `exe_yarn`         | ~/.config/nvm/versions/node/v14.15.1/bin/yarn
  - `exe_zsh`          | os dependent path to executable
  - `gems`             | list of ruby gems
  - `git_key`          | path to host key when using ssh for pulls/clones
  - `git_method`       | https
  - `gits_dir`         | "{{ ansible_env.HOME }}/gits"
  - `gits`             | [name: lua-language-server, url: sumneko/lua-language-server]
  - `install_cargos`   | no; whether to install cargo, i.e. fd on lx (uses shell)
  - `install_fzf`      | no; whether to run fzf install script (good for lx; mac uses brew)
  - `install_gems`     | false
  - `install_perls`    | false
  - `install_pips`     | false
  - `install_yarns`    | false
  - `lsp_lua_(mac,lx)` | yes; whether to install sumneko lua lsp
  - `lx_opt_packs`     | yes; whether to create "vim bin" at /usr/local/opt
  - `lx_rtp_packs`     | binaries to symlink from /usr/bin to /usr/local/opt
  - `nv_dirs`          | folders to create; i.e. ~/.cache/nvim/undodir
  - `nvim_build_dir`   | "{{ gits_dir }}/neovim"
  - `nvim_dir`         | "{{ ansible_env.HOME }}/.config/nvim"
  - `nvim_source`      | neovim/neovim
  - `perls`            | list of perl modules (not working)

NOTE:
  1. I cannot get ansible's cpanm module to function properly. If you would like perl/neovim integration, run this from the command line: `cpanm Neovim::Ext`
  2. pip and yarn/npm install from requirements.txt/package.json, respectively, instead of taking a list.


nvim_source
nvim_dir
nvim_build_dir
nvrc_repo
git_method
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
