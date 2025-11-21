# SkillMate - Banco de Dados

## 🚀 Sobre o Projeto

Este repositório contém a estrutura e scripts de banco de dados do projeto **SkillMate**, um sistema de gestão de habilidades e metas de aprendizado. O projeto inclui:

- **Modelo Relacional** (Oracle Database) com DDL, DML, procedures, functions e packages
- **Modelo NoSQL** (MongoDB) com script de migração dos dados relacionais
- **Documentação** dos modelos lógico e relacional
- **Dados de exemplo** para demonstração do sistema

## 🎥 Vídeo Demonstrativo

Assista ao vídeo demonstrativo da solução: [SkillMate - Demonstração](https://youtu.be/Ohdb5ijIjsg)

## 👥 Equipe de Desenvolvimento

| Nome                        | RM      | Turma    | E-mail                 | GitHub                                         | LinkedIn                                   |
|-----------------------------|---------|----------|------------------------|------------------------------------------------|--------------------------------------------|
| Arthur Vieira Mariano       | RM554742| 2TDSPF   | arthvm@proton.me       | [@arthvm](https://github.com/arthvm)           | [arthvm](https://linkedin.com/in/arthvm/)  |
| Guilherme Henrique Maggiorini| RM554745| 2TDSPF  | guimaggiorini@gmail.com| [@guimaggiorini](https://github.com/guimaggiorini) | [guimaggiorini](https://linkedin.com/in/guimaggiorini/) |
| Ian Rossato Braga           | RM554989| 2TDSPY   | ian007953@gmail.com    | [@iannrb](https://github.com/iannrb)           | [ianrossato](https://linkedin.com/in/ianrossato/)      |

## 🛠️ Tecnologias Utilizadas

- **Oracle Database** — Banco de dados relacional
- **MongoDB** — Banco de dados NoSQL
- **SQL** — Linguagem para scripts Oracle (DDL, DML, PL/SQL)
- **JavaScript** — Scripts de migração para MongoDB
- **JSON** — Formato de dados para conversão entre modelos

## 📦 Estrutura do Projeto

```
db/
├── skillmate.sql                    # Script SQL completo (Oracle)
├── migrate_to_mongodb.js            # Script de migração para MongoDB
├── diagrams/                        # Diagramas dos modelos
│   ├── logical.jpg                  # Modelo lógico
│   ├── relational.jpg               # Modelo relacional
│   └── diagrams.pdf                 # Documentação completa
└── README.md
```

## 🗄️ Banco de Dados Relacional (Oracle)

### Estrutura das Tabelas

O banco de dados Oracle possui as seguintes tabelas principais:

- **ROLES** — Papéis profissionais (Administrador, Desenvolvedor, Designer UX/UI, Analista de Dados, etc.)
- **USERS** — Usuários do sistema com seus respectivos papéis
- **GOALS** — Metas de aprendizado dos usuários
- **WEEKLY_PLANS** — Planos semanais de estudo associados às metas
- **TASKS** — Tarefas dentro dos planos semanais
- **REFERENCES** — Referências e materiais de estudo para as tarefas
- **LOGS** — Logs de auditoria do sistema

### Componentes do Script SQL

O arquivo `skillmate.sql` contém:

1. **DDL (Data Definition Language)**
   - Criação de tabelas com constraints (PK, FK, UNIQUE, CHECK)
   - Criação de sequences
   - Criação de índices para performance

2. **DML (Data Manipulation Language)**
   - Inserção de dados iniciais
   - Dados de exemplo para todas as tabelas

3. **PL/SQL**
   - **Packages:**
     - `PKG_INSERTS` — Procedures para inserção de dados com validações
     - `PKG_FUNCTIONS` — Funções para conversão JSON e cálculos de compatibilidade
     - `PKG_EXPORT` — Exportação de dados para JSON
   - **Procedures** — Operações complexas do sistema
   - **Functions** — Funções reutilizáveis

### Executando o Script SQL

```sql
-- Conecte-se ao Oracle Database
sqlplus username/password@database

-- Execute o script
@skillmate.sql
```

## 🍃 Banco de Dados NoSQL (MongoDB)

### Estrutura das Collections

O modelo MongoDB utiliza collections com documentos embutidos para relacionamentos:

- **roles** — Papéis profissionais do sistema
- **users** — Usuários com role embutido
- **goals** — Metas de aprendizado
- **weekly_plans** — Planos semanais associados às metas
- **tasks** — Tarefas dentro dos planos semanais
- **references** — Referências e materiais de estudo
- **logs** — Logs de auditoria

### Executando a Migração para MongoDB

```bash
# Conecte-se ao MongoDB
mongo

# Execute o script de migração
mongo skillmate < migrate_to_mongodb.js
```

Ou usando o MongoDB Compass ou outra ferramenta MongoDB:

```javascript
// Execute o conteúdo do arquivo migrate_to_mongodb.js
```

## 📊 Modelos de Dados

### Modelo Relacional (Oracle)

O modelo relacional segue a terceira forma normal (3NF) e utiliza:

- **Chaves primárias (PK)** — Identificadores únicos (CUID de 24 caracteres)
- **Chaves estrangeiras (FK)** — Relacionamentos entre tabelas
- **Constraints** — Validações de integridade (UNIQUE, CHECK, NOT NULL)
- **Índices** — Otimização de consultas
- **Sequences** — Geração automática de IDs para logs
- **Packages PL/SQL** — Lógica de negócio no banco

### Modelo NoSQL (MongoDB)

O modelo NoSQL utiliza:

- **Embedded Documents** — Dados relacionados embutidos (denormalização)
- **References** — Referências quando necessário
- **Collections** — Estrutura flexível para documentos
- **Índices** — Otimização de consultas por campos específicos

### Conversão Relacional → NoSQL

O script de migração `migrate_to_mongodb.js` realiza a conversão automática dos dados relacionais para o modelo NoSQL. A conversão transforma:

- Tabelas → Collections
- Linhas → Documents
- Relacionamentos FK → Embedded Documents ou References
- Chaves primárias → Campos `_id`

## 🔄 Migração de Dados

### Oracle → MongoDB

1. **Exportar dados do Oracle:**
   ```sql
   -- Use o package pkg_export para exportar dados em JSON
   -- Execute: SELECT pkg_export.export_dataset_to_json() FROM dual;
   ```

2. **Importar no MongoDB:**
   ```bash
   # Execute o script de migração
   mongo skillmate < migrate_to_mongodb.js
   ```

3. **Verificar dados:**
   ```javascript
   use skillmate;
   db.users.count();
   db.roles.count();
   db.goals.count();
   db.tasks.count();
   db.references.count();
   db.weekly_plans.count();
   db.logs.count();
   ```

## 📚 Documentação Adicional

- **diagrams/logical.jpg** — Modelo lógico do banco de dados
- **diagrams/relational.jpg** — Modelo relacional completo com diagramas
- **diagrams/diagrams.pdf** — Documentação completa dos modelos

## 🚀 Como Usar

### Para Oracle Database

1. **Conecte-se ao Oracle:**
   ```bash
   sqlplus username/password@database
   ```

2. **Execute o script SQL:**
   ```sql
   @skillmate.sql
   ```

3. **Verifique as tabelas criadas:**
   ```sql
   SELECT table_name FROM user_tables;
   ```

### Para MongoDB

1. **Inicie o MongoDB:**
   ```bash
   mongod
   ```

2. **Execute o script de migração:**
   ```bash
   mongo skillmate < migrate_to_mongodb.js
   ```

3. **Verifique as collections:**
   ```javascript
   use skillmate;
   show collections;
   ```

## 📄 Licença

Projeto acadêmico desenvolvido para Global Solution da FIAP.
