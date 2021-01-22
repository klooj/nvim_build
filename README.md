![CI](https://github.com/klooj/nvim_build/workflows/CI/badge.svg) [![Build Status](https://travis-ci.com/klooj/nvim_build.svg?branch=master)](https://travis-ci.com/klooj/nvim_build)

# nvim_build  

This ansible role builds the nightly version of neovim on macOS and debian based linux distributions.

First, it installs or updates the dependencies, packages, and repos used for building and configuring your neovim, then builds it using the makefile in the source repo. This role puts everything in place but does not open neovim nor run arbitrary neovim commands, so it does not update or install plugins. To use this role, add the following to your requirements file and run `ansible-galaxy role install -r requirements.yml`

```yaml
- src: https://github.com/klooj/nvim_build
  scm: git
  name: nvim_build
```

## requirements  

  - This role works on debian based linux distros and macOS and requires apt or homebrew, respectively.
  - Ansible 2.10 is likely the minimum compatible version out of the box[^1] because I used the new naming conventions(mostly). To that end, the role employs the community collection, which can be installed by running:
  `ansible-galaxy collection install community.general`.

The are also a few optional dependencies listed below.

## Role Variables  

| variable               | default directory                     | description                               |
|:----------------------:|:-------------------------------------:|:-----------------------------------------:|
| `nvim_build_dir`       | `{{ gits_dir }}/neovim`               | local dest for clone of source repo       |
| `nvim_dir`             | `{{ ansible_env.HOME }}/.config/nvim` | local dest for clone of user config       |
| `nvim_source`          | neovim/neovim                         | build source repo                         |
| `nvrc_repo`            |                                       | personal config repo                      |
| `install_path`         | ~/.local                              | dest for installed runtime files & binary |


**The default for nearly everything is non-action**.  

| variable       | default | description                                                        | type   |
|:--------------:|:-------:|:------------------------------------------------------------------ |:------:|
| `build_it`     | no      | whether to build and install nvim                                  | bool   |
| `exe_make`     |         | path to executable                                                 | string |
| `exe_shell`    |         | path to executable                                                 | string |
| `exe_pip`      |         | path to executable                                                 | string |
| `exe_yarn`     |         | path to executable                                                 | string |
| `exe_gem`      |         | path to executable                                                 | string |
| `git_key`      |         | path to host key when using ssh for pulls/clones                   | string |
| `git_method`   | https   | only supported options are ssh and https                           | string |
| `gits_dir`     | ~/gits  | local parent directory where extra repos are cloned                | string |
| `gits`         |         | format: `[- name: any, repo: foo/bar]`                             | dict   |
| `lx_rtp_bin`   | no      | whether to create "vim bin" at /usr/local/opt                      | bool   |
| `lx_rtp_packs` | +       | symlinks into vimbin; format:`[- name: fzf, source: ~/go/bin/fzf]` | dict   |
| `lsp_lua_lx`   | no      | whether to install sumneko lua lsp linux                           | bool   |
| `lsp_lua_mac`  | no      | whether to install sumneko lua lsp mac                             | bool   |
| `nv_dirs_mk`   | no      | whether to create directories specified by `nv_dirs`               | bool   |
| `nv_dirs`      | +       | folders to create; i.e., ~/.cache/nvim/undodir, etc.               | list   |

| variable         | default                 | type |
|:----------------:|:----------------------- |:----:|
| `install_apts`   | no                      | bool |
| `apts`           | see below               | list |
| `install_brews`  | no                      | bool |
| `brews`          | see below               | list |
| `brew_heads`     | see below               | list |
| `install_gems`   | no                      | bool |
| `gems`           | neovim, minitest-neovim | list |
| `install_cargos` | no (fd, rg, rga)        | bool |
| `install_perls`  | no                      | bool |
| `perls`          | Neovim                  | list |
| `install_pips`   | no                      | bool |
| `install_yarns`  | no                      | bool |

`+` = see defaults/main.yml for default values  

| apt                                            | brew             |
|:----------------------------------------------:|:----------------:|
| ack                 libtool                    | ack              |
| autoconf            libtool-bin                | automake         |
| automake            libunibilium-dev           | ccache           |
| build-essential     libutf8proc-dev            | cmake            |
| ccache              libuv1-dev                 | fd               |
| cmake               libvterm-dev               | fzy              |
| dirmngr             lua5.3                     | gettext          |
| ffmpeg              luajit                     | libtool          |
| fzy                 luarocks                   | lua              |
| g++                 ninja-build                | ninja            |
| git                 pandoc                     | pkg-config       |
| git-lfs             pkg-config                 | rg               |
| gettext             poppler-utils              | rga              |
| gperf               software-properties-common | fzf -- HEAD      |
| libluajit-5.1-dev   unzip                      | luajit -- HEAD   |
| libmsgpack-dev      zsh                        | luarocks -- HEAD |
| libtermkey-dev                                 |                  |
|                                                |                  |

**NOTE**  
  1. I cannot get ansible's cpanm module to function properly. If you would like perl + neovim integration, run this from the command line: `cpanm Neovim::Ext`  
  2. pip and yarn[^2] install from requirements.txt/package.json files, respectively, instead of taking a list. Make sure those files are in your `nvrc_repo` or use a pre-task to put them in `nvim_dir` (see playbook example below).  
  3. Only github is supported out of the box for cloning repos. I have never used gitlab or any other version control platform and do not know my way around.  
  4. The `lx_rtp_bin` "vim bin" is a directory with the same absolute path on each machine that is not in `$PATH`, and I use it for symlinking binaries that I want to made specifically available to neovim. So, in vimrc I can just rtp+=/usr/local/opt/fzf once and forget about it.  

## dependencies  

The dependencies are triggered in limited circumstances for certain optional features.

  - Zsh _might_ be required for some optional tasks that use shell modules.
You can define the executable however you like, but I always specify zsh and have never tried with another shell. The tasks using shell modules are the `install_cargos` and `lsp_lua`, which are located in tasks/packs.yaml and tasks/extras.yaml. In theory, zsh is not required but check the shell syntax before using something else.

  - C++17 is required for building the optional stand-alone [sumneko](https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)) lua lsp.
