# vim-jupycent

Plugin for editing [Jupyter notebook][1] (ipynb) files via the [jupytext][2]
percent format.

[jupytext.vim][3] is an excellent plugin, but it loads the result of the
jupytext conversion into the ipynb buffer, which causes issues with other
plugins for version control (e.g., gitgutter) and linting (e.g., coc.nvim).
[jupytext.vim][3] is also a more flexible wrapper of jupytext, whereas
vim-jupycent only converts to the python percent format, and adds some
highlighting and folding based on this format.

## Installation

1. Make sure that you have the `jupytext` CLI program installed (`pip install jupytext`).
2. Install this plugin with your favourite method, like vim-plug (`Plug 'gabenespoli/vim-jupycent'`).

## Usage

When you open a Jupyter Notebook (`*.ipynb`) file, it is automatically
converted from json to markdown or python through the [`jupytext` utility][2],
and the result is loaded into the buffer. Upon saving, the `ipynb` file is
updated with any modifications.

In more detail, opening a file `notebook.ipynb` in vim will create a temporary
file  `notebook.py`. This file is the result of calling e.g.

    jupytext --to=py:percent --output notebook.md notebook.ipynb

The file `notebook.py` is opened, and the original `notebook.ipynb` is wiped
from vim. When saving the buffer, its contents is first written to
`notebook.py`, and then the original `notebook.ipynb` is updated with a call to

    jupytext --from=py:percent --to=ipynb --update --output notebook.ipynb notebook.py

The `--update` flag ensures the output for any cell whose corresponding input
in `notebook.py` is unchanged will be preserved.

On closing the buffer, the temporary `notebook.py` will be deleted. If
`notebook.py` already existed when opening `notebook.ipynb`, the existing file
will be used (instead of being generated by `jupytext`), and it will be
preserved when closing the buffer.

## Commands

*   `JupycentSaveIpynb`

    Saves the current python (.py) file as a Jupyter notebook (.ipynb).

## Configuration

The plugin has the following settings. If you want to override the default values shown below, you can define the corresponding variables in your `~/.vimrc`.

*   `let g:jupycent_enable = 1`

    You may disable the automatic conversion of `ipynb` files (i.e., deactivate this plugin) by setting this to 0.

*   `let g:jupycent_command = 'jupytext'`

    The CLI `jupytext` command to use. You may include the full path to point to a specific `jupytext` executable not in your default `$PATH`.

*   `let g:jupycent_to_ipynb_opts = '--to=ipynb --update'`

    Command line options for the conversion from `g:jupytext_fmt` back to the notebook format

*   `let g:jupycent_line_return = 1

    When opening a notebook as a .py, return to the last line you were editing using `g\`"zvzz`

## Acknowledgements

This plugin takes some inspiration, code, and documentation from [jupytext.vim][3]. vim-jupycent is basically a fork of [jupytext.vim][3], but is probably too different to call it a fork.

[1]: http://jupyter.org
[2]: https://github.com/mwouts/jupytext
[3]: https://github.com/goerz/jupytext.vim
