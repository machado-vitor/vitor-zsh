#!/usr/bin/env bash
# Vitor's zsh setup — macOS. Idempotent: safe to re-run.
set -euo pipefail

REPO_URL="https://github.com/machado-vitor/vitor-zsh.git"
SRC="${BASH_SOURCE[0]:-}"
[[ -n "$SRC" && -f "$(dirname "$SRC")/zshrc" ]] && DIR="$(cd "$(dirname "$SRC")" && pwd)" || DIR=""

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.zsh-setup-backup-$STAMP"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

[[ "$(uname -s)" == "Darwin" ]] || { echo "Só macOS."; exit 1; }

# 1. fonte dos arquivos
if [[ -z "$DIR" ]]; then
  say "Clonando $REPO_URL"
  DIR="$(mktemp -d)/vitor-zsh"
  git clone --depth 1 "$REPO_URL" "$DIR"
fi

# 2. Homebrew
if ! command -v brew >/dev/null; then
  say "Instalando Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
BREW="$([[ -x /opt/homebrew/bin/brew ]] && echo /opt/homebrew/bin/brew || echo /usr/local/bin/brew)"
eval "$("$BREW" shellenv)"

# 3. pacotes
say "Instalando pacotes"
PKGS=(git gh fzf ripgrep jq tmux nvm)
[[ "${WITH_EXTRAS:-0}" == "1" ]] && PKGS+=(go maven zig ffmpeg yt-dlp rclone aria2 age)
for p in "${PKGS[@]}"; do
  brew list --formula "$p" >/dev/null 2>&1 || brew install "$p"
done
mkdir -p "$HOME/.nvm"

# 4. fonte MesloLGS NF (p10k)
say "Instalando fonte MesloLGS NF"
mkdir -p "$HOME/Library/Fonts"
base="https://github.com/romkatv/powerlevel10k-media/raw/master"
for f in "MesloLGS NF Regular.ttf" "MesloLGS NF Bold.ttf" "MesloLGS NF Italic.ttf" "MesloLGS NF Bold Italic.ttf"; do
  dst="$HOME/Library/Fonts/$f"
  [[ -f "$dst" ]] || curl -fsSL "$base/${f// /%20}" -o "$dst"
done

# 5. zinit
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  say "Instalando zinit"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 6. dotfiles (backup do que existir)
say "Escrevendo dotfiles (backup em $BACKUP)"
mkdir -p "$BACKUP"
install_file() {
  local src="$1" dst="$2"
  [[ -e "$dst" ]] && cp -p "$dst" "$BACKUP/$(basename "$dst")"
  cp "$src" "$dst"
}
install_file "$DIR/zshrc" "$HOME/.zshrc"
install_file "$DIR/p10k.zsh" "$HOME/.p10k.zsh"

# 7. zprofile: brew shellenv
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  [[ -e "$HOME/.zprofile" ]] && cp -p "$HOME/.zprofile" "$BACKUP/.zprofile"
  printf '\neval "$(%s shellenv zsh)"\n' "$BREW" >> "$HOME/.zprofile"
fi

# 8. shell default
if [[ "${SHELL:-}" != */zsh ]]; then
  warn "Shell atual não é zsh. Rode: chsh -s /bin/zsh"
fi

# 9. primeira carga: zinit baixa os plugins
say "Baixando plugins (primeira carga do zsh)"
zsh -i -c exit >/dev/null 2>&1 || true

# 10. verificação
say "Verificando"
PLUGDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/plugins"
ok=1
for p in romkatv---powerlevel10k zdharma-continuum---fast-syntax-highlighting zsh-users---zsh-autosuggestions zsh-users---zsh-completions Aloxaf---fzf-tab; do
  if [[ -d "$PLUGDIR/$p" ]]; then printf '  ok   %s\n' "$p"; else printf '  FALTA %s\n' "$p"; ok=0; fi
done
command -v fzf >/dev/null && printf '  ok   fzf\n' || { printf '  FALTA fzf\n'; ok=0; }
[[ -f "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" ]] && printf '  ok   fonte\n' || { printf '  FALTA fonte\n'; ok=0; }
[[ "$ok" == 1 ]] || warn "Algo faltou acima — rode o script de novo."

cat <<EOF

Pronto.
  - Abra um terminal novo.
  - No app do terminal, selecione a fonte "MesloLGS NF" (iTerm2: Settings > Profiles > Text).
  - Ajustes só desta máquina vão em ~/.zshrc.local (não é sobrescrito).
  - Backup dos arquivos antigos: $BACKUP
EOF
