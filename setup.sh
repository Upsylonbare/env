#!/bin/sh
# Inspired from tot0k's setup.sh
# https://gitlab.com/tot0k/myenv

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
          net-tools\
          iproute2\
          zsh\
          fdclone\
          bat\
          xclip"

echo_info "Updating APT repositories"
sudo apt update -yqq

for pkg in $pkg_list:
do
    echo_info "Installing ${pkg}"
    if sudo apt-get -yqq install "$pkg"; then
    echo_ok "$pkg installed."
    else
    echo_err "$pkg not installed!"
    fi
done

echo_info "Installing typora"
if ! which typora > /dev/null; then
    if curl https://typora.io/linux/public-key.asc | sudo gpg --dearmor > /usr/share/keyrings/typora.gpg; then
        touch /etc/apt/sources.list.d/typora.list
        echo "deb [signed-by=/usr/share/keyrings/typora.gpg] https://typora.io/linux ./" > /etc/apt/sources.list.d/typora.list
        sudo apt update
        if sudo apt-get -yqq install typora; then
            echo_ok "Typora installed."
        else
            echo_err "Error while installing Typora!"
        fi
    fi
else
    echo_ok "Typora already installed."
fi

echo_info "Copying default environment"
cp "${CURDIR}/myenv" ~/.myenv

if ! which exa > /dev/null; then
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

#installing fzf only if it is not already installed
echo_info "Installing fzf"
if ! which fzf > /dev/null; then
    if wget "https://github.com/junegunn/fzf/releases/download/0.35.1/fzf-0.35.1-linux_amd64.tar.gz" > /dev/null; then
        tar -xf fzf-0.35.1-linux_amd64.tar.gz
        if sudo cp fzf /usr/bin/fzf; then
            # cp "${CURDIR}/fzf-git.sh" ~/.fzf-git.sh
            # chmod +x ~/.fzf-git.sh
            echo_ok "Fzf installed."
        else
            echo_err "Fzf not installed!"
        fi
    fi
else
    echo_info "Fzf already installed, skipping"
fi

echo_info "Installing ohmyzsh"
#test if ohmyzsh is already installed
if [ -d ~/.oh-my-zsh ]; then
    echo_info "OhMyZsh already installed, skipping"
else
    if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --keep-zshrc --unattended; then
        echo_ok "OhMyZsh installed."
        echo_info "Copying zsh config"
        cp "${CURDIR}/zshrc" ~/.zshrc
        if  cp "${CURDIR}/my-af-magic.zsh-theme" ~/.oh-my-zsh/themes/my-af-magic.zsh-theme; then
            echo_info "Using custom zsh theme"
        else
            echo_err "Could not cp custom zsh theme, falling back to default theme"
            sed -i 's/my-af-magic.zsh-theme/af-magic.zsh-theme/g' ~/.zshrc
        fi
        echo_info "Setting zsh as default shell"
        if chsh -s "$(which zsh)"; then
            echo_ok "Zsh set as default shell."
        else
            echo_err "Could not set zsh as default shell!"
        fi
    else
        echo_err "OhMyZsh not installed!"
    fi
fi

#Configuring vim
#Asking if vim should be reconfigured
echo_info "Setting up vim"
if [ ! -d ~/.vim ]; then
    mkdir -p ~/.vim ~/.vim/autoload ~/.vim/backup ~/.vim/colors ~/.vim/plugged
    curl -sfLo  ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    cp "${CURDIR}/vimrc" ~/.vimrc
else
    echo_info "Vim is already configured, do you want to reconfigure it? (y/n)"
    read -r vim_reconfigure
    if [ "$vim_reconfigure" = "y" ]; then
        echo_info "Reconfiguring vim"
        rm -rf ~/.vim ~/.vimrc
        mkdir -p ~/.vim ~/.vim/autoload ~/.vim/backup ~/.vim/colors ~/.vim/plugged
        curl -sfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        cp "${CURDIR}/vimrc" ~/.vimrc
        vim +PlugInstall +qall > /dev/null 2>&1
    else
        echo_info "Keeping vim configuration"
    fi
fi

echo_info "Setting up diff-so-fancy"
if which diff-so-fancy > /dev/null; then
    echo_info "Diff-so-fancy already installed, skipping"
else
    if wget "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy" ; then
        if sudo mv diff-so-fancy /usr/local/bin/diff-so-fancy; then
            chmod +x /usr/local/bin/diff-so-fancy
            echo_ok "Diff-so-fancy installed."
        else
            echo_err "Diff-so-fancy not installed!"
        fi
    else
        echo_err "Diff-so-fancy not installed!"
    fi
fi

#ask for git config only if .gitconfig does not exist
if [ ! -f ~/.gitconfig ]; then
    echo_info "Setting up git"
    read -p "Enter your global git username: " git_username
    read -p "Enter your global git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
fi

cd - || exit
rm -rf "$TMP"
zsh
