#! /usr/bin/env zsh

local installOrUpdate() {
	if [[ $OSTYPE =~ linux ]] {
		(( ${+commands[fzf]} )) && [[ -z `git -C $FOOZ/fzf status --porcelain` ]] && return
		git -C $FOOZ/fzf pull
		$FOOZ/fzf/install --bin --no-bash --no-fish
		cp -f $FOOZ/fzf/bin/* ${GOBIN:-$HOME/.local/bin}  # both fzf executables
		rsync -azuh $FOOZ/fzf/man $XDG_DATA_HOME      # manpages

	} elif [[ $OSTYPE =~ darwin ]] {
		if (( ! ${+commands[fzf]} )) {
			brew install --HEAD fzf
		} else {
		brew upgrade --fetch-HEAD fzf
		}
	}
}

[[ -d $FOOZ/fzf ]] || git clone --depth 1 https://github.com/junegunn/fzf.git ${FOOZ}/fzf
installOrUpdate
