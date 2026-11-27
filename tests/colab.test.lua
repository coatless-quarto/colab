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
  t.eq(nb[3].source:match("^[^\n]*"), "%%R", "the R cell's first line")
  t.eq(nb[4].source, "%%bash\necho hi", "the bash cell")
end)

t.test("a knitr cell split by its outputs is one code cell, with every output after it", function()
  local nb = cells(t.render("basic.qmd", "ipynb").text)
  t.eq(#nb, 4, "number of cells (badge, R setup, R, bash)")
  t.eq(nb[3].type, "code", "the R cell's type")
  t.eq(nb[3].source, "%%R\nx <- 1\nx\ny <- 2\ny", "the R cell's source")
  t.eq(nb[3].outputs, 2, "the R cell's outputs")
end)

-- Regression: the setup cells were never added, because languages were only
-- looked for at the top level and Quarto wraps every cell in a div.
t.test("setup cells: R gets the rpy2 setup cell, after the badge and before the code", function()
  local nb = cells(t.render("basic.qmd", "ipynb").text)
  t.eq(nb[2].type, "code", "the setup cell's type")
  t.eq(nb[2].source, "# Install and configure R integration\n!pip install rpy2\n%load_ext rpy2.ipython",
    "the setup cell's source")
end)

-- Regression: a custom magic-commands entry crashed the render, and custom
-- setup-cells entries were ignored.
t.test("magic-commands and setup-cells: custom entries are used", function()
  local r = t.render("custom.qmd", "ipynb")
  r:succeeded()
  local sources = {}
  for _, cell in ipairs(cells(r.text)) do sources[#sources + 1] = cell.source end
  local all = table.concat(sources, "\n----\n")
  t.contains(all, "%%Rcustom\n1 + 1")
  t.contains(all, "# Install the shell tools\n!apt-get install -y jq")
  t.contains(all, "!pip install rpy2")
end)

-- Regression: leaving out gh-branch crashed the render.
t.test("gh-branch is optional and defaults to main", function()
  local r = t.render("nobranch.qmd", "ipynb")
  r:succeeded()
  t.contains(cells(r.text)[1].source,
    "(https://colab.research.google.com/github/octocat/notebooks/blob/main/nobranch.ipynb)")
end)

-- Regression: the magic lines and setup cells also went into HTML output.
t.test("html: cells show the code as written, with no magic lines or setup cells", function()
  local r = t.render("basic.qmd", "html")
  r:succeeded()
  t.count(r.text, '<div class="sourceCode cell-code"', 2)
  t.not_contains(r.text, "%%R")
  t.not_contains(r.text, "%%bash")
  t.not_contains(r.text, "rpy2")
end)
