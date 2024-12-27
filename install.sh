#!/bin/bash

set -e

# Variables
REPO_URL="https://raw.githubusercontent.com/paulfournel/helpLLM/main"
SCRIPT_NAME="helpLLM.sh"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_FILE="$HOME/.llm_config.json"

# Create the installation directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    echo "Created installation directory at $INSTALL_DIR"
fi

# Download the script
echo "Downloading $SCRIPT_NAME..."
curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"

# Make the script executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
echo "$SCRIPT_NAME has been installed to $INSTALL_DIR"

# Ensure the installation directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding $INSTALL_DIR to your PATH..."
    echo "export PATH=\$PATH:$INSTALL_DIR" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    echo "Path updated. Restart your terminal to apply changes."
fi

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        echo "Please install 'jq' manually for your platform."
        exit 1
    fi
else
    echo "jq is already installed."
fi

# Inform the user about configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating a default configuration file at $CONFIG_FILE..."
    echo '{}' > "$CONFIG_FILE"
else
    echo "Configuration file already exists at $CONFIG_FILE."
fi

echo "Installation completed! Run 'helpLLM.sh --help' to get started."
