#!/bin/bash

set -e

SENHA='123'
START=$(date +%s)

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

cd ..

echo "Iniciando frontend..."

cd frontend
pip install -r requirements.txt

cat > .env <<EOF
FRONT_PORT=5001
API_BASE=http://localhost:8000
EOF

python app.py &
FRONTEND_PID=$!

cd ..

echo "Aguardando aplicação..."

# checa se o frontend está disponível. O frontend depende do back e do bd no docker-compose
until curl -sf http://localhost:5001/ > /dev/null
do
    sleep 1
done

END=$(date +%s)

DEPLOY_TIME=$((END-START))

echo "tempo_deploy=$DEPLOY_TIME" >> resultado_deploy_p1.txt
echo "status=sucesso" >> resultado_deploy_p1.txt

echo "Deploy concluído em $DEPLOY_TIME segundos"