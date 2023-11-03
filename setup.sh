#!/bin/bash
# Inspired from tot0k's setup.sh
# https://gitlab.com/tot0k/myenv

. ./utils.sh
CURDIR="$(pwd)"
TMP="$(mktemp -d)"
cd "$TMP" || exit
echo_info "Setting up Legoffar's environment"
BIN="$HOME/bin"
mkdir -p "$BIN"
ZDOTDIR="$HOME/.config/zsh"
mkdir -p "$ZDOTDIR"
################################################################################
#                                                                              #
#                                 Pkg                                          #
#                                                                              #
################################################################################
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

################################################################################
#                                                                              #
#                                 exa                                          #
#                                                                              #
################################################################################
fallback_ls() {
    sed -i 's/exa -laF --group-directories-first --header --git --long/ls  -laF --group-directories-first/g' ~/.myenv
    sed -i 's/exa -a --group-directories-first/ls -a --group-directories-first/g' ~/.myenv
    sed -i 's/exa -lF --group-directories-first --header --git --long/ls -lF --group-directories-first/g' ~/.myenv
    sed -i 's/exa --group-directories-first/ls --group-directories-first/g' ~/.myenv
}

read -rp "Do you want to install exa? (y/n) " answer
case ${answer:0:1} in
    y|Y )
        echo_info "Installing exa"
        if ! which exa > /dev/null; then
            if unzip res/exa*.zip; then
                if sudo mv bin/exa "$BIN"; then
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
;;
    * )
        echo_info "Skipping exa installation."
    ;;
esac
################################################################################
#                                                                              #
#                                 fzf                                          #
#                                                                              #
################################################################################
read -rp "Do you want to install fzf? (y/n) " answer
case ${answer:0:1} in
    y|Y )
        echo_info "Installing fzf"
        if ! which fzf > /dev/null; then
            if tar -xf res/*fzf.tar.gz; then
                if sudo cp fzf "$BIN"; then
                    echo_ok "Fzf installed."
                else
                    echo_err "Fzf not installed!"
                fi
            fi
        else
            echo_info "Fzf already installed, skipping"
        fi
;;
    * )
        echo_info "Skipping fzf installation."
    ;;
esac
################################################################################
#                                                                              #
#                               Oh My Zsh                                     #
#                                                                              #
################################################################################
read -rp "Do you want to install fzf? (y/n) " answer
case ${answer:0:1} in
    y|Y )
        echo_info "Installing ohmyzsh"
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
;;
    * )
        echo_info "Skipping fzf installation."
    ;;
esac

################################################################################
#                                                                              #
#                            diff-so-fancy                                    #
#                                                                              #
################################################################################
echo_info "Setting up diff-so-fancy"
if which diff-so-fancy > /dev/null; then
    echo_info "Diff-so-fancy already installed, skipping"
else
    if mv res/diff-so-fancy "$BIN"; then
        if chmod +x "$BIN"/diff-so-fancy; then
            echo_ok "Diff-so-fancy installed."
        else
            echo_err "Diff-so-fancy not installed!"
        fi
    else
        echo_err "Diff-so-fancy not installed!"
    fi
fi

################################################################################
#                                                                              #
#                                 git                                          #
#                                                                              #
################################################################################
#ask for git config only if .gitconfig does not exist
if [ ! -f ~/.gitconfig ]; then
    echo_info "Setting up global git"
    read -rp "Enter your global git username: " git_username
    read -rp "Enter your global git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
fi


echo_info "Copying default environment"
cp "${CURDIR}/myenv" ~/.myenv

echo_info "Copying utils.sh"
cp "${CURDIR}/utils.sh" "$BIN"

cd - || exit
rm -rf "$TMP"

zsh

################################################################################
#                                                                              #
#                                 Typora                                       #
#                                                                              #
################################################################################
# read -rp "Do you want to install Typora? (y/n) " answer
# case ${answer:0:1} in
#     y|Y )
#         echo_info "Installing typora"
#         if ! which typora > /dev/null; then
#             if wget -qO - https://typoraio.cn/linux/public-key.asc | sudo tee /etc/apt/trusted.gpg.d/typora.asc; then
#                 sudo add-apt-repository -y 'deb https://typora.io/linux ./'
#                 sudo apt-get update -yqq
#                 if sudo apt-get -yqq install typora; then
#                     echo_ok "Typora installed."
#                 else
#                     echo_err "Error while installing Typora!"
#                 fi
#             fi
#         else
#             echo_ok "Typora already installed."
#         fi
#     ;;
#     * )
#         echo_info "Skipping Typora installation."
#     ;;
# esac

################################################################################
#                                                                              #
#                                 vim                                          #
#                                                                              #
################################################################################
# #Configuring vim
# #Asking if vim should be reconfigured
# echo_info "Setting up vim"
# if [ ! -d ~/.vim ]; then
#     mkdir -p ~/.vim ~/.vim/autoload ~/.vim/backup ~/.vim/colors ~/.vim/plugged
#     curl -sfLo  ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#     cp "${CURDIR}/vimrc" ~/.vimrc
# else
#     echo_info "Vim is already configured, do you want to reconfigure it? (y/n)"
#     read -r vim_reconfigure
#     if [ "$vim_reconfigure" = "y" ]; then
#         echo_info "Reconfiguring vim"
#         rm -rf ~/.vim ~/.vimrc
#         mkdir -p ~/.vim ~/.vim/autoload ~/.vim/backup ~/.vim/colors ~/.vim/plugged
#         curl -sfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#         cp "${CURDIR}/vimrc" ~/.vimrc
#         vim +PlugInstall +qall > /dev/null 2>&1
#     else
#         echo_info "Keeping vim configuration"
#     fi
# fi