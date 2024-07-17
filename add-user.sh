ACTION=$1
CHAT_ID=$2
SSH_USERNAME=$3
SSH_PASSWORD=$4
BOT_TOKEN="7267929870:AAHC2lojziLjI1ujugqM5iHLaDhSiPFlGkU"

send_telegram_message() {
    local MESSAGE=$1
    local INLINE_KEYBOARD='{"inline_keyboard":[[{"text":"Powered By","url":"https://t.me/NorSodikin"}]]}'
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE" -d parse_mode=Markdown -d reply_markup="$INLINE_KEYBOARD"
}

case $ACTION in
  add)
    if id "$SSH_USERNAME" &>/dev/null; then
        MESSAGE="User $SSH_USERNAME already exists. Please choose a different username."
    else
        sudo adduser --disabled-password --gecos "" $SSH_USERNAME --force-badname
        echo "$SSH_USERNAME:$SSH_PASSWORD" | sudo chpasswd
        sudo usermod -aG sudo $SSH_USERNAME

        HOSTNAME=$(hostname -I | cut -d' ' -f1)
        MESSAGE="*SSH login information:*%0A%0A*Username:* $SSH_USERNAME%0A*Password:* $SSH_PASSWORD%0A*Hostname:* $HOSTNAME%0A%0A_Use the above information to connect using PuTTY or any SSH client._"
    fi

    send_telegram_message "$MESSAGE"
    ;;

  delete)
    if ! id "$SSH_USERNAME" &>/dev/null; then
        MESSAGE="User $SSH_USERNAME does not exist."
    else
        sudo usermod --expiredate 1 $SSH_USERNAME
        sudo deluser --remove-home $SSH_USERNAME
        MESSAGE="User $SSH_USERNAME has been deleted from the system and can no longer log in."
    fi

    send_telegram_message "$MESSAGE"
    ;;

  *)
    echo "Invalid action. Use 'add' to add a user or 'delete' to delete a user."
    ;;
esac
