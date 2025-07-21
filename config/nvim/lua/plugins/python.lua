return {
  -- add config of lsp for python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          -- Dynamic configuration function
          on_new_config = function(new_config, new_root_dir)
            -- Detect uv project
            local function find_uv_venv(path)
              -- Find .venv directory
              local venv_path = vim.fs.find(".venv", {
                path = path,
                upward = true,
                type = "directory",
              })[1]

              if venv_path then
                local python_path = venv_path .. "/bin/python"
                -- Check if Python exists
                if vim.fn.executable(python_path) == 1 then
                  return python_path, venv_path
                end
              end
              return nil, nil
            end

            -- Check if project root has pyproject.toml and uv.lock
            local function is_uv_project(path)
              local pyproject = vim.fs.find("pyproject.toml", { path = path, upward = true })[1]
              local uvlock = vim.fs.find("uv.lock", { path = path, upward = true })[1]
              return pyproject and uvlock
            end

            -- If it's a uv project, configure Python path
            if is_uv_project(new_root_dir) then
              local python_path, venv_path = find_uv_venv(new_root_dir)

              if python_path and venv_path then
                print("🐍 Detected uv project, using virtual environment: " .. venv_path)

                -- Set Python interpreter path
                new_config.settings = vim.tbl_deep_extend("force", new_config.settings or {}, {
                  python = {
                    pythonPath = python_path,
                    analysis = {
                      extraPaths = {
                        venv_path .. "/lib/python*/site-packages",
                        new_root_dir .. "/src", -- if using src directory
                        new_root_dir, -- project root directory
                      },
                      autoSearchPaths = true,
                      useLibraryCodeForTypes = true,
                      autoImportCompletions = true,
                      typeCheckingMode = "basic",
                    },
                  },
                })

                -- Set environment variables
                new_config.cmd_env = {
                  VIRTUAL_ENV = venv_path,
                  PATH = venv_path .. "/bin:" .. vim.env.PATH,
                }
              else
                print("⚠️  uv project detected but .venv directory not found, please run 'uv sync'")
              end
            end
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic", -- 类型检查模式
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,
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
      require("dap-python").setup("python")
    end,
  },
  -- nvim-cmp: codes completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP 补全源
      "hrsh7th/cmp-buffer", -- 缓冲区补全源
      "hrsh7th/cmp-path", -- 路径补全源
      "hrsh7th/cmp-cmdline", -- 命令行补全源
      "L3MON4D3/LuaSnip", -- 代码片段引擎
      "saadparwaiz1/cmp_luasnip", -- LuaSnip 补全源
    },
    opts = function(_, opts)
      local cmp = require("cmp")

      -- 补全菜单设置
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }

      -- 补全源设置
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 }, -- LSP 补全（最高优先级）
        { name = "luasnip", priority = 750 }, -- 代码片段
        { name = "buffer", priority = 500 }, -- 当前缓冲区
        { name = "path", priority = 250 }, -- 文件路径
      })

      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          -- on_attach: LSP 连接到文件时执行的函数
          on_attach = function(client, bufnr)
            -- 定义快捷键（只在有 LSP 的缓冲区中生效）
            local function map(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            -- 常用的 LSP 快捷键
            map("n", "gd", vim.lsp.buf.definition, "跳转到定义")
            map("n", "gr", vim.lsp.buf.references, "查找引用")
            map("n", "K", vim.lsp.buf.hover, "悬停文档")
            map("n", "<leader>ca", vim.lsp.buf.code_action, "代码操作")
            map("n", "<leader>rn", vim.lsp.buf.rename, "重命名")
            map("n", "<leader>f", vim.lsp.buf.format, "格式化代码")
          end,

          -- capabilities: 告诉 LSP 客户端支持的功能
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- 添加代码补全支持
            capabilities.textDocument.completion.completionItem = {
              documentationFormat = { "markdown", "plaintext" },
              snippetSupport = true,
              preselectSupport = true,
              insertReplaceSupport = true,
              labelDetailsSupport = true,
              deprecatedSupport = true,
              commitCharactersSupport = true,
              tagSupport = { valueSet = { 1 } },
              resolveSupport = {
                properties = {
                  "documentation",
                  "detail",
                  "additionalTextEdits",
                },
              },
            }

            return capabilities
          end)(),

          -- Pyright 特定设置
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic", -- 基础类型检查
                autoSearchPaths = true, -- 自动搜索 Python 路径
                useLibraryCodeForTypes = true, -- 使用库代码进行类型推断
                autoImportCompletions = true, -- 自动导入补全
                diagnosticMode = "workspace", -- 诊断模式：整个工作区
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
      -- Find Python in uv virtual environment
      local function find_uv_python()
        local venv_path = vim.fs.find(".venv", {
          path = vim.fn.getcwd(),
          upward = true,
          type = "directory",
        })[1]

        if venv_path then
          local python_path = venv_path .. "/bin/python"
          if vim.fn.executable(python_path) == 1 then
            return python_path
          end
        end

        return "python" -- fallback to system Python
      end

      -- Setup Python debugger
      require("dap-python").setup(find_uv_python())

      -- Debug keymaps
      local dap = require("dap")
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue execution" })
      vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "Step over" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
    end,
  },
}
