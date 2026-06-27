#!/bin/bash

# Obs: o script considera que o usuário está na raiz do diretório do protótipo1
SENHA='123' # Senha de usuário de exemplo. Troque pela do seu usuário do SO.

set -e

echo "Apagando o virtual environment se existir..."
rm -rf venv

echo "Começando a contagem do tempo..."
START=$(date +%s)

echo "Instalando pacotes necessários para o script..."

sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip curl default-mysql-client

# Verifica se o MySQL está acessível antes de continuar
until mysqladmin ping -h 127.0.0.1 --silent >/dev/null 2>&1; do
  sleep 1
done

echo "Criando ambiente virtual..."
python3 -m venv venv
source venv/bin/activate

echo "Configurando banco de dados..."
echo $SENHA | sudo -S mysql -u root -p < db_setup.sql

echo "Iniciando backend..."

cd backend
pip install -r requirements.txt

cd app

cat > .env <<EOF
API_KEY=test_key
STORAGE_MODE=local # "local" or "s3"
SQLALCHEMY_DATABASE_URI=mysql+mysqlconnector://admin:admin@localhost:3306/db
EOF

cd ..

python run.py &
BACKEND_PID=$!

# aguarda backend estar disponível antes de iniciar o frontend
until curl -sf http://localhost:8000/health > /dev/null
do
    sleep 1
done

cd ..

echo "Iniciando frontend..."

cd frontend
pip install -r requirements.txt

cat > .env <<EOF
FRONT_PORT=5001
BACKEND_API_BASE=http://localhost:8000
EOF

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

echo "Encerrando a contagem de tempo"

python3 -m pytest

echo "tempo_deploy=$DEPLOY_TIME" >> resultado_tempo_deploy.txt
echo "status=sucesso" >> resultado_tempo_deploy.txt
echo "---------------" >> resultado_tempo_deploy.txt

echo "Deploy concluído em $DEPLOY_TIME segundos"