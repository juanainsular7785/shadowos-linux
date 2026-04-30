hide-lutris:
    #!/usr/bin/env bash
    APP_FILE="net.lutris.Lutris.desktop"
    SOURCE_PATH="/usr/share/applications/$APP_FILE"
    DEST_DIR="$HOME/.local/share/applications"
    DEST_PATH="$DEST_DIR/$APP_FILE"
    
    if [ ! -f "$SOURCE_PATH" ]; then
        echo "Error: Lutris desktop file not found at $SOURCE_PATH"
        exit 1
    fi

    mkdir -p "$DEST_DIR"
    cp "$SOURCE_PATH" "$DEST_PATH"
    
    if grep -q "NoDisplay=" "$DEST_PATH"; then
        sed -i 's/NoDisplay=.*/NoDisplay=true/' "$DEST_PATH"
    else
        echo "NoDisplay=true" >> "$DEST_PATH"
    fi
    
    echo "Lutris hidden. You may need to restart your desktop session or shell."

unhide-lutris:
    rm -f "$HOME/.local/share/applications/net.lutris.Lutris.desktop"
    echo "Lutris restored to menu."
      
