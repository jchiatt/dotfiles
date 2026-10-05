# Omarchy setup

My config for [Omarchy](https://omarchy.org) (Arch + Hyprland). Separate from the older
macOS/Debian `~/.shellrc` setup in the rest of this repo — **don't run the top-level
`./install` on Omarchy**; it replaces `~/.bashrc` and breaks Omarchy's shell integration.

```bash
git clone https://github.com/jchiatt/dotfiles.git ~/Work/dotfiles
~/Work/dotfiles/omarchy/install
```

Everything under `home/` is symlinked into `$HOME` (files individually; Omarchy themes and shell plugins
as whole directories), so editing the live files edits the repo.

## What's here

| Path | What |
|---|---|
| `.zshrc`, `.config/zsh/` | zsh + oh-my-zsh (`git`, `dircycle`), autosuggestions, syntax highlighting. Ports Omarchy's bash integrations (starship, zoxide, mise, fzf, aliases). oh-my-zsh's `ga`/`gd`/`gcm` win over Omarchy's. Machine-local tweaks: `~/.config/zsh/local.zsh` (not tracked). |
| `.config/zsh/tmux-autostart.zsh` | Every terminal opens in tmux: first attaches to the `<hostname>` session, extras get throwaway sessions. Opt out with `TMUX_AUTOSTART_DISABLE=1`. |
| `.config/tmux/` | Backtick prefix (C-b also works), byobu-style F-keys, emacs copy mode, `C-o` copies last command output, TPM plugins (yank, pain-control, resurrect, continuum, sensible). |
| `.config/starship.toml` | Omarchy's prompt, ending in a non-breaking space (marker for tmux `C-o`). |
| `.config/hypr/input.lua` | Caps Lock → Ctrl, Left Alt ↔ Super (Mac-style), Compose on Right Alt. |
| `.config/hypr/bindings.lua` | `Super+Tab` cycles windows, `Super+Alt+C` centers floating window, `Super+A` toggles the agent. |
| `.config/hypr/hyprland.lua` | Agent windows live in the `special:agent` workspace. |
| `.config/voxtype/config.toml` | Voxtype dictation (hold **F9** / toggle **Super+Ctrl+X**) using the `small.en` Whisper model. The installer installs `voxtype-bin` + `wtype`, downloads the configured model, enables the user service, and turns on Vulkan GPU acceleration when available. |
| `.config/herdr/config.toml` | Herdr (agent workspace manager). Omarchy's tmux-style config, plus `confirm_close = true` and close-tab moved to `prefix+ctrl+k` (was `prefix+k`, right next to `j`). Agent-first layout: `hda cx cy` (in `functions.zsh`). |
| `.local/bin/` | `agent-toggle`, `dirsize`, `eachdir`, `pid`, `serve` (Python 3), `ssh-with-reverse`. |
| `.config/omarchy/themes/rafl` | **rafl** theme (Plum by night): rafl design-system palette, Rose gradient borders, confetti wallpapers, wordmark lock screen. `omarchy theme set rafl` |
| `.config/omarchy/themes/rafl-blush` | **rafl Blush** (Blush by day): light variant — flat blush surfaces, plum ink, no gold on light. `omarchy theme set rafl-blush` |
| `.config/omarchy/plugins/jc.daily-word` | **Daily Word** bar widget (center, left of the clock): a cross and today's ESV reference; hover for the verse text, click for the reading popup with the verse and a quote from Reformed church history (←/→ browse days, `c`/`q` copy, `o` open on esv.org); middle-click refetches. Needs a free ESV API key from [api.esv.org](https://api.esv.org): `daily-word set-key <key>` (stored in `~/.config/daily-word/`, not tracked). Edits under a symlinked plugin need `omarchy restart shell` — the shell's watcher doesn't follow symlinks. |
