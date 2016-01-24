#!/usr/bin/env bash

cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

set -e

echo ''

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
          [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done

  success 'dotfiles'
}

touchfiles () {
  info 'touching files'
  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.touch' -not -path '*.git*')
  do
  touch "$HOME/.$(basename "${src%.*}")"
  done
}

homebrew() {
  if test ! $(which brew); then
    info "installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    scucess 'homebrew'
  fi

  info "installing homebrew dependencies"

  # Upgrade homebrew
  info "› brew update"
  # brew update

  # Run Homebrew through the Brewfile
  info "› brew bundle"
  brew bundle --file="${DOTFILES_ROOT}/Brewfile"

  if [[ -f ~/.Brewfile_local ]]; then
    info "› brew bundle --file ~/.Brewfile_local"
    brew bundle --file="${HOME}/.Brewfile_local"
  fi

  success 'homebrew dependencies'
}

gitconfig () {
  info "gitconfig setup"
  if [ "$(uname -s)" == "Darwin" ]
  then
    git_credential='osxkeychain'
  fi

  user ' - What is your github author name? (e.g. Alex Jones)'
  read -e git_authorname
  user ' - What is your github author email? (e.g. alex@jones.co'
  read -e git_authoremail

  git config --file ~/.gitconfig_local user.name "$git_authorname"
  git config --file ~/.gitconfig_local user.email "$git_authoremail"

  success 'gitconfig'
}

info 'Installing dotfiles...'
dotfiles
touchfiles
homebrew
gitconfig

echo ''
echo '  All installed!'
