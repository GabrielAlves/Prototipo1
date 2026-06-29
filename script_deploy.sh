#!/bin/bash

set -e

# Verifica se o MySQL está acessível antes de continuar
until mysqladmin ping -h 127.0.0.1 --silent >/dev/null 2>&1; do
  sleep 1
done

echo "Criando ambiente virtual..."
python3 -m venv venv
source venv/bin/activate

echo "Configurando banco de dados..."
sudo mysql -u root -p < db_setup.sql

cd backend
pip install -r requirements.txt

cd app

cat > .env <<EOF
API_KEY=test_key
STORAGE_MODE=local # "local" or "s3"
SQLALCHEMY_DATABASE_URI=mysql+mysqlconnector://admin:admin@localhost:3306/db
EOF

cd ..

echo "Iniciando backend..."

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

cd backend

python -m pytest --disable-warnings

echo "Tela da aplicação: http://127.0.0.1:5001"
echo "Status do backend: http://127.0.0.1:8000/health"