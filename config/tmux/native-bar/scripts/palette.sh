#!/usr/bin/env bash
# Shared vocabulary for tmux-native-bar: option access, colour resolution, cap markup.
#
# bash 3.2 compatible (macOS system bash): no associative arrays, no mapfile,
# no ${v^^}, no \uXXXX escapes. Cap glyphs are written as UTF-8 bytes.
#
# No hex colour literal appears here. Every colour is either a tmux colour NAME
# (which the terminal resolves from its own palette) or "default" (the terminal's
# own background/foreground). The @thm_* bridge is the sole exception, opt-in
# through @tnb_palette.

TNB_CAP_L=$'\xee\x82\xb6'   # U+E0B6 left half circle
TNB_CAP_R=$'\xee\x82\xb4'   # U+E0B4 right half circle

# tnb_opt <option> <default>
tnb_opt() {
  local v
  v="$(tmux show-option -gqv "$1" 2>/dev/null)"
  if [ -n "$v" ]; then printf '%s' "$v"; else printf '%s' "$2"; fi
}

# tnb_color <role> <ansi_default> <thm_name>
# Precedence: @tnb_<role>_color > @thm_<thm_name> (catppuccin mode only) > ansi default.
# Never returns empty: an empty colour makes "fg=" which tmux rejects, which would
# drop the whole format and blank the bar.
tnb_color() {
  local user palette v
  user="$(tmux show-option -gqv "@tnb_$1_color" 2>/dev/null)"
  if [ -n "$user" ]; then printf '%s' "$user"; return 0; fi
  palette="$(tnb_opt @tnb_palette ansi)"
  if [ "$palette" = "catppuccin" ] && [ -n "$3" ]; then
    v="$(tmux show-option -gqv "@thm_$3" 2>/dev/null)"
    if [ -n "$v" ]; then printf '%s' "$v"; return 0; fi
  fi
  printf '%s' "$2"
}

# tnb_mod_color <name>
# A tmux FORMAT (not a value) yielding the module colour, defaulting to white.
# Emitted rather than resolved so retuning the colour needs no rebuild.
#
# The value branch uses #{E:...}, not #{...}: a module colour may itself be a
# format -- the session module's "#{?client_prefix,red,green}" is exactly that --
# and plain substitution inserts it without re-expanding, leaving
# "fg=#{?client_prefix,red,green}" inside a style spec, which tmux cannot parse.
# The empty-check branch deliberately stays unexpanded, since it tests whether
# the option is set at all.
tnb_mod_color() {
  printf '#{?#{==:#{@tnb_module_%s_color},},white,#{E:@tnb_module_%s_color}}' "$1" "$1"
}

# tnb_cap_left <colour_expr> / tnb_cap_right <colour_expr>
# The cap glyph is drawn in the pill colour over bg=default. It is never drawn
# with `reverse` against a concrete background -- that technique requires a solid
# bar and produces a light halo the moment the bar is transparent.
# An unrecognised @tnb_caps falls through to rounded rather than emitting nothing.
tnb_cap_left() {
  case "$(tnb_opt @tnb_caps rounded)" in
    none)   printf '' ;;
    square) printf '#[none]#[bg=%s] ' "$1" ;;
    *)      printf '#[none]#[fg=%s,bg=default]%s' "$1" "$TNB_CAP_L" ;;
  esac
}

tnb_cap_right() {
  case "$(tnb_opt @tnb_caps rounded)" in
    none)   printf '' ;;
    square) printf '#[none]#[bg=%s] ' "$1" ;;
    *)      printf '#[none]#[fg=%s,bg=default]%s' "$1" "$TNB_CAP_R" ;;
  esac
}
