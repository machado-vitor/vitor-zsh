# Powerlevel10k instant prompt — keep at the top of ~/.zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

: ${HOMEBREW_PREFIX:=$([[ -x /opt/homebrew/bin/brew ]] && echo /opt/homebrew || echo /usr/local)}

export NVM_DIR="$HOME/.nvm"
[[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]] && . "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

export PATH="$HOME/.local/bin:$PATH"

# ---- Zinit ----
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
[[ -f "${ZINIT_HOME}/zinit.zsh" ]] && source "${ZINIT_HOME}/zinit.zsh"

# ---- Powerlevel10k ----
zinit ice depth=1
zinit light romkatv/powerlevel10k

# ---- Plugins (turbo mode) ----
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zinit light Aloxaf/fzf-tab

# ---- History ----
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- fzf (Ctrl-R, Ctrl-T, Alt-C) ----
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi

[[ -f ~/.cargo/env ]] && . "$HOME/.cargo/env"

# ---- Docker CLI completions ----
if [[ -d ~/.docker/completions ]]; then
  fpath=(~/.docker/completions $fpath)
  autoload -Uz compinit
  (( ${+_comps[docker]} )) || compinit
fi

# ---- Per-machine additions ----
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
