#!/bin/bash

set -e

# Variables
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="helpLLM.sh"
CONFIG_FILE="$HOME/.llm_config.json"

# Function to remove the script
remove_script() {
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        echo "Removing $SCRIPT_NAME from $INSTALL_DIR..."
        rm "$INSTALL_DIR/$SCRIPT_NAME"
        echo "$SCRIPT_NAME has been removed."
    else
        echo "$SCRIPT_NAME not found in $INSTALL_DIR."
    fi
}

# Function to remove the configuration file
remove_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo "Removing configuration file at $CONFIG_FILE..."
        rm "$CONFIG_FILE"
        echo "Configuration file has been removed."
    else
        echo "No configuration file found at $CONFIG_FILE."
    fi
}

# Function to check and update PATH
update_path() {
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        echo "Removing $INSTALL_DIR from PATH..."
        # Remove the export command from .bashrc or .zshrc
        sed -i '/export PATH=\$PATH:'"$INSTALL_DIR"'/d' "$HOME/.bashrc" 2>/dev/null || true
        sed -i '/export PATH=\$PATH:'"$INSTALL_DIR"'/d' "$HOME/.zshrc" 2>/dev/null || true
        echo "Please restart your terminal to apply changes."
    else
        echo "$INSTALL_DIR is not in your PATH."
    fi
}

# Confirm uninstallation
read -p "Are you sure you want to uninstall helpLLM.sh and all associated files? (y/N): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    remove_script
    remove_config
    update_path
    echo "Uninstallation complete."
else
    echo "Uninstallation canceled."
fi
