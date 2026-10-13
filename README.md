# vitor-zsh

Meu setup de zsh (zinit + powerlevel10k + fzf), replicável em qualquer Mac.

## Instalar

```sh
curl -fsSL https://raw.githubusercontent.com/machado-vitor/vitor-zsh/main/install.sh | bash
```

Com extras (go, maven, zig, ffmpeg, yt-dlp, rclone, aria2, age):

```sh
curl -fsSL https://raw.githubusercontent.com/machado-vitor/vitor-zsh/main/install.sh | WITH_EXTRAS=1 bash
```

Depois: abrir terminal novo e selecionar a fonte **MesloLGS NF**.

## O que entra

| | |
|---|---|
| Homebrew | instala se faltar, `shellenv` no `~/.zprofile` |
| Pacotes | git, gh, fzf, ripgrep, jq, tmux, nvm |
| Plugin manager | zinit em `~/.local/share/zinit` |
| Prompt | powerlevel10k + `~/.p10k.zsh` (config pronta) |
| Plugins | fast-syntax-highlighting, zsh-autosuggestions, zsh-completions, fzf-tab (turbo) |
| Fonte | MesloLGS NF (4 variantes) em `~/Library/Fonts` |
| Histórico | 10k linhas, compartilhado entre sessões |

Idempotente: rodar de novo não duplica nada. O `~/.zshrc` e `~/.p10k.zsh` antigos vão pra `~/.zsh-setup-backup-<timestamp>/`.

## Por máquina

`~/.zshrc.local` é carregado no fim e nunca sobrescrito — pyenv, sdkman, variáveis do trabalho, etc.

## Atualizar a partir da máquina de origem

```sh
cp ~/.zshrc  zshrc
cp ~/.p10k.zsh p10k.zsh
git commit -am "sync" && git push
```
