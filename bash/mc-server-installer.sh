#!/bin/bash

# ===========================
# Advanced Minecraft Server Auto Setup
# ===========================

echo "==== Minecraft Server Auto Setup ===="

# ------------------------
# Install dependencies
# ------------------------
echo "Updating package lists and installing dependencies..."
sudo apt update
sudo apt install -y default-jdk wget curl jq unzip tmux

# Check Java
if ! command -v java &> /dev/null; then
    echo "Java not installed correctly. Exiting."
    exit 1
fi

# ------------------------
# Memory calculations
# ------------------------
total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
total_ram_gb=$(awk "BEGIN {printf \"%.0f\", $total_ram_kb/1024/1024}")

echo "Total system RAM: ${total_ram_gb}GB"

echo "Choose how much RAM to allocate to the server:"
echo "1) All available RAM (${total_ram_gb}GB)"
echo "2) 80% of total RAM (~$((total_ram_gb * 80 / 100))GB)"
echo "3) 50% of total RAM (~$((total_ram_gb / 2))GB)"
echo "4) 25% of total RAM (~$((total_ram_gb / 4))GB)"
echo "5) Minimum (1.5GB)"

read -rp "Enter choice (1-5): " ram_choice

case $ram_choice in
  1) ram_gb=$total_ram_gb ;;
  2) ram_gb=$((total_ram_gb * 80 / 100)) ;;
  3) ram_gb=$((total_ram_gb / 2)) ;;
  4) ram_gb=$((total_ram_gb / 4)) ;;
  5) ram_gb=2 ;;
  *) echo "Invalid choice. Defaulting to 2GB."; ram_gb=2 ;;
esac

if (( ram_gb < 2 )); then
  ram_gb=2
fi

ram_value="${ram_gb}G"
echo "Selected RAM: $ram_value"

# ------------------------
# Choose server software
# ------------------------
echo "Choose server software:"
echo "1) Vanilla"
echo "2) Paper"
echo "3) Fabric"
echo "4) Modrinth Modpack"

read -rp "Enter choice (1-4): " software_choice

read -rp "Enter server directory name: " dir_name
SERVER_DIR="$HOME/$dir_name"
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR" || exit

case $software_choice in
  1)
    echo "You chose Vanilla."
    read -rp "Enter Minecraft version (e.g., 1.20.6): " mc_version
    manifest_url="https://piston-meta.mojang.com/mc/game/version_manifest.json"
    version_url=$(curl -s "$manifest_url" | jq -r --arg v "$mc_version" '.versions[] | select(.id == $v) | .url')
    if [ -z "$version_url" ]; then
        echo "Invalid version or unable to fetch version URL."
        exit 1
    fi
    JAR_URL=$(curl -s "$version_url" | jq -r '.downloads.server.url')
    JAR_NAME="server.jar"
    ;;
  2)
    echo "You chose Paper."
    read -rp "Enter Paper version (e.g., 1.20.6): " mc_version
    build=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$mc_version" | jq -r '.builds[-1]')
    if [ "$build" = "null" ]; then
        echo "Invalid Paper version or no builds available."
        exit 1
    fi
    JAR_URL="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/$build/downloads/paper-$mc_version-$build.jar"
    JAR_NAME="paper.jar"
    ;;
  3)
    echo "You chose Fabric."
    read -rp "Enter Minecraft version (e.g., 1.20.6): " mc_version
    loader_version=$(curl -s "https://meta.fabricmc.net/v2/versions/loader/$mc_version" | jq -r '.[0].loader.version')
    installer_version=$(curl -s "https://meta.fabricmc.net/v2/versions/installer" | jq -r '.[0].version')
    if [ -z "$loader_version" ] || [ -z "$installer_version" ]; then
        echo "Unable to find Fabric loader or installer for this version."
        exit 1
    fi
    echo "Downloading Fabric installer..."
    curl -O "https://meta.fabricmc.net/v2/versions/installer/$installer_version/installer.jar"
    echo "Running Fabric installer headlessly..."
    java -jar installer.jar server -mcversion "$mc_version" -loader "$loader_version" -downloadMinecraft
    rm installer.jar
    JAR_NAME="fabric-server-launch.jar"
    ;;
  4)
    echo "You chose Modrinth Modpack."
    read -rp "Enter Modrinth Modpack slug or ID: " modpack_id
    read -rp "Enter Modpack version ID: " version_id
    echo "Downloading modpack metadata..."
    curl -L "https://api.modrinth.com/v2/version/$version_id" -o modrinth-version.json
    dl_url=$(jq -r '.files[] | select(.primary == true).url' modrinth-version.json)
    if [ -z "$dl_url" ]; then
        echo "Could not find primary download URL for this modpack version."
        exit 1
    fi
    echo "Downloading modpack..."
    wget -O modpack.zip "$dl_url"
    echo "Extracting modpack..."
    unzip modpack.zip -d "$SERVER_DIR"
    rm modpack.zip modrinth-version.json
    echo "Check extracted folder for start scripts (start.sh, setup.sh, etc.)."
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

if [ "$software_choice" -ne 4 ]; then
    echo "Downloading server jar..."
    wget -O "$JAR_NAME" "$JAR_URL"
fi

echo "Accepting EULA..."
echo "eula=true" > eula.txt

if [ "$software_choice" -ne 4 ]; then
    echo "Creating start script..."
    cat <<EOL > start.sh
#!/bin/bash
java -Xms${ram_value} -Xmx${ram_value} -jar $JAR_NAME nogui
EOL
    chmod +x start.sh
fi

# ------------------------
# Start tmux session
# ------------------------
SESSION_NAME="mc-server"

if [ "$software_choice" -ne 4 ]; then
    echo "Starting server inside tmux session: $SESSION_NAME"
    tmux new-session -d -s "$SESSION_NAME" "./start.sh"
else
    echo "Modrinth modpack extracted. You may need to run setup or start scripts manually."
    echo "Creating tmux session for you anyway..."
    tmux new-session -d -s "$SESSION_NAME" "bash"
fi

# ------------------------
# Print public IP and port
# ------------------------
public_ip=$(curl -s https://api.ipify.org)

echo "========================================"
echo "Setup complete!"
echo "Server directory: $SERVER_DIR"
echo "Public IP: $public_ip"
echo "Port: 25565 (default)"
echo ""
echo "Your server is running inside tmux session: $SESSION_NAME"
echo "To attach and see console, run:"
echo "tmux attach -t $SESSION_NAME"
echo "To detach, press: Ctrl + b, then d"
echo "========================================"
