_:

{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>lua MiniFiles.open()<CR>";
      options.desc = "Toggle file explorer";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>lua MiniPick.builtin.files()<CR>";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>lua MiniPick.builtin.grep_live()<CR>";
      options.desc = "Live grep";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>lua MiniPick.builtin.buffers()<CR>";
      options.desc = "Find buffers";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>lua MiniPick.builtin.help()<CR>";
      options.desc = "Help tags";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>lua MiniExtra.pickers.oldfiles()<CR>";
      options.desc = "Recent files";
    }
    {
      mode = "n";
      key = "<leader>fd";
      action = "<cmd>lua MiniExtra.pickers.diagnostic()<CR>";
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options.desc = "Go to definition";
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>lua MiniExtra.pickers.lsp({ scope = 'references' })<CR>";
      options.desc = "References";
    }
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      options.desc = "Hover docs";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options.desc = "Code action";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options.desc = "Rename";
    }
    {
      mode = "n";
      key = "<leader>d";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options.desc = "Line diagnostics";
    }
    {
      mode = "n";
      key = "[d";
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      options.desc = "Prev diagnostic";
    }
    {
      mode = "n";
      key = "]d";
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      options.desc = "Next diagnostic";
    }
    {
      mode = "n";
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format()<CR>";
      options.desc = "Format file";
    }
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options.desc = "LazyGit";
    }
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprev<CR>";
      options.desc = "Prev buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<CR>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>bd<CR>";
      options.desc = "Delete buffer";
    }
    {
      mode = "n";
      key = "<leader>vw";
      action = "vw";
      options.desc = "Select to next word";
    }
    {
      mode = "n";
      key = "<leader>ve";
      action = "ve";
      options.desc = "Select to end of word";
    }
    {
      mode = "n";
      key = "<leader>vb";
      action = "vb";
      options.desc = "Select to prev word";
    }
    {
      mode = "n";
      key = "<leader>vj";
      action = "vj";
      options.desc = "Select line down";
    }
    {
      mode = "n";
      key = "<leader>vk";
      action = "vk";
      options.desc = "Select line up";
    }
    {
      mode = "n";
      key = "<leader>vl";
      action = "v$";
      options.desc = "Select to line end";
    }
    {
      mode = "n";
      key = "<leader>vh";
      action = "v0";
      options.desc = "Select to line start";
    }
    {
      mode = "n";
      key = "<leader>vv";
      action = "V";
      options.desc = "Select entire line";
    }
    {
      mode = "n";
      key = "<leader>vi";
      action.__raw = "function() local c=vim.fn.getcharstr(); if c~='' then vim.cmd('normal! vi'..c) end end";
      options.desc = "Select inside…";
    }
    {
      mode = "n";
      key = "<leader>va";
      action.__raw = "function() local c=vim.fn.getcharstr(); if c~='' then vim.cmd('normal! va'..c) end end";
      options.desc = "Select around…";
    }
    {
      mode = "n";
      key = "<leader>vf";
      action.__raw = "function() local c=vim.fn.getcharstr(); if c~='' then vim.cmd('normal! vf'..c) end end";
      options.desc = "Select until char (inclusive)";
    }
    {
      mode = "n";
      key = "<leader>vt";
      action.__raw = "function() local c=vim.fn.getcharstr(); if c~='' then vim.cmd('normal! vt'..c) end end";
      options.desc = "Select till char (exclusive)";
    }
    {
      mode = "n";
      key = "<leader>vF";
      action.__raw = "function() local c=vim.fn.getcharstr(); if c~='' then vim.cmd('normal! vF'..c) end end";
      options.desc = "Select until char backward (inclusive)";
    }
    {
      mode = "n";
      key = "<leader>vT";
      action.__raw = "function() local c=vim.fn.getcharstr(); if c~='' then vim.cmd('normal! vT'..c) end end";
      options.desc = "Select till char backward (exclusive)";
    }
    {
      mode = "n";
      key = "<leader>vs";
      action = "vis";
      options.desc = "Select current sentence";
    }
    {
      mode = "n";
      key = "<leader>vW";
      action = "viW";
      options.desc = "Select current WORD";
    }
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Clear search highlights";
    }
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Move to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Move to bottom window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Move to top window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Move to right window";
    }
  ];
}
