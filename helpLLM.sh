#!/bin/bash

# Define color codes
DARK_BLUE="\033[1;34m"
GREEN="\033[1;32m"
BOLD_BLACK="\033[1;30;1m"
RED="\033[1;31m"
RESET="\033[0m"

# Configuration file path
CONFIG_FILE="$HOME/.llm_config.json"
VERBOSE=false

# Function to print usage/help message
print_help() {
    echo -e "${GREEN}Usage:${RESET} $0 [options] \"your question here\""
    echo -e "${GREEN}Options:${RESET}"
    echo -e "  ${BOLD_BLACK}-c, --configure${RESET}  Configure the OpenAI API model"
    echo -e "  ${BOLD_BLACK}-v, --verbose${RESET}    Enable verbose logging"
    echo -e "  ${BOLD_BLACK}-h, --help${RESET}       Show this help message"
    echo -e "${GREEN}Example:${RESET}"
    echo -e "  $0 -c"
    echo -e "  $0 -v \"How do I list files in a directory?\""
}

# Function to configure the OpenAI API model and token
configure_model() {
    # Load existing configuration if available
    if [ -f "$CONFIG_FILE" ]; then
        existing_model=$(jq -r '.model' "$CONFIG_FILE" 2>/dev/null)
        existing_token=$(jq -r '.token' "$CONFIG_FILE" 2>/dev/null)
    fi

    # Display existing token and prompt for a new one
    echo -e "${GREEN}Existing OpenAI API Token:${RESET} ${existing_token:-<not set>}"
    read -p "Enter your OpenAI API token (leave empty to keep the existing one): " new_token
    if [ -n "$new_token" ]; then
        token_to_save="$new_token"
    else
        token_to_save="$existing_token"
    fi

    # Display available models and prompt for selection
    echo -e "${DARK_BLUE}Available OpenAI Models:${RESET}"
    models=("gpt-4" "gpt-3.5-turbo")
    select model in "${models[@]}"; do
        if [ -n "$model" ]; then
            echo -e "${GREEN}You selected:${RESET} $model"
            break
        else
            echo -e "${RED}Invalid selection. Please try again.${RESET}"
        fi
    done

    # Save the configuration to the file
    jq -n --arg model "$model" --arg token "$token_to_save" '{
        model: $model,
        token: $token
    }' > "$CONFIG_FILE"

    echo -e "${GREEN}Configuration saved to $CONFIG_FILE.${RESET}"
}

# Function to load the configured model
load_model() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}No configuration found. Please configure the model.${RESET}"
        configure_model
    fi
    jq -r '.model' "$CONFIG_FILE"
}

# Function to load the OpenAI API token
load_token() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}No configuration found. Please configure the token.${RESET}"
        configure_model
    fi
    jq -r '.token' "$CONFIG_FILE"
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--configure)
            configure_model
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            # Treat the remaining arguments as the question
            question="$*"
            break
            ;;
    esac
done

# Ensure a question is provided
if [ -z "$question" ]; then
    echo -e "${RED}Error:${RESET} No question provided. Use --help for usage information."
    exit 1
fi

# Load the configured model and token
LLM_MODEL=$(load_model)
OPENAI_API_KEY=$(load_token)

if $VERBOSE; then
    echo -e "${DARK_BLUE}Using OpenAI model:${RESET} $LLM_MODEL"
fi

# OpenAI API URL
OPENAI_API_URL="https://api.openai.com/v1/chat/completions"

# Build JSON payload
payload=$(jq -n --arg model "$LLM_MODEL" --arg content "You are a Linux terminal assistant. Respond ONLY with valid JSON containing two keys: 'description' (a short explanation of the command) and 'suggestion' (the terminal command to accomplish the task). Question: \"$question\"" \
'{
    model: $model,
    messages: [
        {
            role: "system",
            content: "You are a Linux terminal assistant. Always respond in JSON format."
        },
        {
            role: "user",
            content: $content
        }
    ],
    response_format: { "type": "json_object" }
}')

if $VERBOSE; then
    echo -e "${DARK_BLUE}Payload sent to OpenAI API:${RESET}\n$payload"
fi

# Query the OpenAI API
response=$(curl -s -X POST "$OPENAI_API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$payload")

# Check if the response contains an error
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
    error_message=$(echo "$response" | jq -r '.error.message')
    echo -e "${RED}OpenAI API Error:${RESET} $error_message"
    exit 1
fi

# Extract the JSON response directly
description=$(echo "$response" | jq -r '.choices[0].message.content.description')
suggestion=$(echo "$response" | jq -r '.choices[0].message.content.suggestion')

# Validate the extracted data
if [ -z "$description" ] || [ -z "$suggestion" ]; then
    echo -e "${RED}Error:${RESET} Failed to parse response from OpenAI. Please check the API response:"
    echo "$response"
    exit 1
fi

# Display the result to the user with color
echo -e "\n${DARK_BLUE}--- Linux Terminal Assistant ---${RESET}"
echo -e "Description: ${GREEN}$description${RESET}"
echo -e "Suggestion: ${BOLD_BLACK}$suggestion${RESET}"

if $VERBOSE; then
    echo -e "${DARK_BLUE}Raw response:${RESET}\n$response"
fi
