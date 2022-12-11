#!/bin/sh

. ./utils.sh
CURDIR="$(pwd)"
TMP="$(mktemp -d)"

fallback_ls() {
    sed -i 's/exa -laF --group-directories-first --header --git --long/ls  -laF --group-directories-first/g' ~/.myenv
    sed -i 's/exa -a --group-directories-first/ls -a --group-directories-first/g' ~/.myenv
    sed -i 's/exa -lF --group-directories-first --header --git --long/ls -lF --group-directories-first/g' ~/.myenv
    sed -i 's/exa --group-directories-first/ls --group-directories-first/g' ~/.myenv
}

cd "$TMP" || exit
echo_info "Setting up Legoffar's environment"

pkg_list="git\
          curl\
          wget\
          zip\
          unzip\
          sed\
          build-essential\
          make\
          shellcheck\
          doxygen\
          terminator\
          nano\
          tldr\
          exa\
          net-tools\
          iproute2\
          zsh"

echo_info "Updating APT repositories"
sudo apt update

for pkg in $pkg_list:
do
    echo_info "Installing ${pkg}"
    if sudo apt-get -yqq install "$pkg"; then
    echo_ok "$pkg installed."
    else
    echo_err "$pkg not installed!"
    fi
done

# echo_info "Add Typora's repository"
if curl https://typora.io/linux/public-key.asc | gpg --dearmor > /usr/share/keyrings/typora.gpg; then
    touch /etc/apt/sources.list.d/typora.list
    echo "deb [signed-by=/usr/share/keyrings/typora.gpg] https://typora.io/linux ./" > /etc/apt/sources.list.d/typora.list
    sudo apt update
    if sudo apt-get -yqq install typora; then
        echo_ok "Typora installed."
    else
        echo_err "Error while installing Typora!"
    fi
fi

echo_info "Copying default environment"
cp "${CURDIR}/myenv" ~/.myenv

if ! which exa; then
    echo_info "Trying to install exa manually since it was not installed automatically"
    if wget "https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip"; then
        unzip exa-linux-x86_64-v0.10.1.zip
        if sudo mv bin/exa /usr/bin/exa; then
            echo_ok "Exa installed."
        else
            echo_err "Could not install exa, falling back to ls"
            fallback_ls
        fi
    else
        echo_err "Could not install exa, falling back to ls"
        fallback_ls
    fi
fi

echo_info "Installing fzf"
if wget "https://github.com/junegunn/fzf/releases/download/0.35.1/fzf-0.35.1-linux_amd64.tar.gz"; then
    tar -xf fzf-0.35.1-linux_amd64.tar.gz
    if sudo cp fzf /usr/bin/fzf; then
        cp "${CURDIR}/fzf-git.sh" ~/.fzf-git.sh
        echo_ok "Fzf installed."
    else
        echo_err "Fzf not installed!"
    fi
fi

echo_info "Installing ohmyzsh"
if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --keep-zshrc --unattended; then
    echo_ok "OhMyZsh installed."
    echo_info "Copying zsh config"
    cp "${CURDIR}/zshrc" ~/.zshrc
    #TODO: Add theme
    echo_info "Setting zsh as default shell"
    if chsh -s "$(which zsh)"; then
        echo_ok "Zsh set as default shell."
    else
        echo_err "Could not set zsh as default shell!"
    fi
else
    echo_err "OhMyZsh not installed!"
fi

#Configuring vim
echo_info "Setting up vim"
if [ ! -d ~/.vim ]; then
    mkdir -p ~/.vim ~/.vim/autoload ~/.vim/backup ~/.vim/colors ~/.vim/plugged
    cp "${CURDIR}/vimrc" ~/.vimrc
fi

#ask for git config
echo_info "Setting up git"
read -p "Enter your global git username: " git_username
read -p "Enter your global git email: " git_email
git config --global user.name "$git_username"
git config --global user.email "$git_email"

cd - || exit
rm -rf "$TMP"
zsh
