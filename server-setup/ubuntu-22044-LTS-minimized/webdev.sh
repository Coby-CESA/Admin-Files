#/bin/bash

# Force script to be run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges. Re-running with sudo..."
    sudo "$0" "$@"
    exit $?
fi

# Add prod user
adduser prod
usermod -aG sudo prod

# Install necessary packages
apt install vim nodejs npm

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
nvm install --lts
nvm use --lts

# Install global npm packages
npm install -g @angular/cli nodemon

# Generate SSH key
read -p "Enter your Github account email: " email
ssh-keygen -t ed25519 -C "$email"

# Manage and clone github repository
echo "Here is the SSH key:"
cat /.ssh/id_ed25519.pub
read -p "Please add the key to your Github account and press [Enter] to continue..."
read -p "Enter the Github repository URL: " repo
git clone $repo /home/prod/app

# Write run scripts
repository_name=$(basename "${repo%.git}")
echo "cd $repository_name/Angular; git pull; ng serve --host 0.0.0.0" > /home/prod/angular.sh
echo "cd $repository_name/Express; git pull; nodemon app.js" > /home/prod/express.sh

echo "Setup complete. Please remember to set up any port forwarding rules on your router."