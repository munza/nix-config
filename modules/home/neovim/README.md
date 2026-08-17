# Neovim

Open this file any time with `:Howto`.

Leader is `<space>`. Press it and wait — `mini.clue` shows every binding under
it, which is faster than reading this file.

## Contents

- [How the configuration works](#how-the-configuration-works)
- [Editing it](#editing-it)
- [Keymaps](#keymaps)
  - [Files and pickers](#files-and-pickers)
  - [LSP and code](#lsp-and-code)
  - [Buffers and windows](#buffers-and-windows)
  - [Git](#git)
  - [Debug (`<leader>d`)](#debug-leaderd)
  - [AI (`<leader>a`)](#ai-leadera)
  - [Selection (`<leader>v`)](#selection-leaderv)
  - [Completion](#completion)
  - [From mini.nvim](#from-mininvim)
- [Troubleshooting](#troubleshooting)

Inside nvim these are plain text, so jump with `gO` for a live outline, or
search: `/## Keymaps`.

## How the configuration works

Neovim is built by [nixvim](https://github.com/nix-community/nixvim): plugins
and their settings are declared in Nix, and the whole thing is compiled into a
single `init.lua` at build time. Two consequences matter day to day:

- **Nothing installs at runtime.** No lazy.nvim, no `:PackerSync`. A plugin
  exists because it is declared in `plugins.nix`.
- **The config in `~/.config/nvim` is read-only**, because it lives in the Nix
  store. Editing it there does nothing; the change is overwritten on the next
  rebuild.

Files, all in `modules/home/neovim/`:

| File          | Holds                                                                                 |
| ------------- | ------------------------------------------------------------------------------------- |
| `default.nix` | Core options, colourscheme, and `extraPackages` — the binaries nvim needs on its PATH |
| `plugins.nix` | Every plugin and its settings                                                         |
| `keymaps.nix` | Every keymap                                                                          |
| `README.md`   | This file                                                                             |

`extraPackages` is worth understanding: formatters, linters and debug adapters
are put on _nvim's_ PATH, not your shell's. `which gofumpt` in a terminal comes
up empty while conform still formats Go correctly. That is deliberate — the
tools follow the editor rather than cluttering the system profile.

## Editing it

Every change follows the same loop: edit a file, then

```sh
nix-util rebuild
```

and restart nvim. `nix-util check` evaluates the config without building if you
just want to know whether it is valid.

**Add a keymap** — `keymaps.nix`, in the group it belongs to:

```nix
(nmap "<leader>xx" "<cmd>SomeCommand<CR>" "What it does")
```

`nmap` binds in normal mode and takes key, action, description. The description
is not optional decoration: it is what `mini.clue` shows in the popup. For a
binding that needs to wait for a character (`vi(` style), use `selectPrompting`
instead.

If you add a new `<leader>` prefix, add it to `mini.clue`'s `clues` list in
`plugins.nix` too, or the popup will show it unlabelled.

**Add a plugin** — `plugins.nix`. Most need only:

```nix
plugin-name.enable = true;
```

Available options for any plugin are at
[nix-community.github.io/nixvim](https://nix-community.github.io/nixvim/). If a
plugin is not packaged by nixvim, it needs `extraPlugins` with a nixpkgs
derivation.

**Add a language server** — `plugins.nix`, under `lsp.servers`:

```nix
lsp.servers.elixirls.enable = true;
```

nixvim pulls in the server binary itself.

**Add a formatter or linter** — two steps. Declare which filetypes use it under
`conform-nvim` (or `lint`), then add the binary to `extraPackages` in
`default.nix`. Forgetting the second step is the usual cause of "format on save
silently does nothing".

**Add a treesitter grammar** — `plugins.nix`, in `treesitter.grammarPackages`.
Grammars are pinned at build time, so `:TSInstall` is not how it works here.

## Keymaps

### Files and pickers

| Key          | Action               |
| ------------ | -------------------- |
| `<leader>e`  | Toggle file explorer |
| `<leader>ff` | Find files           |
| `<leader>fg` | Live grep            |
| `<leader>fb` | Find buffers         |
| `<leader>fh` | Help tags            |
| `<leader>fr` | Recent files         |
| `<leader>fd` | Diagnostics list     |

In the picker, type to filter, `<C-n>`/`<C-p>` to move, `<CR>` to open. In the
file explorer, `<CR>` opens, `g?` shows its own help.

### LSP and code

| Key          | Action                     |
| ------------ | -------------------------- |
| `gd`         | Go to definition           |
| `gr`         | References                 |
| `K`          | Hover docs                 |
| `<leader>ca` | Code action                |
| `<leader>rn` | Rename symbol              |
| `<leader>cd` | Line diagnostics           |
| `<leader>cf` | Format file                |
| `[d` / `]d`  | Previous / next diagnostic |

Formatting also runs automatically on save, falling back to the language server
when no formatter is configured for the filetype.

### Buffers and windows

| Key               | Action                            |
| ----------------- | --------------------------------- |
| `<S-h>` / `<S-l>` | Previous / next buffer            |
| `<leader>bd`      | Delete buffer                     |
| `<C-h/j/k/l>`     | Move to window left/down/up/right |
| `<Esc>`           | Clear search highlights           |

### Git

| Key          | Action  |
| ------------ | ------- |
| `<leader>gg` | LazyGit |

Signs in the gutter come from `mini.diff`; `<leader>gg` is for anything real.

### Debug (`<leader>d`)

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<leader>db` | Toggle breakpoint                |
| `<leader>dB` | Conditional breakpoint (prompts) |
| `<leader>dc` | Continue, or start debugging     |
| `<leader>di` | Step into                        |
| `<leader>do` | Step over                        |
| `<leader>dO` | Step out                         |
| `<leader>dr` | Toggle REPL                      |
| `<leader>du` | Toggle debug UI                  |
| `<leader>dx` | Terminate session                |

Set a breakpoint with `<leader>db`, start with `<leader>dc`, then open the panels
with `<leader>du`. Variable values appear inline next to the code as you step.

Go and Python work with no setup. JavaScript and TypeScript launch the current
file; debugging a test runner or attaching to a running process needs a new
entry under `dap.configurations` in `plugins.nix`.

### AI (`<leader>a`)

| Key               | Action                                       |
| ----------------- | -------------------------------------------- |
| `<leader>ac`      | Toggle claude-code in a float                |
| `<C-l>`           | Accept inline suggestion (insert mode)       |
| `<C-.>` / `<C-,>` | Next / previous suggestion                   |
| `<C-]>`           | Dismiss suggestion                           |
| `<C-q>`           | Close the claude-code float (from inside it) |

Copilot suggests inline as you type, as grey ghost text. It needs `:Copilot auth`
once per machine.

claude-code runs as its own CLI in a floating terminal and keeps its own login,
so no API key lives in this config. The terminal is reused, so toggling away and
back returns to the same conversation. It is disabled in commit message buffers.

### Selection (`<leader>v`)

Visual mode without reaching for `v` first — the second key is the motion `v`
would have taken.

| Key                        | Selects                                                   |
| -------------------------- | --------------------------------------------------------- |
| `<leader>vw` / `ve` / `vb` | To next word / end of word / previous word                |
| `<leader>vj` / `vk`        | Line down / up                                            |
| `<leader>vh` / `vl`        | To line start / end                                       |
| `<leader>vv`               | Entire line                                               |
| `<leader>vs`               | Current sentence                                          |
| `<leader>vW`               | Current WORD                                              |
| `<leader>vi` / `va`        | Inside / around — waits for a character, so `<leader>vi(` |
| `<leader>vf` / `vt`        | Until / till a character forward                          |
| `<leader>vF` / `vT`        | Until / till a character backward                         |

### Completion

| Key               | Action               |
| ----------------- | -------------------- |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-y>`           | Confirm              |
| `<C-Space>`       | Trigger completion   |
| `<C-d>` / `<C-f>` | Scroll docs          |

Sources in priority order: LSP, snippets, buffer, path. Copilot is deliberately
not a completion source — it already suggests inline, and having both shows
every suggestion twice.

### From mini.nvim

These come from `mini.nvim` defaults rather than `keymaps.nix`:

| Key                | Action                               |
| ------------------ | ------------------------------------ |
| `gc`               | Comment (operator), `gcc` for a line |
| `sa` / `sd` / `sr` | Surround add / delete / replace      |

Press a prefix and wait if you are unsure — the clue popup is authoritative.

## Troubleshooting

**A keymap does nothing.** Check `:map <key>` to see what is actually bound and
whether something else claimed it.

**Format on save does nothing.** The formatter binary is probably missing from
`extraPackages`. `:ConformInfo` shows what conform found.

**LSP is not attaching.** `:checkhealth lsp` and `:LspInfo`. A server needs to be
enabled under `lsp.servers` — it will not appear just because the language is
installed.

**Debugging will not start.** `:checkhealth dap`. The adapter binary comes from
`extraPackages`, same as formatters.

**Copilot is silent.** Run `:Copilot status`; if unauthenticated, `:Copilot auth`.

**A change had no effect.** The rebuild has to run and nvim has to restart:
`nix-util rebuild`, then reopen. Editing `~/.config/nvim` directly never works.
