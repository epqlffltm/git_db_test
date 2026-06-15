#!/bin/bash
set -e

echo "==============================="
echo "  자동 설치 스크립트 시작"
echo "==============================="

# 1. 패키지 업데이트
echo "[1/7] 패키지 업데이트..."
sudo apt update -y

# 2. Apache + PHP 설치
echo "[2/7] Apache + PHP 설치..."
sudo apt install -y apache2 php php-mysql

# 3. MariaDB 설치
echo "[3/7] MariaDB 설치..."
sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# 4. Python 환경 설치
echo "[4/7] Python 환경 설치..."
sudo apt install -y python3 python3-venv python3.14-venv

# 5. DB 생성 및 복원
echo "[5/7] DB 생성 및 복원..."
sudo mariadb -e "CREATE DATABASE IF NOT EXISTS zerodb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mariadb -e "CREATE USER IF NOT EXISTS 'zerouser'@'localhost' IDENTIFIED BY 'zeropass123!';"
sudo mariadb -e "GRANT ALL PRIVILEGES ON zerodb.* TO 'zerouser'@'localhost';"
sudo mariadb -e "FLUSH PRIVILEGES;"
sudo mariadb zerodb < zerodb_backup.sql
echo "DB 복원 완료!"

# 6. 프론트엔드 배포
echo "[6/7] 프론트엔드 배포..."
sudo cp frontend/* /var/www/html/
sudo systemctl restart apache2

# 7. FastAPI 설치 및 서비스 등록
echo "[7/7] FastAPI 설치 및 서비스 등록..."
mkdir -p ~/fastapi_app
cp backend/main.py ~/fastapi_app/
cd ~/fastapi_app
python3 -m venv venv
source venv/bin/activate
pip install "fastapi[standard]" pymysql

sudo tee /etc/systemd/system/fastapi.service > /dev/null <<EOF
[Unit]
Description=FastAPI Server
After=network.target mariadb.service

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/fastapi_app
ExecStart=/home/ubuntu/fastapi_app/venv/bin/fastapi run main.py --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl start fastapi

echo "==============================="
echo "  설치 완료!"
echo "  브라우저에서 접속하세요:"
curl -s ifconfig.me | xargs -I{} echo "  http://{}/"
echo "==============================="
