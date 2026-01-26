local luasnip = require("luasnip")
local s = luasnip.snippet
local t = luasnip.text_node
luasnip.add_snippets("markdown", {
  s("ptpause", { t("<!-- pause -->"), }),
  s("ptcenter", { t("<!-- jump_to_middle -->"), }),
  s("ptnewlines", { t("<!-- new_lines: 1 -->"), }),
  s("ptinclist", { t("<!-- incremental_lists: true -->"), }),
  s("ptitemlines", { t("<!-- list_item_newlines: 1 -->"), }),
  s("ptskip", { t("<!-- skip_line -->"), }),
})
