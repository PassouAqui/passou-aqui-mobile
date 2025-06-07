# Passou Aqui

Aplicativo móvel para gerenciamento de estoque e controle de produtos.

## Equipe de Desenvolvimento

### Integrantes
- Adler Castro
- Carlos Eduardo
- Gabriel Linard
- Guilherme Assis
- João Paulo de Sá
- Matheus Reis

### Informações Acadêmicas
- Curso: Engenharia de Software
- Instituição: ICEV
- Turma: 5º Período Alpha

## Requisitos do Sistema

### Para o Backend (API)
- Python 3.8 ou superior
- pip (gerenciador de pacotes Python)
- Virtualenv (recomendado)
- PostgreSQL (banco de dados)

### Para o App Mobile
- Flutter SDK (versão mais recente estável)
- Android Studio ou VS Code com extensões Flutter
- Git
- JDK 11 ou superior (para desenvolvimento Android)
- Xcode (para desenvolvimento iOS, apenas em macOS)

## Configuração do Ambiente

### 1. Backend (API)

1. Clone o repositório da API:
```bash
git clone https://github.com/PassouAqui/passou-aqui-api
cd passou-aqui-api
```

2. Crie e ative um ambiente virtual:
```bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# Linux/macOS
python3 -m venv venv
source venv/bin/activate
```

3. Instale as dependências:
```bash
pip install -r requirements.txt
```

4. Configure o banco de dados:
- Crie um banco de dados PostgreSQL
- Configure as variáveis de ambiente no arquivo `.env` (se necessário)
- Execute as migrações:
```bash
python manage.py migrate
```

5. Inicie o servidor de desenvolvimento:
```bash
python manage.py runserver
```

A API estará disponível em `http://localhost:8000`

#### Variáveis de Ambiente do Backend

Crie um arquivo `.env` na raiz do projeto da API (`passou-aqui-api/`) com as seguintes variáveis:

```env
# Configurações do Banco de Dados PostgreSQL
POSTGRES_DB=passouaqui        # Nome do banco de dados
POSTGRES_USER=postgres        # Usuário do banco de dados
POSTGRES_PASSWORD=admin123    # Senha do banco de dados
POSTGRES_HOST=localhost       # Host do banco de dados
POSTGRES_PORT=5432           # Porta do banco de dados

### 2. App Mobile

1. Clone o repositório do app:
```bash
git clone https://github.com/PassouAqui/passou-aqui-mobile
cd passou-aqui-mobile
```

2. Instale as dependências do Flutter:
```bash
flutter pub get
```

3. Configure o ambiente:
- Certifique-se de que o Flutter está configurado corretamente:
```bash
flutter doctor
```
- Resolva quaisquer problemas indicados pelo `flutter doctor`

4. Configure o arquivo de ambiente:
- Copie o arquivo `.env.example` para `.env` (se existir)
- Configure as variáveis de ambiente necessárias

5. Execute o app:
```bash
# Para desenvolvimento
flutter run

# Para gerar APK de release
flutter build apk --release
```

## Estrutura do Projeto

### Backend (API)
- `accounts/`: Gerenciamento de usuários e autenticação
- `inventory/`: Lógica de negócios do inventário
- `MediTrack/`: Configurações principais do projeto Django

### App Mobile
- `lib/`: Código fonte do aplicativo
  - `core/`: Componentes e utilitários base
  - `features/`: Funcionalidades do app
  - `shared/`: Componentes compartilhados
- `assets/`: Recursos estáticos (imagens, fontes, etc.)
- `test/`: Testes automatizados
