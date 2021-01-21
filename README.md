# nvim_build

Install the dependencies and packages and clone or update the repos used for building and configuring neovim, then build and configure it.

## Requirements

This role works on debian based linux distros and macOS and requires apt or homebrew, respectively.

Zsh _might_ be required for tasks that use shell modules. You can define the executable however you like, but I always specify zsh and have never tried with another shell. The tasks using shell modules are: `install_cargos,` `install_fzf,` `install_tab9,` and the `lsp_lua` commands. In theory, they should not require zsh.
If you want to use the included TabNine or fzf scripts, then zsh is definitely required.

If you enable `lsp_lua_mac/lx,` it gets built from source. The dependencies should be covered by the default brew/apt lists but the build may fail on machines with older versions of C++, which is well beyond scope. Also, the lua lsp does not build on armv (raspberrypi).

It is not required but is strongly recommended to get your virtual environment affairs in order before running this play.


## Role Variables

variable         | default directory                     | description
-----------------|---------------------------------------|----------------------------|
`nvim_build_dir` | `{{ gits_dir }}/neovim`               | local dest for source repo
`nvim_dir`       | `{{ ansible_env.HOME }}/.config/nvim` | local dest for config
`nvim_source`    | neovim/neovim                         | build source repo
`nvrc_repo`      |                                       | personal config repo

The default for nearly everything is non-action.

variable         | default | type   | description
-----------------|---------|--------|----------------------------------------------------------------|
`apts`           | +       | list   | apt packs
`brews`          | +       | list   | homebrew packs
`brew_heads`     | +       | list   | same but install from `--HEAD`
`build_it`       | no      | bool   | whether to actually build nvim after running all other tasks
`exe_gem`        |         | string | path to executable
`exe_make`       |         | string | path to executable
`exe_pip`        |         | string | path to executable
`exe_shell`      |         | string | path to executable
`exe_yarn`       |         | string | path to executable
`gems`           | +       | list   | ruby gems
`git_key`        |         | string | path to host key when using ssh for pulls/clones
`git_method`     | https   | string | only supported options are ssh and https
`gits_dir`       |         | string | local parent directory where extra repos are cloned
`gits`           | +       | list   | repos to clone/update; format: user/repo
`install_cargos` | no      | bool   | whether to install cargo, i.e. fd on lx (uses shell)
`install_fzf`    | no      | bool   | whether to run fzf install script (good for lx; mac uses brew)
`install_gems`   | no      | bool   |
`install_perls`  | no      | bool   | not working atm
`install_pips`   | no      | bool   |
`install_tab9`   | no      | bool   | run script files/tab9_ansible.zsh
`install_yarns`  | no      | bool   |
`lsp_lua_lx`     | no      | bool   | whether to install sumneko lua lsp linux
`lsp_lua_mac`    | no      | bool   | whether to install sumneko lua lsp mac
`lx_rtp_bin`     | no      | bool   | whether to create "vim bin" at /usr/local/opt
`lx_rtp_packs`   | +       | list   | symlinks from /usr/bin to /usr/local/opt
`nv_dirs_mk`     | no      | bool   | whether to create directories specified by `nv_dirs`
`nv_dirs`        | +       | list   | folders to create i.e., ~/.cache/nvim/undodir
`perls`          | +       | list   | perl modules

`+` = see defaults/main.yml for default values


NOTE:
  1. I cannot get ansible's cpanm module to function properly. If you would like perl + neovim integration, run this from the command line: `cpanm Neovim::Ext`
  2. pip and yarn/npm install from requirements.txt/package.json, respectively, instead of taking a list. Make sure those files are in your `nvim_dir` or use a pre-task to put them in place (see playbook example below).
  3. Only github is supported out of the box. I have never used gitlab or any other version control platform and do not know my way around.
  4. npm was constantly throwing errors over things that no self-respecting package manager should, so right now this role uses yarn only ... and I do not feel compelled to try reimplementing npm.
  5. The `lx_rtp_bin` "vim bin" is a directory with the same absolute path on each machine that is not in `$PATH`, and I use it for symlinking binaries that I want to made specifically available to neovim. So, in vimrc I can just rtp+=/usr/local/opt/fzf once and forget about it.

## Dependencies

ansible-galaxy collection install community.general

## Example Playbook

```yaml
- hosts: all

  pre_tasks:
    - name: copy node package.json for yarn
      copy:
        src: files/package.json
        dest: "{{ nvim_dir }}"
        force: no
    - name: copy requirements.txt for pip
      copy:
        src: files/requirements.txt
        dest: "{{ nvim_dir }}"
        force: no

  vars:
    nvrc_repo: klooj/nvim
    build_it: yes

    gits_dir: "{{ ansible_env.HOME }}/gits"
    git_key: "~/.ssh/{{ ansible_hostname }}_git"
    git_method: ssh

    lsp_lua_lx: yes
    lsp_lua_mac: yes
    lx_rtp_bin: yes
    nv_dirs_mk: yes

    install_pips: yes
    exe_pip: ~/.pyenv/versions/neovim3.9/bin/pip
    install_yarns: yes
    exe_yarn: ~/.config/nvm/versions/node/v14.15.1/bin/yarn
    install_gems: yes

    # group_vars: exe_make, exe_shell, exe_gem, install_cargos

  roles:
    - nvim_build

```

NOTE: put `exe_shell` in `group_vars/` or `host_vars/`.

## License

MIT

## Author Information

github.com/klooj
