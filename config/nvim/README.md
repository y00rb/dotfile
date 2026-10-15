# Neovim Configuration

LazyVim-based Neovim configuration.

```text
config/nvim/
├── .gitignore               Local ignore rules
├── .neoconf.json            Neoconf settings
├── init.lua                 Entry point
├── lazyvim.json             Enabled LazyVim extras
├── lazy-lock.json           Plugin lockfile
├── LICENSE                  License
├── README.md                Directory overview
├── stylua.toml              Lua formatting settings
├── lua/config/
│   ├── lazy.lua             Plugin manager bootstrap
│   ├── options.lua          Editor options
│   ├── keymaps.lua          Custom keymaps
│   └── autocmds.lua         Buffer autocommands
└── lua/plugins/
    ├── colorscheme.lua      Catppuccin theme
    ├── go.lua               Go tooling
    ├── lsp.lua              LSP preferences
    ├── python.lua           Python tooling
    └── vscode.lua           VS Code integration
```
