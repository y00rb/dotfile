-- Clear startup buffer.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("wipe_empty_noname", { clear = true }),
  callback = function()
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_valid(buf)
          and vim.bo[buf].buflisted
          and vim.api.nvim_buf_get_name(buf) == ""
          and not vim.bo[buf].modified
          and vim.bo[buf].filetype == ""
          and vim.api.nvim_buf_line_count(buf) <= 1
          and (vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "") == ""
        then
          pcall(vim.api.nvim_buf_delete, buf, {})
        end
      end
    end)
  end,
})
