-- Python tooling.

-- Resolve project directory.
local function find_root()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    return vim.fs.dirname(name)
  end
  return vim.fn.getcwd()
end

-- Find virtualenv.
local function uv_python(root)
  root = root or find_root()
  local venv = vim.fs.find(".venv", {
    path = root,
    upward = true,
    type = "directory",
  })[1]
  if venv then
    local py = venv .. "/bin/python"
    if vim.fn.executable(py) == 1 then
      return py, venv
    end
  end
  return nil, nil
end

return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = { border = "rounded" },
        documentation = { window = { border = "rounded" } },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          before_init = function(_, config)
            local py, venv = uv_python(config.root_dir or find_root())
            if py and venv then
              config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
                python = {
                  pythonPath = py,
                  analysis = {
                    extraPaths = {
                      venv .. "/lib/python*/site-packages",
                      (config.root_dir or find_root()) .. "/src",
                      config.root_dir or find_root(),
                    },
                  },
                },
              })
              config.cmd_env = vim.tbl_extend("force", config.cmd_env or {}, {
                VIRTUAL_ENV = venv,
                PATH = venv .. "/bin:" .. vim.env.PATH,
              })
            end
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
      },
    },
  },

  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local py = uv_python(find_root()) or "python"
      require("dap-python").setup(py)
    end,
  },
}
