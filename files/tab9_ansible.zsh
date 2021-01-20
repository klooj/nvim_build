#! /usr/bin/env zsh

# Download latest TabNine binaries.

# attribution:
#   based on: github.com/aca/completion-tabnine/blob/master/install.sh
#   which is Based on: github.com/codota/TabNine/blob/master/dl_binaries.sh

# attrition:
# NOTE this script allows for an arbitrary amount of versions of the
# executable to be installed, but there may only be one OS per installed
# version. It seems the default TabNine backend installs executables for like a
# half dozen target operating systems, which I guess could be potentially
# helpful for a crossplatform TabNine local server ... but that still seems a 
# little Rube Goldberg.  Anyway, I'm making this disclosure out of an abunance
# of precaution; I'm changing a vendor default and I'm still at the stage where
# I don't even know what I don't know.

# hierarchy:
#  $dest/
#     |- [previous version]
#          |- TabNine
#     |- $latest
#          |- TabNine

# fail fantastically
set -o errexit
set -o pipefail
# set -x # uncomment if you want to trace

# set parent directory for all versions of TabNine and change into it
dest="$HOME/.local/share/t9"
mkdir -p $dest
cd $dest

# check the version of latest t9 available
latest="$(curl -sS https://update.tabnine.com/version)"

# if the latest version is already installed, gtfo
[[ -d $dest/$latest ]] && return

# if we have not exited, we need the latest binary release for our OS.
# so now let's get our triple, which is needed for the url to the binary.
case $(uname -s) in
    "Darwin")
        platform="apple-darwin"
        ;;
    "Linux")
        platform="unknown-linux-gnu"
        ;;
esac
triple="$(uname -m)-$platform"

# get in there
echo "Downloading TabNine $latest for $triple"
curl "https://update.tabnine.com/$latest/$triple/TabNine" --create-dirs -o $latest/TabNine

# the permissions in the default make this executable by the whole world, I prefer to limit it to the user.
chmod u+x $latest/TabNine && echo "\nsucess. the executable is located at:\n$dest/$latest/TabNine" && \
    echo "\nyou prob wanna write down that path somewhere like $FOONV/lua/klooj/completion.lua" && \
    echo "\nyou might even wanna just do something like:\nsed -i '/completion_tabnine_tabnine_path/s/([[:digit:]]\.)*\/TabNine/$latest\/TabNine/'"

