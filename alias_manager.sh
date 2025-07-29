#!/bin/bash

# Configuration file for aliases
ALIAS_FILE="$HOME/.bash_aliases"

# Ensure the alias file exists
touch "$ALIAS_FILE"

# Function to display aliases
display_aliases() {
    local aliases=$(grep '^alias ' "$ALIAS_FILE" | sed 's/^alias //')
    if [ -z "$aliases" ]; then
        whiptail --msgbox "No aliases found." 8 40
    else
        whiptail --msgbox "$aliases" 20 80 --title "Current Aliases"
    fi
}

# Function to add an alias
add_alias() {
    local alias_name=$(whiptail --inputbox "Enter alias name (e.g., ll)" 8 40 3>&1 1>&2 2>&3)
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then return; fi # User cancelled

    if [ -z "$alias_name" ]; then
        whiptail --msgbox "Alias name cannot be empty." 8 40
        return
    fi

    local alias_command=$(whiptail --inputbox "Enter command for '$alias_name' (e.g., ls -laF)" 8 60 3>&1 1>&2 2>&3)
    exit_status=$?
    if [ $exit_status -ne 0 ]; then return; fi # User cancelled

    if [ -z "$alias_command" ]; then
        whiptail --msgbox "Alias command cannot be empty." 8 40
        return
    fi

    echo "alias $alias_name='$alias_command'" >> "$ALIAS_FILE"
    whiptail --msgbox "Alias '$alias_name' added successfully. Remember to 'source ~/.bashrc' or open a new terminal for changes to take effect." 10 70
}

# Function to edit an alias
edit_alias() {
    local aliases=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^alias[[:space:]]+([^=]+)=[\"\'](.+)[\"\']$ ]]; then
            local name="${BASH_REMATCH[1]}"
            local cmd="${BASH_REMATCH[2]}"
            aliases+=("$name" "$cmd")
        fi
    done < "$ALIAS_FILE"

    if [ ${#aliases[@]} -eq 0 ]; then
        whiptail --msgbox "No aliases to edit." 8 40
        return
    fi

    local selected_alias_index=$(whiptail --menu "Choose an alias to edit:" 20 78 12 "${aliases[@]}" 3>&1 1>&2 2>&3)
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then return; fi # User cancelled

    local original_name="${aliases[$selected_alias_index]}"
    local original_command="${aliases[$((selected_alias_index + 1))]}"

    local new_command=$(whiptail --inputbox "Edit command for '$original_name':" 8 60 "$original_command" 3>&1 1>&2 2>&3)
    exit_status=$?
    if [ $exit_status -ne 0 ]; then return; fi # User cancelled

    if [ -z "$new_command" ]; then
        whiptail --msgbox "Alias command cannot be empty. No changes made." 8 50
        return
    fi

    # Use awk to replace the line
    awk -v old_name="$original_name" -v new_cmd="$new_command" '
        BEGIN { found = 0 }
        $0 ~ ("^alias " old_name "=.+") {
            print "alias " old_name "=\x27" new_cmd "\x27"
            found = 1
        }
        !($0 ~ ("^alias " old_name "=.+")) {
            print $0
        }
        END {
            if (!found) {
                # This case should ideally not happen if selection is from existing aliases
                print "alias " old_name "=\x27" new_cmd "\x27"
            }
        }
    ' "$ALIAS_FILE" > "${ALIAS_FILE}.tmp" && mv "${ALIAS_FILE}.tmp" "$ALIAS_FILE"

    whiptail --msgbox "Alias '$original_name' updated successfully. Remember to 'source ~/.bashrc' or open a new terminal for changes to take effect." 10 70
}

# Function to delete an alias
delete_alias() {
    local aliases=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^alias[[:space:]]+([^=]+)=[\"\'](.+)[\"\']$ ]]; then
            local name="${BASH_REMATCH[1]}"
            local cmd="${BASH_REMATCH[2]}"
            aliases+=("$name" "$cmd")
        fi
    done < "$ALIAS_FILE"

    if [ ${#aliases[@]} -eq 0 ]; then
        whiptail --msgbox "No aliases to delete." 8 40
        return
    fi

    local selected_alias_index=$(whiptail --menu "Choose an alias to delete:" 20 78 12 "${aliases[@]}" 3>&1 1>&2 2>&3)
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then return; fi # User cancelled

    local alias_to_delete="${aliases[$selected_alias_index]}"

    if (whiptail --yesno "Are you sure you want to delete alias '$alias_to_delete'?" 8 50); then
        # Use sed to delete the line containing the alias
        sed -i "/^alias[[:space:]]\+$alias_to_delete=/d" "$ALIAS_FILE"
        whiptail --msgbox "Alias '$alias_to_delete' deleted successfully. Remember to 'source ~/.bashrc' or open a new terminal for changes to take effect." 10 70
    else
        whiptail --msgbox "Deletion cancelled." 8 40
    fi
}

# Main menu
while true; do
    CHOICE=$(whiptail --menu "Alias Manager (File: $ALIAS_FILE)" 20 78 12 \
        "1" "View Aliases" \
        "2" "Add Alias" \
        "3" "Edit Alias" \
        "4" "Delete Alias" \
        "5" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) display_aliases ;;
        2) add_alias ;;
        3) edit_alias ;;
        4) delete_alias ;;
        5) break ;;
        *) break ;; # Handle ESC or other unexpected input
    esac
done

exit 0
