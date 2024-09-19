# quarto-colab: A Quarto Extension for Google Colaboratory

> [!IMPORTANT]
>
> This is a WIP extension. Please check back later for more information.


The `{quarto-colab}`  extension allows you to incorporate Google Colaboratory badges and links into your Quarto documents.

This extension is based on the [Using Google Colab with GitHub](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb#scrollTo=8QAWNjizy_3O) notebook.

> [!NOTE]
> This Quarto extension is open source software and is **not affiliated with** Google. The extension is at best a community effort to simplify the integration of Google's Colaboratory runtime inside of Quarto documents.

## Installation

To install the `colab` extension, follow these steps:

1. Open your terminal.

2. Execute the following command:

```bash
quarto add coatless-quarto/colab
```

This command will download and install the extension under the `_extensions` subdirectory of your Quarto project. If you are using version control, ensure that you include this directory in your repository.

## Using

*TODO*: Describe how to use your format.

### Configuration

Specify the `colab` extension in the `_quarto.yml` project file to enable the extension. The `colab` extension supports the following configuration options:

```yaml
colab:
  gh-user: coatless-quarto
  gh-repo: colab
  gh-branch: main

filter: 
  - colab
```

## Example

Here is the source code for a minimal sample document: [template.qmd](template.qmd).
