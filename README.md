# Passou Aqui Mobile

Aplicativo móvel para gerenciamento de medicamentos e farmácias, desenvolvido em Flutter com arquitetura limpa e boas práticas de desenvolvimento.

## 📱 Visão Geral

O Passou Aqui Mobile é um aplicativo que permite aos usuários:
- Gerenciar seu perfil
- Visualizar e buscar medicamentos
- Gerenciar carrinho de compras
- Autenticação segura
- Atualização automática de tokens
- Interface moderna e responsiva

## 🏗️ Arquitetura

O projeto segue a arquitetura limpa (Clean Architecture) com os seguintes níveis:

### 1. Presentation Layer
- **Pages**: Telas da aplicação
- **Widgets**: Componentes reutilizáveis
- **Providers**: Gerenciamento de estado
- **Blocs**: Gerenciamento de eventos (em alguns casos)

### 2. Domain Layer
- **Entities**: Modelos de domínio
- **Repositories**: Interfaces para acesso a dados
- **Use Cases**: Lógica de negócio

### 3. Data Layer
- **Repositories**: Implementações concretas
- **Data Sources**: Fontes de dados (API, local storage)
- **Services**: Serviços de API
- **Models**: DTOs e modelos de dados

## 🎯 Componentes Principais

### Componentes Reutilizáveis

#### 1. AppScaffold
```dart
AppScaffold(
  title: 'Título da Página',
  showBackButton: true,
  showProfileButton: true,
  showLogoutButton: true,
  actions: [/* ações customizadas */],
  body: /* conteúdo da página */,
)
```
- Scaffold padrão com AppBar consistente
- Botões de perfil e logout
- Navegação integrada
- Gerenciamento de autenticação

#### 2. InfoCard
```dart
InfoCard(
  title: 'Título',
  content: 'Conteúdo',
  icon: Icons.info,
  onTap: () => /* ação */,
)
```
- Card informativo reutilizável
- Suporte a ícones
- Estilização customizável
- Gestos de toque

#### 3. LoadingErrorState
```dart
LoadingErrorState(
  isLoading: true,
  error: 'Mensagem de erro',
  onRetry: () => /* ação de retry */,
  child: /* conteúdo principal */,
)
```
- Gerenciamento de estados de carregamento
- Tratamento de erros
- Botão de retry
- Customização de widgets

### Gerenciamento de Estado

#### 1. AuthProvider
- Gerenciamento de autenticação
- Login/Logout
- Verificação de token
- Refresh automático

#### 2. ProfileProvider
- Gerenciamento de perfil
- Carregamento de dados
- Atualização de informações
- Tratamento de erros

#### 3. DrugProvider
- Listagem de medicamentos
- Paginação
- Refresh de dados
- Cache local

## 🔄 Fluxo de Dados

### Autenticação
1. Usuário faz login
2. Token é armazenado de forma segura
3. Token é automaticamente incluído em requisições
4. Refresh automático quando expirado

### Perfil
1. Dados carregados ao acessar a página
2. Cache local para performance
3. Atualização manual via pull-to-refresh
4. Tratamento de erros e estados de loading

### Medicamentos
1. Listagem paginada
2. Cache para performance
3. Pull-to-refresh para atualização
4. Tratamento de erros de rede

## 🔒 Segurança

### Armazenamento Seguro
- Tokens armazenados em `FlutterSecureStorage`
- Refresh automático de tokens
- Limpeza de dados ao logout

### API
- Interceptors para autenticação
- Tratamento de erros 401
- Refresh automático de token
- Headers seguros

## 📦 Estrutura de Diretórios

```
lib/
├── config/           # Configurações (env, constants)
├── data/            # Camada de dados
│   ├── datasources/ # Fontes de dados
│   ├── models/      # DTOs
│   ├── repositories/# Implementações de repositórios
│   └── services/    # Serviços de API
├── domain/          # Camada de domínio
│   ├── entities/    # Modelos de domínio
│   ├── repositories/# Interfaces de repositórios
│   └── usecases/    # Casos de uso
├── presentation/    # Camada de apresentação
│   ├── blocs/       # Gerenciamento de estado (BLoC)
│   ├── pages/       # Telas
│   ├── providers/   # Gerenciamento de estado (Provider)
│   └── widgets/     # Componentes reutilizáveis
└── di.dart          # Injeção de dependências
```

## 🚀 Como Usar

### Configuração
1. Clone o repositório
2. Instale as dependências: `flutter pub get`
3. Configure as variáveis de ambiente em `lib/config/env.dart`
4. Execute o app: `flutter run`

### Desenvolvimento
1. Crie novas páginas em `lib/presentation/pages`
2. Adicione componentes reutilizáveis em `lib/presentation/widgets`
3. Implemente lógica de negócio em `lib/domain/usecases`
4. Adicione serviços de API em `lib/data/services`

### Boas Práticas
1. Use os componentes reutilizáveis quando possível
2. Siga o padrão de arquitetura limpa
3. Mantenha a tipagem forte
4. Documente código complexo
5. Use providers para gerenciamento de estado
6. Implemente tratamento de erros adequado

## 🔄 Ciclo de Vida das Páginas

### ProfilePage
1. Inicialização
   - Verifica autenticação
   - Carrega dados do perfil
2. Estados
   - Loading: Exibe indicador de carregamento
   - Error: Exibe mensagem de erro com botão de retry
   - Success: Exibe dados do perfil
3. Atualização
   - Pull-to-refresh
   - Botão de refresh na AppBar

### DrugsPage
1. Inicialização
   - Carrega lista inicial de medicamentos
2. Estados
   - Loading: Exibe indicador de carregamento
   - Error: Exibe mensagem de erro com botão de retry
   - Success: Exibe lista de medicamentos
3. Paginação
   - Carregamento automático ao rolar
   - Cache de dados
   - Refresh manual

## 🛠️ Tecnologias Principais

- Flutter
- Provider (Gerenciamento de estado)
- Dio (Cliente HTTP)
- Flutter Secure Storage
- BLoC (Em alguns casos)

## 📚 Documentação Adicional

Para mais detalhes sobre:
- Arquitetura: Veja os comentários no código
- Componentes: Consulte a documentação inline
- API: Verifique a documentação da API
- Estado: Analise os providers e blocs
