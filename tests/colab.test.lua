-- colab tests. Run from the repo root: quarto pandoc lua path/to/qtest.lua
-- The fixtures run R and bash through knitr, so they need R with rmarkdown.
local t = require("qtest")

--- The notebook's cells, each with its type, its source as one string and
--- its number of outputs.
---@param ipynb string
---@return {type: string, source: string, outputs: integer}[]
local function cells(ipynb)
  local nb = pandoc.json.decode(ipynb, false)
  local out = {}
  for _, cell in ipairs(nb.cells) do
    local source = type(cell.source) == "table" and table.concat(cell.source) or cell.source
    out[#out + 1] = { type = cell.cell_type, source = source, outputs = cell.outputs and #cell.outputs or 0 }
  end
  return out
end

t.test("ipynb: the first cell is an Open in Colab badge that links to the notebook on the branch", function()
  local r = t.render("basic.qmd", "ipynb")
  r:succeeded()
  local first = cells(r.text)[1]
  t.eq(first.type, "markdown", "the first cell's type")
  t.in_order(first.source, {
    "(https://colab.research.google.com/assets/colab-badge.svg)",
    "(https://colab.research.google.com/github/octocat/notebooks/blob/dev/basic.ipynb)",
  })
end)

t.test("scroll-to: the link opens the notebook at that cell", function()
  local r = t.render("scroll.qmd", "ipynb")
  r:succeeded()
  t.contains(cells(r.text)[1].source,
    "(https://colab.research.google.com/github/octocat/notebooks/blob/main/scroll.ipynb#scrollTo=sGO-VJ_Bb0tU)")
end)

t.test("project: settings in _quarto.yml apply, and the link uses the notebook's path in the project", function()
  local r = t.render("project", "ipynb", { output = "project/notebooks/intro.ipynb" })
  r:succeeded()
  t.contains(cells(r.text)[1].source,
    "(https://colab.research.google.com/github/octocat/course/blob/main/notebooks/intro.ipynb)")
end)

t.test("R and bash cells start with their Jupyter magic, so they run in Colab's Python kernel", function()
  local nb = cells(t.render("basic.qmd", "ipynb").text)
  t.eq(nb[2].source:match("^[^\n]*"), "%%R", "the R cell's first line")
  t.eq(nb[3].source, "%%bash\necho hi", "the bash cell")
end)

t.test("a knitr cell split by its outputs is one code cell, with every output after it", function()
  local nb = cells(t.render("basic.qmd", "ipynb").text)
  t.eq(#nb, 3, "number of cells (badge, R, bash)")
  t.eq(nb[2].type, "code", "the R cell's type")
  t.eq(nb[2].source, "%%R\nx <- 1\nx\ny <- 2\ny", "the R cell's source")
  t.eq(nb[2].outputs, 2, "the R cell's outputs")
end)
