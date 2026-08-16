# nix-config

My personal Nix configuration managing **macOS** (via nix-darwin) from a single flake.

Built with [blueprint](https://github.com/numtide/blueprint) for auto-discovery of modules, [home-manager](https://github.com/nix-community/home-manager) for user-level config, [nixvim](https://github.com/nix-community/nixvim) for Neovim, [sops-nix](https://github.com/Mic92/sops-nix) for secrets, [nix-homebrew](https://github.com/zhaofengli/nix-homebrew) for macOS GUI apps, and [zoxide](https://github.com/ajeetdsouja/zoxide) for smarter cd.

## Structure

```
.
├── flake.nix                  # Inputs & blueprint entry point
├── .githooks/
│   └── pre-commit             # gitleaks secret scan (opt in via core.hooksPath)
├── treefmt.nix                # Formatter config (nixfmt, deadnix, statix, shfmt)
├── lib/
│   └── default.nix            # flake.lib.hostVars — loads + validates host variables
├── scripts/                   # shell scripts sourced by zsh-functions
│   ├── nix-util.sh            # everyday nix operations
│   └── nix-secret.sh          # sops secret manager
├── modules/
│   ├── darwin/
│   │   ├── system.nix         # macOS system defaults and firewall
│   │   ├── nix.nix            # nix daemon settings (gc, experimental features)
│   │   ├── homebrew.nix       # Homebrew taps, brews, casks, mas apps
│   │   └── home-manager.nix   # home-manager settings blueprint does not set
│   └── home/                  # home-manager modules (shared across hosts)
│       ├── zsh.nix
│       ├── neovim/            # neovim split into sub-modules
│       │   ├── default.nix    # core settings, opts, colorscheme
│       │   ├── keymaps.nix    # all keybindings
│       │   └── plugins.nix    # all plugin declarations
│       ├── git.nix
│       ├── ghostty.nix
│       ├── zellij.nix
│       ├── starship.nix
│       ├── lazygit.nix
│       ├── zed.nix
│       ├── aerospace.nix      # macOS window manager
│       ├── zsh-functions.nix  # sources scripts/ for interactive commands
│       └── secrets.nix        # sops-nix declarations and shell variables
└── hosts/
    └── macmini/               # Mac Mini (aarch64-darwin)
        ├── variables.nix      # host/user settings
        ├── host-packages.nix  # packages, home modules
        ├── darwin-configuration.nix
        └── users/
            └── munza.nix      # home-manager config, auto-wired by blueprint
```

## Quick Start

1. **Clone the repo:**

   ```sh
   git clone https://github.com/munza/nix-config.git ~/.nix-config
   ```

2. **Customise host variables** — edit the file for your machine:
   - [`hosts/macmini/variables.nix`](hosts/macmini/variables.nix)

   Change `host.name`, `user.name`, `user.email`, SSH keys, timezone, etc.

3. **Pick your packages** — edit the host-packages file for your host:
   - [`hosts/macmini/host-packages.nix`](hosts/macmini/host-packages.nix)

4. **Build & switch:**

   ```sh
   darwin-rebuild switch --flake ~/.nix-config#macmini
   ```

## Configuration Guide

### Host Variables (`hosts/<name>/variables.nix`)

Each host has a `variables.nix` that defines everything unique to that machine:

```nix
{
  host.platform = "aarch64-darwin";        # or "x86_64-linux"

  machine.sshPublicKeyFile = "~/.ssh/id_ed25519.pub";  # path only; the key stays out of the repo

  user = {
    name = "munza";
    fullName = "Tawsif Aqib";
    email = "hello@tawsifaqib.com";
  };

  # Pinned at install time; do not bump on upgrade.
  stateVersion = {
    system = 6;
    home = "26.05";
  };
}
```

Files are loaded through `flake.lib.hostVars <name>` (see [`lib/default.nix`](lib/default.nix)), which

- **fails with a named error** if a required field (`host.platform`, `user.{name,fullName,email}`, `stateVersion.{system,home}`) is missing, instead of erroring deep inside some module, and
- **derives the rest** so no host has to repeat it: `host.name` (from the directory name), `host.isDarwin` / `host.isLinux`, `user.homeDirectory` (`/Users/<n>` or `/home/<n>`), `nix.builder` (`darwin-rebuild` or `nixos-rebuild`), and `paths.config`.

Modules receive the resulting attrset as the `var` module argument.

### Host Packages (`hosts/<name>/host-packages.nix`)

Controls what gets installed and which home-manager modules are enabled:

```nix
{ pkgs, inputs }:

{
  # Which home-manager modules to load (from modules/home/)
  homeModules = with inputs.self.homeModules; [
    git neovim zsh starship zellij lazygit secrets
  ];

  # System-level packages
  systemPackages = with pkgs; [
    bat btop curl fd ripgrep tree nodejs python3 ...
  ];

  # AI coding tools (from llm-agents input)
  aiTools = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    opencode pi
  ];

  # Homebrew casks, taps, brews
  homebrew = {
    casks = [ "ghostty" "zed" "google-chrome" "obsidian" ... ];
  };
}
```

### Everyday Commands (`nix-util`)

All routine Nix operations go through one command rather than a pile of
aliases. It always acts on this flake and the current host, so it works from any
directory. Run it bare for a menu.

```sh
nix-util                  # interactive menu
nix-util rebuild          # build and switch this host
nix-util update           # update every flake input
nix-util update nixpkgs   # update one input
nix-util search ripgrep   # search nixpkgs
nix-util check            # nix flake check --all-systems --no-build
nix-util check -v         # ... and show nix's warnings
nix-util fmt              # format the repo with treefmt
nix-util diff             # uncommitted flake.lock diff
nix-util generations      # list system generations
nix-util rollback         # switch back to the previous generation
nix-util clean            # collect garbage (user + root) and optimise the store
```

`nix-util update` deliberately does more than `nix flake update`: it shows what
moved in `flake.lock`, offers the full diff, and then runs the flake check, so a
bad input is caught before it becomes a root activation. `nix-util clean`
collects garbage in both the user and root profiles — only the latter frees
system closures — keeping generations newer than 30 days (override with
`NIX_GC_DAYS`). `nix-util check` hides Nix's warnings — blueprint emits flake
outputs Nix does not recognise, so even a clean run is noisy — pass `-v` to see
them.

The command lives in [`scripts/nix-util.sh`](scripts/nix-util.sh) and is sourced
by [`zsh-functions.nix`](modules/home/zsh-functions.nix), which sets the
`FLAKE_DIR`, `NIX_BUILDER` and `NIX_HOST` it reads. Secrets are a separate
concern; see [`nix-secret`](#secrets-sops-nix).

### Formatting

Run `nix fmt` to format the codebase using [treefmt-nix](https://github.com/numtide/treefmt-nix):

- **nixfmt** — Nix formatting
- **deadnix** — detect unused bindings
- **statix** — detect anti-patterns
- **shfmt** — shell script formatting

Run `nix flake check --all-systems --no-build` before pushing. It evaluates the complete system closure of every host in `hosts/`, plus the formatting check.

### Secrets (sops-nix)

Secrets are encrypted with [sops](https://github.com/getsops/sops) to the age key derived from each host's SSH key, and stored in a separate private repo.

#### If you cloned this repo

This repo is public and contains **no secrets and no keys** — only the tooling
that manages them. Nothing here decrypts with my keys or points at my data, so
you can fork it as-is. But the `secrets` flake input points at *my* private
repo, which you cannot read, so you must either point it at your own or turn
secrets off.

**Option A — turn secrets off** (fine if you do not need any):

Drop `secrets` from the `homeModules` list in
[`hosts/<name>/host-packages.nix`](hosts/macmini/host-packages.nix), and delete
the `secrets` input from [`flake.nix`](flake.nix). Nothing else depends on it.

**Option B — use your own secrets repo:**

1. **Create a private repo** (any host, any name) with a single empty commit.
   It needs no particular contents; `nix-secret` creates `secrets/` and
   `.sops.yaml` on first use.

2. **Point the flake input at it** in [`flake.nix`](flake.nix):

   ```nix
   secrets = {
     url = "git+ssh://git@github.com/<you>/<your-secrets-repo>.git";
     flake = false;
   };
   ```

   Keep `flake = false;` and use an SSH URL — the repo is private, and
   `nix-secret` reuses your SSH agent to reach it.

3. **Set `machine.sshPublicKeyFile`** in `hosts/<name>/variables.nix` to your
   own host key (`~/.ssh/id_ed25519.pub`). This is what your secrets get
   encrypted to. Generate one first if you have none:

   ```sh
   ssh-keygen -t ed25519 -C "<you>@<host>"
   ```

4. **Bootstrap and add your first secret:**

   ```sh
   nix-secret pull        # clones your repo to ~/.nix-secret
   nix-secret sync-keys   # writes .sops.yaml with your host as recipient
   nix-secret add         # add a secret, pick the scope
   nix-secret sync        # commit + push, then bump the flake input
   ```

5. **Rebuild.** `darwin-rebuild switch --flake ~/.nix-config#<name>`

Your secret values never touch this repo, and your private key never leaves
`~/.ssh` — sops derives an age identity from it in memory at decrypt time.

#### How it works

**Secrets live in a separate private repo** so that no ciphertext lands in this
public one, and are pulled in as the `secrets` flake input. `nix-secret` keeps a
working checkout at `~/.nix-secret` (override with `NIX_SECRETS_DIR`) and clones
it on demand over SSH.

**Scopes.** Inside that repo, secrets are JSON files, one per scope:

```
secrets/common.json      # readable by every host
secrets/macmini.json     # readable by macmini only
secrets/<hostname>.json  # one per host, created on demand
```

> **A secret is not live until the flake input is bumped.** This flake
> pins the secrets repo by revision, so editing a secret is not enough — you
> must commit, push, and bump. `nix-secret sync` does all three, and every
> mutating command reminds you to run it.

Recipients are declared in the secrets repo's `.sops.yaml`, which is **generated** by `nix-secret sync-keys` — never edit it by hand. Each host points at a public key _by path_ (`machine.sshPublicKeyFile`), so the key itself never enters the repo; `sync-keys` reads it and converts it to an age recipient with `ssh-to-age`.

Because the key lives outside the repo, `sync-keys` can only generate a rule for a host whose public key is readable on the machine you run it from. Keep other hosts' `.pub` files somewhere local (for example `~/.ssh/hosts/homelab.pub`) and point `sshPublicKeyFile` at them; hosts whose key is missing are skipped with a warning rather than failing the run.

sops encrypts values but leaves object keys in plaintext, so `modules/home/secrets.nix` reads the secret _names_ straight out of the JSON at evaluation time. There is no registry to keep in sync: add a secret to a file and its environment variable appears on the next rebuild. Only ciphertext is ever read during evaluation.

**Use the `nix-secret` command:**

```sh
nix-secret              # interactive menu
nix-secret add          # add a secret, choosing its scope
nix-secret read <name>  # print a secret's value
nix-secret list         # every secret and the scope it lives in
nix-secret edit         # open a whole scope in $EDITOR
nix-secret update       # replace an existing secret value
nix-secret remove       # remove a secret
nix-secret rekey        # re-encrypt after recipients change
nix-secret sync-keys    # regenerate .sops.yaml from hosts/*/variables.nix
nix-secret pull         # clone/update the local secrets checkout
nix-secret sync         # commit + push secrets, then bump the flake input
```

`list` and the scope lookups need no key material at all, since names are plaintext. Everything that decrypts or writes derives an age identity in memory from `~/.ssh/id_ed25519` via `ssh-to-age`; no second copy of the private key is written to disk. Override with `SOPS_AGE_SSH_KEY`, or bypass with the standard `SOPS_AGE_KEY` / `SOPS_AGE_KEY_FILE`.

> **Flakes only see git-tracked files.** A secrets file that is not staged is silently invisible to the build, and its secrets simply will not appear. `nix-secret` stages new files for you; if you create one by hand, `git add` it in the secrets repo.

**Add a new secret manually:**

```sh
sops ~/.nix-secret/secrets/common.json   # opens $EDITOR with the decrypted JSON
nix-secret sync
```

Add a `"my-secret": "value"` entry, save, sync, then rebuild.

Secret names are converted to uppercase environment variables (for example, `github-access-token` becomes `GITHUB_ACCESS_TOKEN` and `GITHUB_ACCESS_TOKEN_FILE`). Values are intentionally exported to interactive Zsh sessions and inherited by their child processes. They are not added to the Nix store or exported globally to unrelated GUI applications and services.

**Add a new host:**

New hosts can leave `machine.sshPublicKeyFile` unset while they are being prepared; `sync-keys` skips them with a warning. Once the host key exists and its `.pub` is readable locally, set `machine.sshPublicKeyFile`, then:

```sh
nix-secret sync-keys    # adds the host to .sops.yaml and offers to rekey
```

The host can immediately read `secrets/common.json`. Give it private secrets by adding them to `secrets/<hostname>.json` via `nix-secret add`.

**Revoke a host** by removing it from `hosts/`, running `sync-keys`, and rekeying. Note that rekeying does not change the secret values — anything the host already read should be rotated at the source.

**Use a secret in a service:**

```nix
serviceConfig.EnvironmentFile = config.sops.secrets.my-secret.path;
```

### Security

This repo is public, so nothing here holds key material: secrets are ciphertext
in a separate private repo, and host public keys are referenced by path. Three
habits keep it that way.

**1. Secret scanning at the remote.** Enable GitHub's push protection on the
repo (Settings → Code security → *Secret Protection*: turn on *Secret scanning*
and *Push protection*). Free on public repos, and it rejects a push containing a
recognised credential rather than alerting after the fact.

**2. Secret scanning locally.** [`gitleaks`](https://github.com/gitleaks/gitleaks)
is in `systemPackages`, and [`.githooks/pre-commit`](.githooks/pre-commit) runs
it over the staged diff. Git does not track hook configuration, so enable it
once per clone:

```sh
git config core.hooksPath .githooks
```

The hook is a no-op if `gitleaks` is not installed yet, so it will not block a
first-time build. Mark a false positive with a `# gitleaks:allow` comment on the
offending line.

**3. Review the lock diff before switching.** A rebuild runs every flake input's
code as root, so `flake.lock` is the supply-chain surface. `nix-util update`
prints the lock diffstat, offers the full diff, and only then runs the check —
skim which inputs moved before `nix-util rebuild`.

If you cloned this repo, also check that you repointed the `secrets` input at
your own private repo (see [Secrets](#secrets-sops-nix)) — otherwise the build
tries to fetch a repo you cannot read.

### Adding a New Host

1. Create `hosts/<name>/` with the entry points Blueprint expects:
   - `variables.nix` — host-specific settings (see above)
   - `host-packages.nix` — packages and home-manager modules
   - `darwin-configuration.nix` for macOS, or `configuration.nix` (plus `hardware-configuration.nix`) for NixOS
   - `users/<username>.nix` — home-manager config; Blueprint imports the right home-manager module for the host class automatically

   Nothing in `flake.nix` needs editing: Blueprint discovers the host, and `nix flake check` picks up its system closure as `checks.<system>.{darwin,nixos}-<name>` on its own. Add the host's platform to `systems` in `flake.nix` only if it is not already listed.

2. Set `machine.sshPublicKeyFile` in `hosts/<name>/variables.nix` to a path holding that host's public key.

3. Run `nix-secret sync-keys` to add the host to `.sops.yaml` and rekey.

4. Build and switch with `darwin-rebuild`/`nixos-rebuild switch --flake ~/.nix-config#<name>` (`nix-util rebuild` does this for the current host).

### Home Manager Modules (`modules/home/`)

Shared across all hosts. Enable/disable per host via the `homeModules` list in `host-packages.nix`. Each module is auto-discovered by blueprint and exposed as `inputs.self.homeModules.<name>`.

Modules that touch platform-specific paths branch on `pkgs.stdenv.hostPlatform.isDarwin` (for example [`ghostty.nix`](modules/home/ghostty.nix), where macOS takes the app from Homebrew and other platforms from nixpkgs). Modules that depend on a package the host may not install — such as [`clamav.nix`](modules/home/clamav.nix) — are kept separate so a host opts in explicitly.

Each user also gets a standalone configuration: `home-manager switch --flake .#munza@macmini`.

## License

[MIT](LICENSE) — personal configuration, but use it freely as a reference or
starting point. Fork it, strip what you do not need, keep the copyright notice.

Flake inputs (nixpkgs, home-manager, nixvim, sops-nix, blueprint, …) carry their
own licenses.
