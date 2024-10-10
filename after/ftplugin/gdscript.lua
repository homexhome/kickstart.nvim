local port = os.getenv 'GDScript_Port' or '6005'
local cmd = { 'ncat', '127.0.0.1', port }
local pipe = [[127.0.0.1:55432]]

vim.lsp.start {
  name = 'Godot',
  cmd = cmd,
  root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
  on_attach = function(client, bufnr)
    if vim.lsp.get_clients { name = 'Godot' } == 0 then
      vim.api.nvim_command([[echo serverstart(']] .. pipe .. [[')]])
    end
  end,
}
