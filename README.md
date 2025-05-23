# zsh-git-venv-prompt

![Screenshot](screenshot.png)

`zsh-git-venv-prompt` is a Zsh plugin that enhances your Zsh prompt with information about the current Python virtual environment and the Git status (asynchronously). It uses `zsh-async` to provide async updates for Git status and displays the virtual environment in the second line of the prompt.

## Features

- Displays the name of the active Python virtual environment (if any).
- Shows the current Git branch and changes (staged, unstaged, clean) asynchronously.
- Supports a two-line prompt:
  - First line: Username, hostname, and current directory.
  - Second line: Python virtual environment (if active), followed by Git status.

## Requirements

- [zsh-async](https://github.com/mafredri/zsh-async): This plugin requires `zsh-async` for asynchronous Git status updates.
- [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) (optional): For vi-mode integration and mode indicators.

You can install the dependencies using a plugin manager like `znap`:

```sh
znap source mafredri/zsh-async
znap source jeffreytse/zsh-vi-mode  # Optional for vi-mode support
```

## Installation

### Using znap (Recommended)

To install this plugin using znap, add the following line to your .zshrc:

```sh
znap source walkingshamrock/zsh-git-venv-prompt/zsh-git-venv-prompt.plugin.zsh
```

### Manual Installation

1. Clone the repository to your ~/.zsh/plugins/ directory:

```sh
git clone https://github.com/walkingshamrock/zsh-git-venv-prompt.git ~/.zsh/plugins/zsh-git-venv-prompt
```

1. Add the following line to your .zshrc:

```sh
source ~/.zsh/plugins/zsh-git-venv-prompt/zsh-git-venv-prompt.plugin.zsh
```

1. Reload your .zshrc:

```sh
source ~/.zshrc
```

## Configuration

The plugin automatically configures a two-line prompt:

1. First line: Displays your username, hostname, and current directory.
1. Second line: Displays the Python virtual environment (if active), followed by Git branch and status.

You can modify the prompt by changing the PROMPT variable in the zsh-git-venv-prompt.plugin.zsh file.

## Usage

Once installed, the plugin will automatically display:

- The name of the currently active Python virtual environment (if any).
- The current Git branch and status asynchronously:
  - `+` for staged changes
  - `*` for unstaged changes
  - `✔` for clean status (when no changes)

For example, your prompt will look like this:

```
user@hostname /path/to/dir (main) + *
(venv) > 
```

## Contributing

Contributions are welcome! If you find a bug or have an improvement, please open an issue or submit a pull request.

## Acknowledgements

Special thanks to [pure](https://github.com/sindresorhus/pure) for their inspiration and influence in designing the shell prompts.

## License

This plugin is licensed under the MIT License. See the LICENSE file for details.
