#!/usr/bin/env bash
# nix-util — everyday Nix operations for this flake
#
# Every subcommand acts on $FLAKE_DIR and the current host, so none of them care
# what directory you are in. $NIX_BUILDER is darwin-rebuild or nixos-rebuild,
# resolved per host by lib/default.nix; $NIX_HOST is the flake attribute.
#
# USAGE:
#   nix-util                  — interactive menu
#   nix-util rebuild          — build and switch this host
#   nix-util update [input]   — update flake inputs (all, or just one), show the lock diff, then check
#   nix-util search <term>    — search nixpkgs for a package
#   nix-util check [-v]       — flake check; -v also shows nix warnings
#   nix-util fmt              — format the repo with treefmt
#   nix-util diff             — show the uncommitted flake.lock diff
#   nix-util generations      — list system generations
#   nix-util rollback         — switch back to the previous generation
#   nix-util clean            — collect garbage and optimise the store
#
# Secrets are a separate concern; see nix-secret.

: "${FLAKE_DIR:?FLAKE_DIR is not set}"

_nu_err() { gum style --foreground 1 "$*"; }
_nu_ok() { gum style --foreground 2 "$*"; }
_nu_info() { gum style --foreground 4 "$*"; }

_nu_builder() { echo "${NIX_BUILDER:-darwin-rebuild}"; }
_nu_host() { echo "${NIX_HOST:-$(hostname -s)}"; }

_nu_rebuild() {
  _nu_info "switching $(_nu_host) via $(_nu_builder)"
  sudo "$(_nu_builder)" switch --flake "$FLAKE_DIR#$(_nu_host)"
}

# Inputs run as root at switch time, so the lock diff is the review surface.
# Always show what moved before offering to build on it.
_nu_update() {
  local input="$1"

  if [ -n "$input" ]; then
    _nu_info "updating input: $input"
    nix flake update "$input" --flake "$FLAKE_DIR" || return 1
  else
    _nu_info "updating all inputs"
    nix flake update --flake "$FLAKE_DIR" || return 1
  fi

  if git -C "$FLAKE_DIR" diff --quiet -- flake.lock; then
    _nu_ok "already up to date; nothing moved"
    return 0
  fi

  git -C "$FLAKE_DIR" diff --stat -- flake.lock
  gum confirm "review the full lock diff?" --default=No && _nu_diff

  _nu_check
}

_nu_search() {
  local term="$1"
  [ -z "$term" ] && term=$(gum input --placeholder "package to search for")
  [ -z "$term" ] && return 0
  nix search nixpkgs "$term"
}

# Blueprint emits flake outputs Nix does not recognise, so a clean run is still
# noisy. Warnings are hidden unless asked for; filtering stderr through a
# process substitution keeps nix's own exit status, which a pipe would not.
_nu_check() {
  case "$1" in
  -v | --verbose)
    nix flake check "$FLAKE_DIR" --all-systems --no-build
    ;;
  "")
    nix flake check "$FLAKE_DIR" --all-systems --no-build \
      2> >(grep -vE '^(warning|evaluation warning):' >&2)
    ;;
  *)
    _nu_err "unknown flag: $1 (use -v to show warnings)"
    return 1
    ;;
  esac
}

_nu_fmt() { nix fmt "$FLAKE_DIR"; }

_nu_diff() { git -C "$FLAKE_DIR" diff -- flake.lock; }

_nu_generations() {
  "$(_nu_builder)" --list-generations 2>/dev/null ||
    ls -1t /nix/var/nix/profiles/system-*-link 2>/dev/null ||
    _nu_err "could not list generations"
}

_nu_rollback() {
  gum confirm "roll $(_nu_host) back to the previous generation?" --default=No || return 0
  sudo "$(_nu_builder)" switch --rollback
}

# Garbage collection is per-profile: the user store and the root store both
# hold generations, and only the second one frees system closures.
_nu_clean() {
  local days="${NIX_GC_DAYS:-30}"

  _nu_info "deleting generations older than ${days}d"
  nix-collect-garbage --delete-older-than "${days}d" || return 1
  sudo nix-collect-garbage --delete-older-than "${days}d" || return 1

  _nu_info "optimising the store"
  nix store optimise

  _nu_ok "done"
}

nix-util() {
  local action="$1"

  if [ -z "$action" ]; then
    action=$(gum choose --header="nix utils" \
      "rebuild" \
      "update" \
      "search" \
      "check" \
      "fmt" \
      "diff" \
      "generations" \
      "rollback" \
      "clean")
  fi

  [ -z "$action" ] && return 0

  case "$action" in
  "rebuild") _nu_rebuild ;;
  "update") _nu_update "$2" ;;
  "search") _nu_search "$2" ;;
  "check") _nu_check "$2" ;;
  "fmt") _nu_fmt ;;
  "diff") _nu_diff ;;
  "generations") _nu_generations ;;
  "rollback") _nu_rollback ;;
  "clean") _nu_clean ;;
  *)
    _nu_err "unknown action: $action"
    return 1
    ;;
  esac
}
