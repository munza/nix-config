# Neovim keymaps
#
# Grouped by what they act on. Leader is <space>; the <leader>v family is a
# small language of its own, documented at the bottom.
_:

let
  # `vi(`, `vf,` and friends need a character before they can run, so each of
  # these prompts for one and replays the motion. Wrapping them keeps the
  # prompt-then-replay logic in one place instead of six near-identical blobs.
  selectPrompting = key: motion: desc: {
    mode = "n";
    inherit key;
    action.__raw = "function() local c=vim.fn.getcharstr(); if c~='' then vim.cmd('normal! ${motion}'..c) end end";
    options.desc = desc;
  };

  # Named for the mode it binds in, and so it does not shadow builtins.map.
  nmap = key: action: desc: {
    mode = "n";
    inherit key action;
    options.desc = desc;
  };
in
{
  programs.nixvim.keymaps = [
    # ── Files and pickers ───────────────────────────────────────────────
    (nmap "<leader>e" "<cmd>lua MiniFiles.open()<CR>" "Toggle file explorer")
    (nmap "<leader>ff" "<cmd>lua MiniPick.builtin.files()<CR>" "Find files")
    (nmap "<leader>fg" "<cmd>lua MiniPick.builtin.grep_live()<CR>" "Live grep")
    (nmap "<leader>fb" "<cmd>lua MiniPick.builtin.buffers()<CR>" "Find buffers")
    (nmap "<leader>fh" "<cmd>lua MiniPick.builtin.help()<CR>" "Help tags")
    (nmap "<leader>fr" "<cmd>lua MiniExtra.pickers.oldfiles()<CR>" "Recent files")
    (nmap "<leader>fd" "<cmd>lua MiniExtra.pickers.diagnostic()<CR>" "Diagnostics")

    # ── LSP ─────────────────────────────────────────────────────────────
    (nmap "gd" "<cmd>lua vim.lsp.buf.definition()<CR>" "Go to definition")
    (nmap "gr" "<cmd>lua MiniExtra.pickers.lsp({ scope = 'references' })<CR>" "References")
    (nmap "K" "<cmd>lua vim.lsp.buf.hover()<CR>" "Hover docs")
    (nmap "<leader>ca" "<cmd>lua vim.lsp.buf.code_action()<CR>" "Code action")
    (nmap "<leader>rn" "<cmd>lua vim.lsp.buf.rename()<CR>" "Rename")

    # ── Diagnostics ─────────────────────────────────────────────────────
    (nmap "<leader>cd" "<cmd>lua vim.diagnostic.open_float()<CR>" "Line diagnostics")
    (nmap "[d" "<cmd>lua vim.diagnostic.goto_prev()<CR>" "Prev diagnostic")
    (nmap "]d" "<cmd>lua vim.diagnostic.goto_next()<CR>" "Next diagnostic")

    # ── Formatting and git ──────────────────────────────────────────────
    (nmap "<leader>cf" "<cmd>lua require('conform').format()<CR>" "Format file")
    (nmap "<leader>gg" "<cmd>LazyGit<CR>" "LazyGit")

    # ── Buffers and windows ─────────────────────────────────────────────
    (nmap "<S-h>" "<cmd>bprev<CR>" "Prev buffer")
    (nmap "<S-l>" "<cmd>bnext<CR>" "Next buffer")
    (nmap "<leader>bd" "<cmd>bd<CR>" "Delete buffer")
    (nmap "<C-h>" "<C-w>h" "Move to left window")
    (nmap "<C-j>" "<C-w>j" "Move to bottom window")
    (nmap "<C-k>" "<C-w>k" "Move to top window")
    (nmap "<C-l>" "<C-w>l" "Move to right window")

    # ── Debug (<leader>d) ───────────────────────────────────────────────
    # <leader>d was line diagnostics; that moved to <leader>cd so this prefix
    # can follow the usual dap convention.
    (nmap "<leader>db" "<cmd>lua require('dap').toggle_breakpoint()<CR>" "Toggle breakpoint")
    (nmap "<leader>dB" "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Condition: '))<CR>"
      "Conditional breakpoint"
    )
    (nmap "<leader>dc" "<cmd>lua require('dap').continue()<CR>" "Continue / start")
    (nmap "<leader>di" "<cmd>lua require('dap').step_into()<CR>" "Step into")
    (nmap "<leader>do" "<cmd>lua require('dap').step_over()<CR>" "Step over")
    (nmap "<leader>dO" "<cmd>lua require('dap').step_out()<CR>" "Step out")
    (nmap "<leader>dr" "<cmd>lua require('dap').repl.toggle()<CR>" "Toggle REPL")
    (nmap "<leader>du" "<cmd>lua require('dapui').toggle()<CR>" "Toggle debug UI")
    (nmap "<leader>dx" "<cmd>lua require('dap').terminate()<CR>" "Terminate session")

    # ── AI (<leader>a) ──────────────────────────────────────────────────
    # claude-code in a float; it keeps its own login, so nvim holds no key.
    (nmap "<leader>ac" "<cmd>lua _CLAUDE_CODE:toggle()<CR>" "Toggle claude-code")

    # ── Search ──────────────────────────────────────────────────────────
    (nmap "<Esc>" "<cmd>nohlsearch<CR>" "Clear search highlights")

    # ── Selection (<leader>v) ───────────────────────────────────────────
    # Visual mode without reaching for v first: the second key is the motion
    # it would have taken, so <leader>vw is `vw`, <leader>vl is `v$`.
    (nmap "<leader>vw" "vw" "Select to next word")
    (nmap "<leader>ve" "ve" "Select to end of word")
    (nmap "<leader>vb" "vb" "Select to prev word")
    (nmap "<leader>vj" "vj" "Select line down")
    (nmap "<leader>vk" "vk" "Select line up")
    (nmap "<leader>vl" "v$" "Select to line end")
    (nmap "<leader>vh" "v0" "Select to line start")
    (nmap "<leader>vv" "V" "Select entire line")
    (nmap "<leader>vs" "vis" "Select current sentence")
    (nmap "<leader>vW" "viW" "Select current WORD")

    # These wait for a character: <leader>vi( selects inside the parens.
    (selectPrompting "<leader>vi" "vi" "Select inside…")
    (selectPrompting "<leader>va" "va" "Select around…")
    (selectPrompting "<leader>vf" "vf" "Select until char (inclusive)")
    (selectPrompting "<leader>vt" "vt" "Select till char (exclusive)")
    (selectPrompting "<leader>vF" "vF" "Select until char backward (inclusive)")
    (selectPrompting "<leader>vT" "vT" "Select till char backward (exclusive)")
  ];
}
