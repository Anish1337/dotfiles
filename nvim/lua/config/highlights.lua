local function remove_italic(group)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
    name = group,
    link = false,
  })

  if not ok or not hl or vim.tbl_isempty(hl) then
    return
  end

  hl.italic = false
  vim.api.nvim_set_hl(0, group, hl)
end

local function fix_highlights()
  local groups = {
    "Comment",
    "SpecialComment",
    "Keyword",
    "StorageClass",
    "Statement",
    "Conditional",
    "Repeat",
    "Type",
    "Typedef",

    "@comment",
    "@comment.documentation",
    "@keyword",
    "@keyword.function",
    "@keyword.return",
    "@keyword.conditional",
    "@keyword.repeat",
    "@type",
    "@type.builtin",
    "@type.definition",
    "@type.qualifier",
  }

  for _, group in ipairs(groups) do
    remove_italic(group)
  end

  -- Dracula Pro C++ type override
  vim.api.nvim_set_hl(0, "@type.cpp", { link = "DraculaCyan" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = fix_highlights,
})

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  callback = fix_highlights,
})

fix_highlights()
