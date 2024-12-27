# helpLLM

`helpLLM` is a lightweight and user-friendly command-line assistant powered by OpenAI's GPT models. It helps you find quick solutions, terminal commands, or explanations for your Linux tasks directly from the command line.

## Features

- Queries OpenAI's GPT models to provide **terminal commands** and their **explanations**.
- Configurable to use different GPT models (`gpt-4`, `gpt-3.5-turbo`).
- Stores your OpenAI API key and model preferences locally.
- Verbose logging for debugging.
- JSON-based structured output for easy parsing.
- Easy installation and uninstallation.

---

## Installation

Install `helpLLM` directly from this repository:

```bash
curl -fsSL https://raw.githubusercontent.com/paulfournel/helpLLM/main/install.sh | bash
```

### Dependencies

1. **jq**: `helpLLM` relies on `jq` for JSON parsing. If it's not installed, the installer will try to install it automatically.
2. **OpenAI API Key**: You must have an OpenAI API key to use this tool. [Get your API key here](https://platform.openai.com/account/api-keys).

---

## Usage

Run the script with your query or configuration options:

```bash
helpLLM.sh [options] "your question here"
```

### Options

| Option            | Description                                       |
|-------------------|---------------------------------------------------|
| `-c`, `--configure` | Configure the OpenAI API key and preferred model. |
| `-v`, `--verbose`   | Enable verbose logging for debugging purposes.    |
| `-h`, `--help`      | Display help information.                         |

### Examples

1. **Basic Usage**:
   ```bash
   helpLLM.sh "How do I list files in a directory?"
   ```

2. **Verbose Logging**:
   ```bash
   helpLLM.sh -v "How do I find a process by its name?"
   ```

3. **Configure API Key and Model**:
   ```bash
   helpLLM.sh --configure
   ```

---

## Configuration

The tool saves your OpenAI API key and preferred model to `~/.llm_config.json`. You can reconfigure it anytime by running:

```bash
helpLLM.sh --configure
```

### Configuration File Example

`~/.llm_config.json`:
```json
{
  "model": "gpt-4",
  "token": "your-openai-api-key"
}
```

---

## Uninstallation

To uninstall `helpLLM` and remove all associated files, run:

```bash
curl -fsSL https://raw.githubusercontent.com/paulfournel/helpLLM/main/uninstall.sh | bash
```

This will:
- Remove the `helpLLM.sh` script.
- Delete the configuration file (`~/.llm_config.json`).
- Remove `~/.local/bin` from your `PATH` if it was added during installation.

---

## Development

### Requirements
- Bash
- `curl`
- `jq`

### Contributing
Contributions are welcome! Feel free to submit issues, fork the repository, and create pull requests.

---

## License

This project is licensed under the [MIT License](LICENSE).

