#!/bin/bash

# This script sets up the project selector and generator scripts by making them
# executable and creating symbolic links in ~/.local/bin for easy access.

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No COLOR

# FUNCTION to echo with color
cecho() {
  local color="$1"
  local message="$2"
  echo -e "${color}${message}${NC}"
}

cecho "${BLUE}" "Starting installation of mnemonicon alias manager script..."

# --- Ensure ~/.local/bin exists ---
BIN_DIR="$HOME/.local/bin"
if [ ! -d "$BIN_DIR" ]; then
  cecho "${YELLOW}" "Directory ${BIN_DIR} not found. Creating it..."
  mkdir -p "$BIN_DIR"
  if [ $? -ne 0 ]; then
    cecho "${RED}" "Error: Failed to create ${BIN_DIR}. Please check permissions."
    exit 1
  fi
  cecho "${GREEN}" "Created ${BIN_DIR}."
fi

# --- Check if ~/.local/bin is in PATH ---
if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
  cecho "${YELLOW}" "Warning: ${BIN_DIR} is not in your system's PATH."
  cecho "${YELLOW}" "You may need to add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your ~/.bashrc or ~/.zshrc file."
  cecho "${YELLOW}" "After adding, run 'source ~/.bashrc' (or your shell config) or restart your terminal."
fi

# --- Install Scripts ---

# Helper function to install a single script
install_script() {
  local script_file="$1"
  local target_name="$2" # Can be different from script_file if needed

  cecho "${RED}" "Processing ${script_file}..."

  if [ ! -f "./${script_file}" ]; then
    cecho "${RED}" "Error: Source script './${script_file}' not found. Skipping."
    return 1
  fi

  # Make the script executable
  cecho "${BLUE}" "  Making './${script_file}' executable..."
  chmod +x "./${script_file}"
  if [ $? -ne 0 ]; then
    cecho "${YELLOW}" "  Warning: Failed to make './${script_file}' executable. Please check permissions."
  else
    cecho "${GREEN}" "  './${script_file}' is now executable."
  fi

  # Create symbolic link
  cecho "${BLUE}" "  Creating symbolic link for '${script_file}' as '${target_name}' in ${BIN_DIR}..."
  # Using ln -s for symbolic link, which is standard for executables.
  # -f (force) is useful if a link already exists, -s for symbolic.
  ln -sf "$(pwd)/${script_file}" "${BIN_DIR}/${target_name}"
  if [ $? -ne 0 ]; then
    cecho "${RED}" "  Error: Failed to create symbolic link for '${script_file}'. Please check permissions."
    return 1
  else
    cecho "${GREEN}" "  Successfully linked '${target_name}'."
  fi
  return 0
}

install_script "alias_manager.sh" "mnemonicon"

cecho "${GREEN}" "Installation complete!"
cecho "${GREEN}" "You can now run 'mnemonicon' from anywhere in your terminal."
cecho "${GREEN}" "Remember to restart your terminal or 'source' your shell config if ~/.local/bin was just added to PATH."
