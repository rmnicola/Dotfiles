local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("markdown", {
  -- SNIPPET 1: The Image Component
  -- Usage: Type 'stimg', press Enter. Type variable name -> Tab -> Alt text -> Tab -> Caption.
  s("stimg", fmt([[
    <center>
      <Image
        src={{{}}}
        alt="{}"
        style={{{{ height: 'auto' }}}}
      />
    </center>
    <p><center>{}</center></p>
  ]], {
    i(1, "myImageVariable"),      -- This is the variable name
    i(2, "Description of image"), -- This is the alt text
    i(3, "Image Caption"),        -- This is the caption
  })),

  -- SNIPPET 2: The Import Statement
  -- Usage: Type 'stimp', press Enter. Type variable name -> Tab -> Path.
  s("stimp", fmt([[
    import {{ Image }} from 'astro:assets';
    import {} from '../../assets/{}';
  ]], {
    i(1, "myImageVariable"), -- Matches the variable used in the component
    i(2, "image.png"),       -- The file name
  })),
})
