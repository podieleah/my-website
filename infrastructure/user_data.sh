#!/bin/bash

# Update and install prerequisites
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release nginx certbot python3-certbot-nginx

# Install Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Pull and run your app container (binding only to localhost)
docker pull ${docker_image}
docker run -d --name flask_app -p 127.0.0.1:5000:5000 --restart unless-stopped ${docker_image}

# Configure Nginx reverse proxy (HTTP only, used for Let's Encrypt validation)
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name jodiecoleman.co.uk www.jodiecoleman.co.uk;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /health {
        proxy_pass http://127.0.0.1:5000/health;
        access_log off;
    }
}
EOF

# Restart Nginx
systemctl restart nginx

# Wait briefly in case DNS is still propagating
sleep 15

# Run Certbot to obtain and configure HTTPS
certbot --nginx --non-interactive --agree-tos --email jodiecoleman1@outlook.com \
  -d jodiecoleman.co.uk -d www.jodiecoleman.co.uk

# Add auto-renewal cron
echo "0 0 * * * root certbot renew --quiet" >> /etc/crontab

# Log
echo "$(date): Deployment with HTTPS complete" >> /var/log/portfolio-deploy.log
