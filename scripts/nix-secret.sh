#!/usr/bin/env bash
# nix-secret — manage sops secrets with charm
#
# Secrets live in a separate private repo (the `secrets` flake input), in
# secrets/<scope>.json where scope is "common" (all hosts) or a hostname.
# Recipients are declared in its .sops.yaml, generated from
# hosts/*/variables.nix by `nix-secret sync-keys`.
#
# This operates on a local checkout of that repo, cloned on demand. Because the
# dotfiles flake pins it by revision, a change is not live until the input is
# bumped — `nix-secret sync` commits, pushes and bumps in one step.
#
# USAGE:
#   nix-secret                — interactive menu
#   nix-secret pull           — clone/update the local secrets checkout
#   nix-secret sync           — commit + push secrets, then bump the flake input
#   nix-secret add            — add a secret to a scope
#   nix-secret read <name>    — print a secret value
#   nix-secret list           — list secrets and their scope
#   nix-secret edit           — open a whole scope in $EDITOR
#   nix-secret update         — replace a secret's value
#   nix-secret remove         — delete a secret
#   nix-secret rekey          — re-encrypt after recipients change
#   nix-secret sync-keys      — regenerate .sops.yaml from hosts/*/variables.nix

: "${DOTFILES:?DOTFILES is not set}"

# Working checkout of the private secrets repo; not inside $DOTFILES so its
# ciphertext never lands in the public repo.
readonly SECRETS_REPO="${NIX_SECRETS_DIR:-$HOME/.nix-secret}"
readonly SECRETS_DIR="$SECRETS_REPO/secrets"
readonly HOSTS_DIR="$DOTFILES/hosts"
readonly SOPS_CONFIG="$SECRETS_REPO/.sops.yaml"

# The dotfiles flake is the single source of truth for where secrets live.
_secrets_url() {
  nix flake metadata "$DOTFILES" --json 2>/dev/null |
    python3 -c 'import json,sys
n = json.load(sys.stdin)["locks"]["nodes"]
print(n["secrets"]["original"]["url"] if "secrets" in n else "")' 2>/dev/null
}

# Clone the secrets repo on first use. git handles SSH auth via your agent.
_ensure_repo() {
  local url

  [ -d "$SECRETS_REPO/.git" ] && return 0

  url=$(_secrets_url)
  if [ -z "$url" ]; then
    _err "no 'secrets' input in $DOTFILES/flake.nix — nothing to clone"
    return 1
  fi

  gum style --foreground 4 "cloning $url -> $SECRETS_REPO"
  git clone "$url" "$SECRETS_REPO" || return 1
}

# sops discovers .sops.yaml by walking up from $PWD, so without --config
# nix-secret only works from inside $DOTFILES. Every call goes through here.
_sops() { sops --config "$SOPS_CONFIG" "$@"; }

_err() { gum style --foreground 1 "$*"; }
_ok() { gum style --foreground 2 "$*"; }

