# quarto-colab: A Quarto Extension for Google Colaboratory <img src="https://github.com/user-attachments/assets/4e9340ce-fa33-467e-a77e-4662b3683c27" align="right" alt="Logo: A notebook going into an abstract cloud" width="150"/>

The `{quarto-colab}` extension enables Google Colab integration for your Quarto documents rendered to Juypter Notebook. It adds "Open in Colab" badges and handles the configuration of Jupyter magic commands for languages like R, SQL, and Octave, letting anyone run your notebooks in Colab with a single click.

> [!NOTE]
>
> This Quarto extension is open source software and is **not affiliated with** Google. The extension is at best a community effort to simplify the integration of Google's Colaboratory runtime inside of Quarto documents.

## Installation

Add the extension to your Quarto project by running the following command in Terminal within your Quarto project directory:

```bash
quarto add coatless-quarto/colab
```

This command will download and install the extension under the `_extensions` subdirectory of your Quarto project. If you're using version control, make sure to include this directory in your repository.

### Requirements

- Quarto >= 1.4.0
- `R` and `knitr` (for polyglot document evaluation)
- GitHub public repository (for Colab to access your notebooks)
- Google Colab account (for Colab features)

## Usage

We recommend using this extension as part of a multi-format output using
`jupyter` and `html` formats.

### Basic Setup

Add the following to your document's header or `_quarto.yml`:

```yaml
---
title: "My Document"
format:
  jupyter: default
  html: default
colab:
  gh-user: "username"    # Your GitHub username
  gh-repo: "reponame"    # Your repository name
  gh-branch: "main"      # Optional, defaults to "main"
filters:
  - colab
---
```

### Language Configuration

#### Magic Commands (Optional)

Define the cell magic commands for different languages to use in your document:

```yaml
magic-commands:
  r: "%%R"              # Custom R magic command
  julia: "%%julia"      # Custom Julia magic command
  newlang: "%%newlang"  # Custom magic command for a new language
```

#### Setup Cells (Optional)

Define custom environment setup for different languages:

```yaml
setup-cells:
  r:
    language: "python"    # Language assumed for the setup cell
    code: |
      # Custom R setup
      !pip install rpy2
      %load_ext rpy2.ipython
```

### HTML Support (Work in Progress)

While automatic HTML integration is under development, you can manually add Colab links to your HTML output:

```yaml
format:
  html:
    code-links:
      - text: "Open in Colab"
        href: "https://colab.research.google.com/github/USERNAME/REPO/blob/BRANCH/PATH_TO_NOTEBOOK.ipynb"
        icon: "laptop"
```

Replace `USERNAME`, `REPO`, `BRANCH`, and `PATH_TO_NOTEBOOK.ipynb` with your specific values.

> [!NOTE]
> 
> We know this is a bit cumbersome and are working on a better solution.

## Supported Languages

The extension includes pre-configured setup for:

- R (using [`{rpy2}`][rpy2magic])
- Julia (using [`{juliacall}`][juliacallmagic])
- Octave (using [`{oct2py}`][oct2pymagic])
- SQL (using [`{jupysql}`][jupysqlmagic])
- SAS (using [`{saspy}`][saspymagic] + licensed copy and a way to access it)

Additional languages are supported via magic commands without requiring specific setup cells.

## Acknowledgements

This extension is based on the [Using Google Colab with GitHub](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb#scrollTo=8QAWNjizy_3O) notebook.

### Notes

This extension formed the basis of my [**second** ever issue ticket](https://github.com/quarto-dev/quarto-cli/issues?q=is%3Aissue%20author%3Acoatless%20sort%3Acreated-asc) on the Quarto project's GitHub issue tracker [quarto-dev/quarto-cli#1224](https://github.com/quarto-dev/quarto-cli/issues/1224). The issue ticket was opened on **October 1, 2022**. Wowie, how time flies when you're having fun!

[rpy2magic]: https://rpy2.github.io/doc/v3.5.x/html/interactive.html#module-rpy2.ipython.rmagic
[juliacallmagic]: https://juliapy.github.io/PythonCall.jl/stable/compat/#IPython 
[oct2pymagic]: https://nbviewer.org/github/blink1073/oct2py/blob/main/example/octavemagic_extension.ipynb?create=1
[jupysqlmagic]: https://jupysql.ploomber.io/en/latest/api/magic-sql.html
[saspymagic]: https://sassoftware.github.io/saspy/advanced-topics.html#jupyter-magics
