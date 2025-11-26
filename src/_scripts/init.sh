#!/bin/bash

# Load environment variables from .env file
ENV_FILE="/tmp/src/.env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Warning: .env file not found at $ENV_FILE"
fi

# Replace placeholders in files with actual values
directory="/tmp/src"

patterns=(
    "DOMAIN"
    "MYSQL:USERNAME"
    "MYSQL:PASSWORD"
    "OPENAI:KEY"
    "ADMIN:USERNAME"
    "ADMIN:PASSWORD"
)

replacements=(
    "${DOMAIN:-Replace this with your domain}"
    "${MYSQL_USERNAME:-Replace this with your MySQL admin username (choose one)}"
    "${MYSQL_PASSWORD:-Replace this with your MySQL admin password (choose one)}"
    "${OPENAI_KEY:-Replace this with your OpenAI Key}"
    "${ADMIN_USERNAME:-Replace this with your admin panel username (choose one)}"
    "${ADMIN_PASSWORD:-Replace this with your admin panel password (choose one)}"
)

if [ ${#patterns[@]} -ne ${#replacements[@]} ]; then
    echo "Error: The number of patterns and replacements do not match."
    exit 1
fi

replacements[4]=$(echo -n "${replacements[4]}" | sha256sum | awk '{print $1}')

for file in $(find "$directory"); do
    if [ -f "$file" ]; then
        echo "Processing $file"
        for i in "${!patterns[@]}"; do
            sed -i -e "s/#_${patterns[i]}_#/${replacements[i]}/g" "$file"
        done
    fi
done

# Prefill configurations
cat /tmp/src/postfix/preconfig | debconf-set-selections

# Move startup script to root
mv /tmp/src/_scripts/startup.sh /startup.sh