# Dotfiles

Theses are dotfiles. They make it easier to manage config files and homebrew applications on OS X.

The goal of these dotfiles is to provide a shared baseline for teams, with the possibility of personalization.

## Installation

Easy:

```sh
cat ./bootstrap.sh # Make sure everthing looks good.
./bootstrap.sh     # Install everything and set up symlinks.
```

Harder:

0. Install [homebrew](https://brew.sh) and [homebrew bundle](https://github.com/Homebrew/homebrew-bundle)
0. Install the [Brewfile](./Brewfile) with homebrew bundle
0. For each `.symlink` file, create a symlink in your home directory (transforming the name from `foo.symlink` to `.foo`)
0. For each `.touch` file, ensure that a file exists in your home directory (transforming the name from `foo.symlink` to `.foo`)

(This is what the bootstrap script does anyway.)

## Personalization

The easiest way to add customizations is to submit a Pull Request to this repo.

In order to override this repo's opinions, you can edit the `_local` dotfiles, `$HOME/.{vimrc,tmux.conf,zshrcg,gitconfig}_local`.

