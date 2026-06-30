# Prototipo1

Este protótipo é parte de um TCC e implementa uma aplicação web de gerenciamento de arquivos multimídia (imagens, áudios e vídeos) utilizando execução tradicional sem conteinerização. Todos os componentes da aplicação são executados diretamente no sistema operacional hospedeiro. O diretório  [arquivos_exemplo](https://github.com/GabrielAlves/Prototipos/tree/main/arquivos_exemplo) contém exemplos de arquivos (<10 MB) de diversos formatos que são aceitos na aplicação (mp3, mp4, mkv, aac, png, jpeg, gif). 

O objetivo deste protótipo é servir como cenário base para comparação com as abordagens conteinerizadas dos Protótipos 2 e 3.

Observação: este repositório contém artefatos do desenvolvimento inicial do projeto que não participam da versão experimental realizada (resquícios de código). Para fins de "archive", o repositório original do Prototipo1 pode ser acessado em [MediaManager](https://github.com/GabrielAlves/MediaManager). 

![Interface de usuário da aplicação](https://raw.githubusercontent.com/GabrielAlves/Prototipos/refs/heads/main/screenshots/interface_usuario_prototipo1.png)
Figura 1. Interface de usuário da aplicação

## Funcionalidades
- Inserção de arquivos multimídia (imagem, áudio e vídeo) de até 10 MB
- Listagem dos arquivos armazenados
- Visualização e reprodução dos arquivos enviados
- Remoção de arquivos
- Persistência de metadados em banco relacional e arquivos de upload
- Testes unitários com Pytest

## Tecnologias utilizadas
- HTML, CSS e JavaScript
- Python 3.11
- Flask 3.1
- MySQL 8.0
- Pytest 9.0

## Pacotes necessários
- git
- python
- venv
- pip
- mysql

## Como configurar automaticamente

Os 2 scripts abaixo foram criados para auxiliar os avaliadores.

O `script_pacotes.sh` deve ser executado na primeira vez para instalar com o apt-get os pacotes que são utilizados pelo `script_deploy.sh`. Esses pacotes são git, python3, python3-venv, python3-pip, mysql-server-8.0, mysql-client-core-8.0, curl.

1. Execute `sudo bash script_pacotes.sh`

O `script_deploy.sh` executa automaticamente os passos de configuração descritos logo abaixo e também executa os testes unitários no final da execução.

1. Execute `sudo bash script_deploy.sh`

![Saída esperada para o arquivo de deploy](https://raw.githubusercontent.com/GabrielAlves/Prototipos/refs/heads/main/screenshots/script_deploy_executado_prototipo1.png)
Figura 2. Resultado do `script_deploy.sh`

## Como configurar manualmente

As instruções passadas nesse README pressupoem que o sistema host seja Linux (Ubuntu 24.04), mas o protótipo pode ser e já foi executado também em sistema Windows (Windows 11). Para executar em ambiente windows, é necessário adaptar os comandos descritos nas configurações abaixo, por exemplo, usar `venv\Scripts\activate` em vez de `source venv/bin/activate`, `copy` em vez de `cp`, etc. 

### Configure o banco de dados

O script `db_setup.sql` foi criado para facilitar a configuração do banco de dados. Por padrão, ele cria um banco de dados `db`, um usuário padrão `admin` e fornece privilégios para o usuário `admin`. O comando abaixo usa o usuário root para inserir os comandos desse script: 

1. Execute `mysql -u root -p < db_setup.sql`

### Configure o backend

Observação: as variáveis de ambiente essenciais foram deixadas em claro nos .env.examples para facilitar a execução, mas em sistemas reais, essas informações não podem estar em claro nesses arquivos! 

1. Clone o repositório: `git clone https://github.com/GabrielAlves/Prototipo1`
2. Entre no diretório: `cd Prototipo1`
3. Crie um ambiente virtual: `python3 -m venv venv`
4. Ative o ambiente virtual: `source venv/bin/activate` 
5. Entre no diretório backend: `cd backend`
6. Instale as dependências: `pip install -r requirements.txt`
7. Copie o arquivo env de exemplo para o diretório app: `cp .env.example app/.env`
8. Edite as variáveis do arquivo .env. É importante que SQLALCHEMY_DATABASE_URI e STORAGE_MODE sejam definidos.
9. Execute o backend: `python run.py`
9. (opcional) Cheque o backend em `http://localhost:8000/health`

### Configure o frontend

Em outro processo e na raiz do Protótipo1 (Prototipo1/)

1. Ative o ambiente virtual: `source venv/bin/activate` 
2. Entre na pasta frontend: `cd frontend`
3. Instale as dependências: `pip install -r requirements.txt`
4. Copie o arquivo env de exemplo para o mesmo diretório: `cp .env.example .env`. É importante que FRONT_PORT e BACKEND_API_BASE estejam definidos.
5. Execute o frontend: `python app.py`
6. Acesse a tela em `http://localhost:5001`

## Como executar os testes unitários diretamente

1. Entre no diretório backend: `cd backend`
2. Execute: `python -m pytest`

## Como executar os testes de tempo de deploy

1. Execute `sudo bash script_tempo.sh`

ou

1. Execute `sudo bash executar_varios_script_tempo.sh` (default: 10 execuções. O número pode ser modificado no for do script `executar_varios_script_tempo.sh`)

## Resultados de tempo de deploy

Os resultados se encontram em `resultado_tempo_deploy.txt`. O arquivo usado para calcular as médias e desvio padrões pode ser acessado [aqui](https://github.com/GabrielAlves/Prototipos/blob/main/desvio_padrao.py).
