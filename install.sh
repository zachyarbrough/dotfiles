#!/bin/bash

create_symlinks () {
  # Creates symlinks for config files
  ln -s $HOME/.dotfiles/zsh/zshrc.symlink $HOME/.zshrc
  ln -s $HOME/.dotfiles/git/gitconfig.symlink $HOME/.gitconfig
  ln -s $HOME/.dotfiles/git/gitconfig.local.symlink $HOME/.gitconfig.local

  # Creates symlinks inside .config directory 
  mkdir $HOME/.config
  ln -s $HOME/.dotfiles/nvim $HOME/.config/nvim
  ln -s $HOME/.dotfiles/tmux $HOME/.config/tmux

  # Creates symlink for bash scripts
  ln -s $HOME/.dotfiles/bin $HOME/
}

setup_brew_files () {
  # Installs homebrew
  -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Installs dependencies based on the Brewfile
  brew bundle --file $HOME/.dotfiles/homebrew/Brewfile
}

start_cron_jobs () {
    # Create a cron job for git-backup.sh that will run every hour
    # echo "0 * * * * $HOME/bin/git-backup.sh $HOME/Documents/notes" | crontab -
}

create_symlinks
setup_brew_files
start_cron_jobs
