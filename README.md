# FitManager

##  descrição

Um aplicativo móvel desenvolvido em Flutter para gerenciamento de estúdios de personal training ou academias. O objetivo é facilitar a administração de alunos, treinos e o acompanhamento por parte dos professores e da empresa.

**Status do Projeto:** Em desenvolvimento e refatoração para uma arquitetura limpa.

---

## Funcionalidades Implementadas/Planejadas

* **Gerenciamento de Empresa:**
    * Cadastro de novas empresas (estúdios/academias).
    * Login para empresas.
* **Gerenciamento de Professor:**
    * Cadastro de professores vinculados a uma empresa.
    * Login para professores.
    * Listagem de professores.
* **Gerenciamento de Aluno:**
    * Cadastro de alunos vinculados a uma empresa.
    * Listagem de alunos da empresa.
    * Seleção de alunos para visualização de detalhes e treinos.
* **Gerenciamento de Treinos:**
    * Visualização de treinos agrupados (ex: A, B, C).
    * Atribuição de treinos a alunos (funcionalidade em desenvolvimento/refatoração).
    * Edição de detalhes do treino (séries, repetições, grupo).

---

## Tecnologias Utilizadas

* **Flutter & Dart:** Para o desenvolvimento multiplataforma do aplicativo.
* **Arquitetura Limpa (Clean Architecture):** Em processo de implementação para melhor organização, testabilidade e manutenibilidade do código. A estrutura visa separar as responsabilidades em camadas:
    * `app`: Configurações globais, tema, widgets reutilizáveis.
    * `core`: Lógica de negócios central, utilitários, constantes e serviços de base.
    * `features`: Módulos funcionais da aplicação (ex: autenticação, aluno, treino), cada um com suas camadas de `data`, `domain` e `presentation`.
* **Gerenciamento de Estado:** (A definir - ex: Cubit/BLoC, Provider, Riverpod). Atualmente, algumas lógicas estão em controllers simples ou diretamente nos widgets, sendo refatoradas.
* **Comunicação com API:**
    * `http`: Pacote para realizar chamadas HTTP para o backend.
    * Consumo de uma API REST para todas as operações de dados.
* **Armazenamento Seguro:**
    * `flutter_secure_storage`: Para armazenar dados sensíveis como tokens de autenticação e IDs de sessão.
* **Padronização de UI:**
    * Tema centralizado (`AppTheme`) para cores, fontes e estilos de widgets.
    * Widgets customizados reutilizáveis (ex: `PrimaryButton`).

---

## Configuração e Execução do Projeto

### Pré-requisitos

* Flutter SDK (Versão 3.x.x ou superior recomendada)
* Um emulador Android/iOS configurado ou um dispositivo físico.
* Acesso à API de backend. A URL base da API utilizada durante o desenvolvimento é: `https://8963-2804-984-863-4d00-682e-2911-2ebb-81cb.ngrok-free.app`. Certifique-se de que esta API esteja acessível ou substitua pela URL do seu ambiente.

### Passos para Rodar

1.  **Clone o repositório (se aplicável):**
    ```bash
    git clone <url-do-seu-repositorio>
    cd <nome-da-pasta-do-projeto>
    ```

2.  **Instale as dependências:**
    Abra o terminal na raiz do projeto e execute:
    ```bash
    flutter pub get
    ```

3.  **Verifique a URL da API:**
    A URL da API está configurada nos arquivos de serviço (ex: `lib/services/api_service.dart` ou, após refatoração, em `lib/core/constants/api_constants.dart`).
    Se necessário, atualize-a para apontar para o seu ambiente de backend.

4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```
    Selecione o dispositivo desejado quando solicitado.

---

## Estrutura do Projeto (Pós-Refatoração)

O projeto está sendo organizado seguindo os princípios da Arquitetura Limpa, dividindo o código em três áreas principais na pasta `lib/`:

* **`app/`**: Contém configurações globais da aplicação, como temas (`app/theme/`), widgets reutilizáveis em todo o app (`app/widgets/`) e configuração de navegação.
* **`core/`**: Inclui a lógica de negócios que é central para a aplicação, mas não específica de uma feature. Isso pode incluir utilitários (`core/utils/`), constantes (`core/constants/`), definições de erros (`core/errors/`), e serviços base como clientes HTTP ou wrappers de storage (`core/services/`).
* **`features/`**: É onde cada funcionalidade principal do aplicativo reside como um módulo independente. Exemplos incluem `auth` (autenticação), `aluno`, `professor`, `treino`. Cada feature é subdividida em:
    * **`data/`**: Responsável pela implementação da obtenção de dados. Contém `models/` (objetos de transferência de dados, DTOs), `datasources/` (classes que interagem com APIs externas ou bancos de dados locais) e `repositories/` (implementações dos contratos definidos no domínio).
    * **`domain/`**: O coração da feature, contendo a lógica de negócios pura. Inclui `entities/` (objetos de negócio), `repositories/` (contratos/interfaces para os repositórios de dados) e `usecases/` (casos de uso específicos da feature).
    * **`presentation/`**: Responsável pela UI e pela lógica de apresentação. Contém `screens/` (as telas da feature), `widgets/` (widgets específicos da feature) e `manager/` (gerenciadores de estado como Cubits, Providers ou BLoCs).

---