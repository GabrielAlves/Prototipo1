#!/bin/bash

set -e

echo "apagando processos usando as portas do backend e frontend"

sudo fuser -k 8000/tcp || true
sudo fuser -k 5001/tcp || true

echo "apagando o bd e o usuário se existirem"

sudo mysql -u root -p -e "DROP DATABASE IF EXISTS db;DROP USER IF EXISTS 'admin'@'localhost';"

echo "Apagando o virtual environment se existir..."
rm -rf venv

echo "Começando a contagem do tempo..."
START=$(date +%s)

echo "Criando ambiente virtual..."
python3 -m venv venv
source venv/bin/activate

echo "Configurando banco de dados..."
sudo mysql -u root -p < db_setup.sql

echo "Instalando requirements do backend..."

cd backend
pip install -r requirements.txt

cd app

echo "Setando env vars do backend..."

cat > .env <<EOF
API_KEY=test_key
STORAGE_MODE=local # "local" or "s3"
SQLALCHEMY_DATABASE_URI=mysql+mysqlconnector://admin:admin@localhost:3306/db
EOF

cd ..

echo "Ligando o backend..."

python run.py &
BACKEND_PID=$!

# aguarda backend estar disponível antes de iniciar o frontend
until curl -sf http://localhost:8000/health > /dev/null
do
    sleep 1
done

cd ..

echo "Instalando requirements do frontend..."

cd frontend
pip install -r requirements.txt

echo "Setando env vars do frontend..."

cat > .env <<EOF
FRONT_PORT=5001
BACKEND_API_BASE=http://localhost:8000
EOF

echo "Ligando o frontend..."

python app.py &
FRONTEND_PID=$!

cd ..

echo "Aguardando aplicação..."

# checa se o frontend está disponível.
until curl -sf http://localhost:5001/ > /dev/null
do
    sleep 1
done

END=$(date +%s)

DEPLOY_TIME=$((END-START))

echo "tempo_deploy=$DEPLOY_TIME" >> resultado_tempo_deploy.txt
echo "status=sucesso" >> resultado_tempo_deploy.txt
echo "---------------" >> resultado_tempo_deploy.txt

echo "Deploy concluído em $DEPLOY_TIME segundos"