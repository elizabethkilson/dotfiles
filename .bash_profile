export GNUPGHOME="$HOME/.gnupg"
export GPG_TTY=$(tty)
#export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

gpgconf --launch gpg-agent
#gpg-agent --daemon --enable-ssh-support
gpg-connect-agent updatestartuptty /bye



export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
