-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Wispr Flow-style dictation (Omarchy's SUPER+CTRL+X toggle and F9 push-to-talk still work).
-- Hold Right Alt (code:108, where Right Cmd sits on a Mac) to talk; the bind swallows the key,
-- so its Compose role lives on Right Ctrl instead (see input.lua).
o.bind("code:108", "Start dictation (hold Right Alt)", "voxtype record start")
o.bind("code:108", "Stop dictation (release Right Alt)", "voxtype record stop", { release = true })
-- Hands-free: press once to start, again to stop (Ctrl+Opt+Cmd+Space on a Mac).
o.bind("CTRL + ALT + SUPER + SPACE", "Toggle dictation (hands-free)", "voxtype record toggle")

-- Center the focused floating window.
o.bind("SUPER + ALT + C", "Center floating window", hl.dsp.window.center())

-- Show/hide the coding agent (launches one if none is running).
o.bind("SUPER + A", "Toggle agent", "agent-toggle")

-- Mac-style Cmd+Tab: SUPER+TAB cycles windows instead of workspaces.
-- (Was: next/previous workspace. SUPER+1..9 and SUPER+CTRL+TAB still switch workspaces.)
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
o.bind("SUPER + TAB", "Focus on next window", hl.dsp.window.cycle_next())
o.bind("SUPER + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
o.bind("SUPER + SHIFT + TAB", "Focus on previous window", hl.dsp.window.cycle_next({ next = false }))
o.bind("SUPER + SHIFT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
