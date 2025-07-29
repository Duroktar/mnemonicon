#!/bin/bash

# Configuration file for aliases
ALIAS_FILE="$HOME/.bash_aliases"

# Ensure the alias file exists
touch "$ALIAS_FILE"

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
    local aliases_raw=() # Stores pairs of "name" "command"
    local menu_options=() # Stores "index" "name: command" for whiptail
    local i=0

    while IFS= read -r line; do
        if [[ "$line" =~ ^alias[[:space:]]+([^=]+)=[\"\'](.+)[\"\']$ ]]; then
            local name="${BASH_REMATCH[1]}"
            local cmd="${BASH_REMATCH[2]}"
            aliases_raw+=("$name" "$cmd")
            menu_options+=("$i" "$name: $cmd")
            i=$((i + 1))
        fi
    done < "$ALIAS_FILE"

    if [ ${#aliases_raw[@]} -eq 0 ]; then
        whiptail --msgbox "No aliases to edit." 8 40
        return
    fi

    # Corrected way to capture output and check status directly for cancellation
    local selected_menu_index
    if ! selected_menu_index=$(whiptail --menu "Choose an alias to edit:" 20 78 12 "${menu_options[@]}" 3>&1 1>&2 2>&3); then
        # If whiptail exits with non-zero status (e.g., Cancel/ESC)
        return
    fi

    # Calculate the actual index in aliases_raw
    local original_name_index=$((selected_menu_index * 2))
    local original_command_index=$((selected_menu_index * 2 + 1))

    local original_name="${aliases_raw[$original_name_index]}"
    local original_command="${aliases_raw[$original_command_index]}"

    local new_command=$(whiptail --inputbox "Edit command for '$original_name':" 8 60 "$original_command" 3>&1 1>&2 2>&3)
    local exit_status=$? # Keep this check as it's separate input
    if [ $exit_status -ne 0 ]; then return; fi # User cancelled

    if [ -z "$new_command" ]; then
        whiptail --msgbox "Alias command cannot be empty. No changes made." 8 50
        return
    fi

    # Use awk to replace the line
    awk -v old_name_regex="^alias[[:space:]]+${original_name}==" -v old_name="$original_name" -v new_cmd="$new_command" '
        BEGIN { found = 0 }
        $0 ~ old_name_regex {
            print "alias " old_name "=\x27" new_cmd "\x27"
            found = 1
        }
        !($0 ~ old_name_regex) {
            print $0
        }
        END {
            if (!found) {
                print "alias " old_name "=\x27" new_cmd "\x27"
            }
        }
    ' "$ALIAS_FILE" > "${ALIAS_FILE}.tmp" && mv "${ALIAS_FILE}.tmp" "$ALIAS_FILE"

    whiptail --msgbox "Alias '$original_name' updated successfully. Remember to 'source ~/.bashrc' or open a new terminal for changes to take effect." 10 70
}

# Function to delete an alias
delete_alias() {
    local aliases_raw=() # Stores pairs of "name" "command"
    local menu_options=() # Stores "index" "name: command" for whiptail
    local i=0

    while IFS= read -r line; do
        if [[ "$line" =~ ^alias[[:space:]]+([^=]+)=[\"\'](.+)[\"\']$ ]]; then
            local name="${BASH_REMATCH[1]}"
            local cmd="${BASH_REMATCH[2]}"
            aliases_raw+=("$name" "$cmd")
            menu_options+=("$i" "$name: $cmd")
            i=$((i + 1))
        fi
    done < "$ALIAS_FILE"

    if [ ${#aliases_raw[@]} -eq 0 ]; then
        whiptail --msgbox "No aliases to delete." 8 40
        return
    fi

    # Corrected way to capture output and check status directly for cancellation
    local selected_menu_index
    if ! selected_menu_index=$(whiptail --menu "Choose an alias to delete:" 20 78 12 "${menu_options[@]}" 3>&1 1>&2 2>&3); then
        # If whiptail exits with non-zero status (e.g., Cancel/ESC)
        return
    fi

    # Calculate the actual index of the name in aliases_raw
    local alias_name_to_delete="${aliases_raw[$((selected_menu_index * 2))]}"

    if (whiptail --yesno "Are you sure you want to delete alias '$alias_name_to_delete'?" 8 50); then
        # Use sed to delete the line containing the alias. Escaping special characters in alias_name_to_delete for sed.
        sed -i "/^alias[[:space:]]\+${alias_name_to_delete}=/d" "$ALIAS_FILE"
        whiptail --msgbox "Alias '$alias_name_to_delete' deleted successfully. Remember to 'source ~/.bashrc' or open a new terminal for changes to take effect." 10 70
    else
        whiptail --msgbox "Deletion cancelled." 8 40
    fi
}

# Main menu
while true; do
    CHOICE=$(whiptail --menu "Alias Manager (File: $ALIAS_FILE)" 20 78 12 \
        "1" "Add Alias" \
        "2" "Edit Alias" \
        "3" "Delete Alias" \
        "4" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) add_alias ;;
        2) edit_alias ;;
        3) delete_alias ;;
        4) break ;;
        *) break ;; # Handle ESC or other unexpected input
    esac
done

exit 0
