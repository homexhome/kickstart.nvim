-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)
return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    dap.adapters.godot = {
      type = 'server',
      host = '127.0.0.1',
      port = 6008,
    }

    dap.configurations.gdscript = {
      {
        type = 'godot',
        request = 'launch',
        name = 'Launch scene',
        project = '${workspaceFolder}',
        launch_game_instance = true,
        debugServer = 6007,
        port = 6007,
        addres = '127.0.0.1',
        launch_scene = false,
      },
    }
    dap.adapters.coreclr = {
      type = 'executable',
      command = 'C:/Users/wired/AppData/Local/nvim/lua/kickstart/plugins/netcoredbg/netcoredbg',
      args = {'--interpreter=vscode'}
    }


    local function getHighestVersionDirectory(dir)
      local command = 'dir /B ' .. dir -- For Windows, use 'dir /B ' .. dir instead
      local max_version, max_dir = -1, ''
      local p = io.popen(command)
      local lines = p:lines()
      for dirname in lines do
        local version = tonumber(dirname:match('net(%d+%.%d+)'))
        if version and version > max_version then
          max_version = version
          max_dir = dirname
        end
      end
      if p ~= nil then
        p:close()
      end
    
      return max_dir
    end

    homex_config = {
      debug_dllPath = nil
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
          local path = vim.fn.getcwd()
          local sep = path:match('[/\\]') -- Get the path separator used (either / or \)
          local last_dir = path:match('([^' .. sep .. ']+' .. sep .. '?)$')
          local project_name = last_dir:sub(1, -1) -- Remove the trailing separator if it exists
          local version_directory = path .. "\\bin\\Debug"
          local latest_version = getHighestVersionDirectory(version_directory);
          -- logger:info('Hieghest version: ' .. latest_version)
          local executable_path = version_directory .. "\\" .. latest_version .. "\\" .. project_name .. ".dll"
          -- local tokens = string.gmatch(path, "\\")
          -- local project_name = tokens[#(tokens) - 1] .. "\\"
          if (homex_config.debug_dllPath ~= nill) then
            executable_path = homex_config.debug_dllPath
          end
    
          local result = vim.fn.input('Path to dll: ', executable_path, 'file')
          homex_config.debug_dllPath = result
          -- logger:info('Result: ' .. result)
          return result
        end,
        -- env = {},
        -- cwd = ""
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<leader><F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F6>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>B', dap.clear_breakpoints, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>P', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()
  end,
}
