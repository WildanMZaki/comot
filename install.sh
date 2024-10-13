#!/bin/bash

# Default alias name
DEFAULT_FN_NAME="comot"

# Ask the user for the preferred alias name
read -r -p "Enter your preferred command alias ($DEFAULT_FN_NAME): " fn_name

# Use default if no alias name is provided
if [ -z "$fn_name" ]; then
  fn_name=$DEFAULT_FN_NAME
fi

# Get the current directory (which is where comot.sh is located)
current_dir=$(pwd)

# Create runner.sh with the function definition
cat <<EOL > runner.sh
# This script defines the alias to call comot.sh
$fn_name () {
    $current_dir/comot.sh "\$@"
}
EOL

# Create .comot.sh in the home directory to store the installation path
cat <<EOL > "$HOME/.comot.sh"
# Store the installation path
INSTALLATION_PATH="$current_dir"

# Default directory for Windows Downloads
DOWNLOADS_DIR="$HOME/Downloads"
EOL

# Check if ~/.bashrc exists, create it if not
if [ ! -f ~/.bashrc ]; then
    echo "Creating ~/.bashrc..."
    touch ~/.bashrc
fi

# Add source line for runner.sh to ~/.bashrc if not already added
if ! grep -q "source $current_dir/runner.sh" ~/.bashrc; then
    echo "Adding source to ~/.bashrc..."
    echo "source $current_dir/runner.sh" >> ~/.bashrc
else
    echo "runner.sh is already sourced in ~/.bashrc."
fi

# Final message
echo "Installation complete! Please restart your terminal or run 'source ~/.bashrc' to start using '$fn_name'."