_valid_name() {
  [[ $1 =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]
}

# All scopes that have a file, plus every scope that could have one.
_scopes() {
  local varfile
  echo "common"
  # NOTE: this file is sourced into zsh, where `path` is a special array bound
  # to $PATH. Never use it as a loop variable.
  for varfile in "$HOSTS_DIR"/*/variables.nix; do
    [ -e "$varfile" ] || continue
    basename "$(dirname "$varfile")"
  done
}

_scope_file() {
  echo "$SECRETS_DIR/$1.json"
}

_existing_files() {
  local file
  while IFS= read -r scope; do
    file=$(_scope_file "$scope")
    [ -e "$file" ] && echo "$file"
  done < <(_scopes)
}

# name<TAB>scope for every secret that exists. sops leaves object keys in
# plaintext, so this needs no key material and no decryption.
_list_secrets() {
  local file scope
  while IFS= read -r file; do
    scope=$(basename "${file%.json}")
    python3 -c 'import json,sys
for k in json.load(open(sys.argv[1])):
    if k not in ("sops", "_placeholder"): print(k)' "$file" 2>/dev/null |
      while IFS= read -r name; do printf '%s\t%s\n' "$name" "$scope"; done
  done < <(_existing_files)
}

# sops has no native ssh-key support; derive the age identity in memory rather
# than writing a second copy of the private key to disk.
_age_identity() {
  local key="${SOPS_AGE_SSH_KEY:-$HOME/.ssh/id_ed25519}"

  if [ -n "${SOPS_AGE_KEY:-}" ] || [ -n "${SOPS_AGE_KEY_FILE:-}" ]; then
    return 0
  fi

  if [ ! -r "$key" ]; then
    _err "no age identity: $key is missing (set SOPS_AGE_SSH_KEY or SOPS_AGE_KEY)"
    return 1
  fi

  SOPS_AGE_KEY=$(ssh-to-age -private-key -i "$key") || return 1
  export SOPS_AGE_KEY
}

_secret_names() { _list_secrets | cut -f1; }

_file_for_secret() {
  local name="$1" scope
  scope=$(_list_secrets | awk -F'\t' -v n="$name" '$1 == n { print $2; exit }')
  [ -z "$scope" ] && return 1
  _scope_file "$scope"
}

# Create an encrypted-but-empty scope file so `_sops set` has metadata to work with.
_ensure_file() {
  local file="$1"

  [ -e "$file" ] && return 0

  if ! grep -qF "secrets/$(basename "${file%.json}")\\.json" "$SOPS_CONFIG" 2>/dev/null; then
    _err "no creation rule in .sops.yaml for $(basename "$file") — run 'nix-secret sync-keys'"
    return 1
  fi

  mkdir -p "$SECRETS_DIR"
  echo '{"_placeholder":"remove me"}' >"$file"
  if ! _sops encrypt --in-place "$file"; then
    rm -f "$file"
    return 1
  fi

  _git_track "$file"
}

# Flakes only see git-tracked files, so an unstaged secrets file is silently
# invisible to the build. Stage it as soon as it exists.
_git_track() {
  git -C "$SECRETS_REPO" add --intent-to-add "$1" 2>/dev/null || true
}

_ns_pull() {
  _ensure_repo || return 1
  git -C "$SECRETS_REPO" pull --ff-only || return 1
  _ok "secrets checkout up to date"
}

# Publish local secret changes and point the dotfiles flake at them. Skipping
# the bump is the most confusing possible failure: the secret exists, is
# committed, and still does not appear after a rebuild.
_ns_sync() {
  _ensure_repo || return 1

  git -C "$SECRETS_REPO" add -A
  if git -C "$SECRETS_REPO" diff --cached --quiet; then
    gum style --foreground 3 "no secret changes to publish"
  else
    git -C "$SECRETS_REPO" commit -q -m "secrets: update $(date -u +%Y-%m-%dT%H:%M:%SZ)" || return 1
    git -C "$SECRETS_REPO" push -q || return 1
    _ok "pushed secret changes"
  fi

  if ! (cd "$DOTFILES" && nix flake update secrets); then
    _err "failed to bump the secrets input"
    return 1
  fi

  _ok "flake input bumped — run 'nix-secret sync' then 'nix-rebuild'"
}

# Write a value without it ever appearing in argv.
_set_value() {
  local file="$1" name="$2" value="$3"

  printf '%s' "$value" |
    python3 -c 'import json,sys; sys.stdout.write(json.dumps(sys.stdin.read()))' |
    _sops set --value-stdin "$file" "[\"$name\"]"
}

_ns_add() {
  local name value scope file

  _ensure_repo || return 1

  _age_identity || return 1

  scope=$(_scopes | gum choose --header="which hosts should be able to decrypt it?")
  [ -z "$scope" ] && return 1
  file=$(_scope_file "$scope")

  name=$(gum input --placeholder "secret-name-in-kebab-case" --char-limit=64)
  [ -z "$name" ] && return 1

  if ! _valid_name "$name"; then
    _err "name must be kebab-case (lowercase letters, digits, hyphens)"
    return 1
  fi

  if _secret_names | grep -qx "$name"; then
    _err "'$name' already exists"
    return 1
  fi

  value=$(gum input --placeholder "enter secret value" --password)
  [ -z "$value" ] && return 1

  _ensure_file "$file" || return 1

  if ! _set_value "$file" "$name" "$value"; then
    _err "failed to encrypt '$name'"
    return 1
  fi

  # Drop the bootstrap placeholder once a real secret is in the file.
  _sops unset "$file" '["_placeholder"]' 2>/dev/null || true

  _ok "added '$name' to $scope — run 'nix-secret sync' then 'nix-rebuild'"
}

_ns_read() {
  local name="$1" scope_file

  if [ -z "$name" ]; then
    echo "Usage: nix-secret read <secret-name>"
    echo "Available secrets:"
    _list_secrets | awk -F'\t' '{ printf "  %s (%s)\n", $1, $2 }'
    return 1
  fi

  if ! _valid_name "$name"; then
    _err "invalid secret name: $name"
    return 1
  fi

  # Always resolve through the repo. Reading whatever ${NAME}_FILE happens to
  # point at would return a stale generation, or another host's value entirely.
  if ! scope_file=$(_file_for_secret "$name"); then
    _err "unknown secret: $name"
    return 1
  fi

  _age_identity || return 1
  _sops decrypt --extract "[\"$name\"]" "$scope_file"
}

_ns_list() {
  _list_secrets | awk -F'\t' '{ printf "%s\t%s\n", $2, $1 }' | sort |
    gum table --print --separator=$'\t' --columns="SCOPE,SECRET" 2>/dev/null ||
    _list_secrets | awk -F'\t' '{ printf "  %-24s %s\n", $1, $2 }'
}

_ns_edit() {
  local scope file

  _ensure_repo || return 1

  _age_identity || return 1

  scope=$(_existing_files | xargs -n1 basename | sed 's/\.json$//' |
    gum choose --header="edit which scope?")
  [ -z "$scope" ] && return 1

  file=$(_scope_file "$scope")
  _sops edit "$file" && _ok "edited $scope — run 'nix-secret sync' then 'nix-rebuild'"
}

_ns_update() {
  local name value file

  _ensure_repo || return 1

  _age_identity || return 1

  name=$(_secret_names | gum filter --placeholder "select a secret...")
  [ -z "$name" ] && return 1

  file=$(_file_for_secret "$name") || return 1

  value=$(gum input --placeholder "enter new value" --password)
  [ -z "$value" ] && return 1

  if ! _set_value "$file" "$name" "$value"; then
    _err "failed to update '$name'"
    return 1
  fi

  _ok "updated '$name' — run 'nix-secret sync' then 'nix-rebuild'"
}

_ns_remove() {
  local name file

  _ensure_repo || return 1

  _age_identity || return 1

  name=$(_secret_names | gum filter --placeholder "select a secret...")
  [ -z "$name" ] && return 1

  file=$(_file_for_secret "$name") || return 1

  gum confirm "remove '$name'?" --default=No || return 1

  if ! _sops unset "$file" "[\"$name\"]"; then
    _err "failed to remove '$name'"
    return 1
  fi

  _ok "removed '$name' — run 'nix-secret sync' then 'nix-rebuild'"
}

_ns_rekey() {
  local file

  _ensure_repo || return 1

  _age_identity || return 1

  while IFS= read -r file; do
    if ! _sops updatekeys -y "$file"; then
      _err "failed to rekey $(basename "$file")"
      return 1
    fi
  done < <(_existing_files)

  _ok "rekeyed all secrets"
}

# Regenerate .sops.yaml from the public key each host points at. This is
# what secrets/secrets.nix used to do at evaluation time; .sops.yaml is plain
# YAML, so it has to be generated instead.
_ns_sync_keys() {
  _ensure_repo || return 1

  local host keyfile pubkey agekey rules keys count=0

  keys=""
  rules=""

  while IFS= read -r host; do
    keyfile=$(nix eval --raw --impure \
      --expr "(import $HOSTS_DIR/$host/variables.nix).machine.sshPublicKeyFile or \"\"" 2>/dev/null || true)

    if [ -z "$keyfile" ]; then
      gum style --foreground 3 "skipping '$host' — no machine.sshPublicKeyFile yet"
      continue
    fi

    # The key lives outside the repo, so it is only reachable for hosts whose
    # public key is present on this machine.
    keyfile="${keyfile/#\~/$HOME}"
    if [ ! -r "$keyfile" ]; then
      gum style --foreground 3 "skipping '$host' — $keyfile not readable here"
      continue
    fi

    pubkey=$(cat "$keyfile")

    if ! agekey=$(printf '%s\n' "$pubkey" | ssh-to-age 2>/dev/null) || [ -z "$agekey" ]; then
      _err "could not convert '$host' ssh key to an age recipient"
      return 1
    fi

    keys="${keys}  - &${host} ${agekey}"$'\n'
    rules="${rules}  - path_regex: secrets/${host}\\.json\$"$'\n'
    rules="${rules}    key_groups:"$'\n'
    rules="${rules}      - age:"$'\n'
    rules="${rules}          - *${host}"$'\n'
    count=$((count + 1))
  done < <(_scopes | grep -v '^common$')

  if [ "$count" -eq 0 ]; then
    _err "no hosts with a readable machine.sshPublicKeyFile — nothing to do"
    return 1
  fi

  # common.json goes to every host.
  local common_refs=""
  while IFS= read -r host; do
    grep -q "&${host} " <<<"$keys" && common_refs="${common_refs}          - *${host}"$'\n'
  done < <(_scopes | grep -v '^common$')

  {
    # shellcheck disable=SC2016  # literal backticks; shfmt reverts escaping
    echo '# Generated by `nix-secret sync-keys`. Do not edit by hand.'
    echo "# Recipients come from the key at machine.sshPublicKeyFile in hosts/*/variables.nix."
    echo "keys:"
    printf '%s' "$keys"
    echo "creation_rules:"
    echo '  - path_regex: secrets/common\.json$'
    echo "    key_groups:"
    echo "      - age:"
    printf '%s' "$common_refs"
    printf '%s' "$rules"
  } >"$SOPS_CONFIG.tmp" && mv "$SOPS_CONFIG.tmp" "$SOPS_CONFIG"
  _git_track "$SOPS_CONFIG"

  _ok "wrote .sops.yaml for $count host(s)"

  if [ -n "$(_existing_files)" ]; then
    gum confirm "rekey existing secrets with the new recipients?" --default=Yes && _ns_rekey
  fi
}

nix-secret() {
  local action="$1"

  if [ -z "$action" ]; then
    action=$(gum choose --header="secrets manager" \
      "add" \
      "read" \
      "list" \
      "edit" \
      "update" \
      "remove" \
      "rekey" \
      "pull" \
      "sync" \
      "sync-keys")
  fi

  [ -z "$action" ] && return 0

  case "$action" in
  "add") _ns_add ;;
  "read") _ns_read "$2" ;;
  "list") _ns_list ;;
  "edit") _ns_edit ;;
  "update") _ns_update ;;
  "remove") _ns_remove ;;
  "rekey") _ns_rekey ;;
  "pull") _ns_pull ;;
  "sync") _ns_sync ;;
  "sync-keys") _ns_sync_keys ;;
  *)
    _err "unknown action: $action"
    return 1
    ;;
  esac
}
