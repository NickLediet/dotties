require "nvchad.options"

local custom = {
  opt = {
    tabstop = 4,
    expandtab = true,
    relativenumber = true,
    --termguicolors = true
  }
}

for i, opts in pairs(custom) do
  for k,v in pairs(opts) do
    vim[i][k] = v
  end
end
