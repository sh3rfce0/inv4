#!/bin/bash

# Directory for bot configuration
BOT_DIR="/etc/bot"
DB_FILE="$BOT_DIR/.bot.db"

echo "==============================="
echo "   Sherif VPN BOT SETUP"
echo "==============================="

# Create directory if it doesn't exist
mkdir -p "$BOT_DIR"

# Prompt for Token
read -p "Enter your Telegram Bot Token: " token
if [ -z "$token" ]; then
    echo "Error: Token cannot be empty."
    exit 1
fi

# Prompt for Admin Chat ID
read -p "Enter your Telegram Admin Chat ID: " chat_id
if [ -z "$chat_id" ]; then
    echo "Error: Chat ID cannot be empty."
    exit 1
fi

# Save to database
echo "#bot# $token $chat_id" > "$DB_FILE"
chmod 600 "$DB_FILE"

echo "==============================="
echo "✅ Bot configuration saved!"
echo "Database: $DB_FILE"
echo "Token   : $token"
echo "Admin ID: $chat_id"
echo "==============================="
echo "You can now use the bot features in the script."
