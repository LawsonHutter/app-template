#!/bin/bash
set -e

echo "========================================"
echo "  Setting up EC2 instance"
echo "========================================"
echo ""

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo ""
echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    echo "✓ Docker installed"
else
    echo "✓ Docker already installed"
fi

# Add user to docker group
echo ""
echo "Adding user to docker group..."
sudo usermod -aG docker ubuntu || true

# Install Docker Compose
echo ""
echo "Installing Docker Compose..."
if ! command -v docker compose &> /dev/null; then
    sudo apt install docker-compose-plugin -y
    echo "✓ Docker Compose installed"
else
    echo "✓ Docker Compose already installed"
fi

# Verify installations
echo ""
echo "Verifying installations..."
docker --version
docker compose version

# Create app directory
echo ""
echo "Creating app directory..."
mkdir -p ~/app
cd ~/app

# Create .env template
echo ""
echo "Creating .env template..."
cat > .env.template << 'ENVEOF'
# Django Configuration
SECRET_KEY=CHANGE_ME_GENERATE_SECRET_KEY
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,YOUR_EC2_IP
DATABASE_URL=postgresql://counter_user:CHANGE_ME_STRONG_PASSWORD@db:5432/counter_db
POSTGRES_PASSWORD=CHANGE_ME_STRONG_PASSWORD
CORS_ALLOWED_ORIGINS=http://yourdomain.com,https://www.yourdomain.com

# EC2 Configuration
EC2_IP=YOUR_EC2_IP
ENVEOF

echo "✓ .env.template created"
echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Copy your project files to ~/app"
echo "  2. Copy .env.template to .env and fill in values"
echo "  3. Run: docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build"
echo ""
