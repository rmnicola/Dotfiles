local luasnip = require("luasnip")
local s = luasnip.snippet
local t = luasnip.text_node
luasnip.add_snippets("markdown", {
  s("ptpause", { t("<!-- pause -->"), }),
  s("ptcenter", { t("<!-- jump_to_middle -->"), }),
  s("ptfontsize", { t("<!-- font_size: 2 -->"), }),
  s("ptinclist", { t("<!-- incremental_lists: true -->"), }),
  s("ptimg", { t("![image:width:90%](../assets/)"), }),
  s("ptitemlines", { t("<!-- list_item_newlines: 1 -->"), }),
  s("ptnewlines", { t("<!-- new_lines: 1 -->"), }),
  s("ptskip", { t("<!-- skip_line -->"), }),
})
