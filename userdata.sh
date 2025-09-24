#!/bin/bash
set -e

# ===== 1. Atualiza pacotes =====
apt-get update -y
apt-get install -y docker.io curl unzip nfs-common mysql-client

# ===== 2. Ativa Docker =====
systemctl start docker
systemctl enable docker

# ===== 3. Instala Docker Compose =====
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# ===== 4. Monta o EFS =====
# Substitua fs-xxxxx pelo ID do seu EFS e us-east-1 pela região
EFS_ID=fs-xxxxx
REGION=us-east-1

mkdir -p /mnt/efs
echo "$EFS_ID.efs.$REGION.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0" >> /etc/fstab
mount -a

# Garante pasta para WordPress no EFS
mkdir -p /mnt/efs/html
chmod -R 777 /mnt/efs/html

# ===== 5. Cria docker-compose.yml =====
mkdir -p /home/ubuntu/wordpress
cat <<EOF > /home/ubuntu/wordpress/docker-compose.yml
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: seuendpointRDS:3306
      WORDPRESS_DB_NAME: nomedobanco
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: suaSenha
    volumes:
      - /mnt/efs/html:/var/www/html
EOF

# ===== 6. Sobe o WordPress =====
cd /home/ubuntu/wordpress
docker-compose up -d >> /var/log/wordpress-docker.log 2>&1

# ===== 7. Testes básicos =====
echo "Teste EFS OK - $(date)" > /mnt/efs/teste_efs.txt
mysql -h seuendpointRDS -u admin -psuaSenha -e "SHOW DATABASES;" || echo "Falha conexão RDS"