If you enable `lsp_lua_[mac|lx]`, it gets built from source. The dependencies are covered by the default brew/apt lists but the build may fail on machines with older versions of C++, which is well beyond scope and my comprehension. The only build failure I've come across is on a standard armv raspberry pi, which are excluded from building this feature even if enabled in the playbook.  

  - rust w/cargo for installing the optional crates on linux.
The apt repositories created problems for ripgrep and fd due to outdated versions and a namespace issue. I do not know if those problems continue, but I switched to installing them as crates with cargo. Homebrew does not have the same issues with these binaries.

  - go for installing the optional fzf package on linux
This is not actually implemented in the role just yet, but it will address the same version issues described in the previous bullet. In the meantime, simply run `go get -u github.com/junegunn/fzf`

It is not required but is strongly recommended to get your virtual environment affairs in order before running this play.  

## Example Playbook  

### play/main.yml  

```yaml  
---  
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
    nv_dirs_mk: yes  

    gits_dir: "{{ ansible_env.HOME }}/gits"  
    git_key: "~/.ssh/{{ ansible_hostname }}_secretKey"  
    git_method: ssh  

    lsp_lua_lx: yes  
    lsp_lua_mac: yes  
    lx_rtp_bin: yes  

    install_brews: yes  
    install_apts: yes  
    install_pips: yes  
    exe_pip: ~/.pyenv/versions/neovim3.9/bin/pip  
    install_yarns: yes  
    exe_yarn: ~/.config/nvm/versions/node/v14.15.1/bin/yarn  
    install_gems: yes  

  roles:  
    - nvim_build  
...  
```  

### play/group_vars/macs.yml  

```yaml  
---  
exe_make = /usr/local/gnubin/make  
exe_shell = /usr/local/bin/zsh  
exe_gem = /usr/local/opt/ruby/bin/gem  
...  
```  

## TODO

  - supplement/modify defaults rather than accept as is or redefine for each one.
  - option to build on one host then distribute to many
  - list of useful interactions between this role and nvim config, options, and features w/specific examples
  - luarocks
  - convert fzf and tab9 scripts to ansible tasks
  - vimr?

Author  |  License  
--- | ---
www.github.com/klooj  |  MIT

---
[^1]: Compatability with earlier versions of ansible would only require a few task names to be modified.
[^2]: npm was constantly throwing errors over things that no self-respecting package manager should, so right now this role uses yarn only ... and I do not feel compelled to try reimplementing npm.  
