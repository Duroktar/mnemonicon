# mnemonicon

## Simple TUI Alias Manager for Linux

![Built with Bash](https://img.shields.io/badge/Built%20with-Bash-1f425f.svg)

**Mnemonicon** is a simple yet powerful TUI (Text User Interface) alias manager for Linux. Built with `whiptail`, it provides an interactive way to view, add, edit, and delete your shell aliases, streamlining your command-line workflow.

---

## Features

* **View Aliases:** See all your currently defined aliases in a clear, scrollable format.
* **Add Aliases:** Easily create new aliases by providing a name and the command it represents.
* **Edit Aliases:** Modify the command associated with an existing alias.
* **Delete Aliases:** Remove unwanted aliases with a confirmation prompt.
* **Persistent Storage:** All changes are saved to your `~/.bash_aliases` file (or a configurable path).

---

## Prerequisites

Before using `mnemonicon`, ensure you have the following tools installed on your Linux system:

* **`whiptail`**: A dialog box utility for shell scripts. (Usually pre-installed or available via your package manager, e.g., `sudo apt install whiptail` on Debian/Ubuntu).
* **`bash`**: The Bourne Again SHell.
* **`grep`**: For searching text.
* **`sed`**: Stream editor for filtering and transforming text.
* **`awk`**: Pattern scanning and processing language.

---

## Installation

To install `mnemonicon`, follow these steps:

1.  **Clone the Repository (or download the files):**
    ```bash
    git clone [https://github.com/your-username/mnemonicon.git](https://github.com/your-username/mnemonicon.git)
    cd mnemonicon
    ```
    *(Replace `your-username` with your actual GitHub username and adjust the repository name if different.)*

2.  **Run the Installer Script:**
    The `install_mnemonicon.sh` script will make `alias-manager.sh` executable and create a symbolic link named `mnemonicon` in `~/.local/bin`, making it accessible from anywhere in your terminal.
    ```bash
    ./install_mnemonicon.sh
    ```

    The installer will guide you and inform you if `~/.local/bin` needs to be added to your system's `PATH` environment variable. If it does, you'll typically add the following line to your `~/.bashrc` (or `~/.zshrc`):
    ```bash
    export PATH="$HOME/.local/bin:$PATH"
    ```
    After modifying your shell configuration, remember to `source` it or restart your terminal:
    ```bash
    source ~/.bashrc # Or ~/.zshrc
    ```

---

## Usage

Once installed, simply run `mnemonicon` from your terminal:

```bash
mnemonicon
```

This will launch the `whiptail` TUI, presenting you with a menu to manage your aliases.

---

## Alias File Location

By default, `mnemonicon` manages aliases stored in `$HOME/.bash_aliases`. This file is commonly sourced by your `~/.bashrc` to load aliases automatically when your shell starts.

If you wish to use a different file, you can modify the `ALIAS_FILE` variable at the top of the `alias-manager.sh` script:

```bash
ALIAS_FILE="$HOME/.my_custom_aliases_file"
```

---

## Applying Changes

After adding, editing, or deleting aliases using `mnemonicon`, the changes are written to the alias file. For these changes to take effect in your *current* terminal session, you must reload your shell's configuration. The script will remind you to do this.

The most common way is to `source` your shell's configuration file:

```bash
source ~/.bashrc # Or source ~/.zshrc, depending on your shell
```

Alternatively, simply open a new terminal window.

---

## Contributing

Contributions are welcome! If you have suggestions for improvements, bug reports, or new features, please open an issue or submit a pull request on the GitHub repository.

---

## License

This project is open-source and available under the [MIT License](LICENSE).

*(Note: You'll need to create a `LICENSE` file in your repository with the full MIT License text.)*