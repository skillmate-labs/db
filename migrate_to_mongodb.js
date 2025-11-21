// Arthur Vieira Mariano - RM554742
// Guilherme Henrique Maggiorini - RM554745
// Ian Rossato Braga - RM554989

use skillmate;

db.users.drop();
db.roles.drop();
db.goals.drop();
db.logs.drop();

db.roles.insertMany([
  { _id: 'jziszucfubmtdtklaifabh1n', name: 'Administrador', acronym: 'ADM', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'd8hyks8giczejw47xqikaci0', name: 'Desenvolvedor', acronym: 'DEV', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'dix5up9nyphadam3dbymgfjy', name: 'Designer UX/UI', acronym: 'DSG', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'ynlcjadhg5u587t6s7fmxg00', name: 'Analista de Dados', acronym: 'ANL', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'r6wghro1v874pdu4l16b850v', name: 'Gerente de Projetos', acronym: 'GPR', createdAt: new Date(), migratedAt: new Date() },
  { _id: '83z3maofj7jrrr814rznbd13', name: 'Especialista em IA', acronym: 'IA', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'ycnvcqmqzmats3746gl7vswf', name: 'Product Manager', acronym: 'PM', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'jwo98rpx5dpor1w9kjbal5v1', name: 'DevOps Engineer', acronym: 'DOE', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'yblwvn88y2vb81evpp89vt3h', name: 'Cybersecurity', acronym: 'CS', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'qm76nh78x0vu5owu6appt0v0', name: 'Cloud Architect', acronym: 'CA', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'z996op8eojs9v66mtgv3g0gm', name: 'Scrum Master', acronym: 'SM', createdAt: new Date(), migratedAt: new Date() },
  { _id: 'qnoejo7fm722x5cc9euqks6p', name: 'Data Scientist', acronym: 'DS', createdAt: new Date(), migratedAt: new Date() }
]);

db.users.insertMany([
  {
    _id: 'hbizq1cfnoby46k0gl2j19os',
    name: 'Ana Silva',
    email: 'ana.silva@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'jziszucfubmtdtklaifabh1n',
      name: 'Administrador',
      acronym: 'ADM'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: 'lfjqjd1xpx40f9lzl3rr1n3f',
    name: 'Carlos Mendes',
    email: 'carlos.mendes@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'd8hyks8giczejw47xqikaci0',
      name: 'Desenvolvedor',
      acronym: 'DEV'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: 'qmzbsl7thsgz4332c5oa5wps',
    name: 'Mariana Costa',
    email: 'mariana.costa@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'dix5up9nyphadam3dbymgfjy',
      name: 'Designer UX/UI',
      acronym: 'DSG'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: 'fj0tniy2r9s1pygwgaqa3fro',
    name: 'João Santos',
    email: 'joao.santos@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'ynlcjadhg5u587t6s7fmxg00',
      name: 'Analista de Dados',
      acronym: 'ANL'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: 'z5sxaiywvqv5tvlysyrjsaoj',
    name: 'Fernanda Lima',
    email: 'fernanda.lima@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'r6wghro1v874pdu4l16b850v',
      name: 'Gerente de Projetos',
      acronym: 'GPR'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: '65ay1765eignqmodpdx9kslz',
    name: 'Ricardo Alves',
    email: 'ricardo.alves@skillmate.com',
    password: 'pass123',
    role: {
      _id: '83z3maofj7jrrr814rznbd13',
      name: 'Especialista em IA',
      acronym: 'IA'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: 'z8klf5xw0sm2fus0z2ja8028',
    name: 'Juliana Rocha',
    email: 'juliana.rocha@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'ycnvcqmqzmats3746gl7vswf',
      name: 'Product Manager',
      acronym: 'PM'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: '1fi3sz8v3la72ts51tfw763f',
    name: 'Pedro Oliveira',
    email: 'pedro.oliveira@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'jwo98rpx5dpor1w9kjbal5v1',
      name: 'DevOps Engineer',
      acronym: 'DOE'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: '579jidxqeteyvviu3mz8eawr',
    name: 'Larissa Ferreira',
    email: 'larissa.ferreira@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'yblwvn88y2vb81evpp89vt3h',
      name: 'Cybersecurity',
      acronym: 'CS'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: 'lpx5wvdxdic13wc74fwof1pv',
    name: 'Bruno Souza',
    email: 'bruno.souza@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'qm76nh78x0vu5owu6appt0v0',
      name: 'Cloud Architect',
      acronym: 'CA'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: '65vc7pwhnxe5y1dh1gpohlry',
    name: 'Camila Martins',
    email: 'camila.martins@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'z996op8eojs9v66mtgv3g0gm',
      name: 'Scrum Master',
      acronym: 'SM'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  },
  {
    _id: 'smnk1cchli7ubz4q6hwrngev',
    name: 'Gabriel Pereira',
    email: 'gabriel.pereira@skillmate.com',
    password: 'pass123',
    role: {
      _id: 'qnoejo7fm722x5cc9euqks6p',
      name: 'Data Scientist',
      acronym: 'DS'
    },
    createdAt: new Date(),
    migratedAt: new Date()
  }
]);

db.goals.insertMany([
  {
    _id: 'lc3nc7joi8myryoy6cpzq8xy',
    title: 'Dominar Machine Learning e Deep Learning para aplicações empresariais',
    experience: 'Tenho experiência básica em Python e estatística. Trabalho com análise de dados há 2 anos e quero migrar para área de IA. Preciso aprender frameworks como TensorFlow, PyTorch e entender modelos de redes neurais.',
    hours_per_day: 4,
    days_per_week: 5,
    user: {
      _id: 'fj0tniy2r9s1pygwgaqa3fro',
      name: 'João Santos',
      email: 'joao.santos@skillmate.com'
    },
    weekly_plans: [
      {
        _id: 'sfj14j8twfwslzk6yvrpyn6m',
        week_start: ISODate('2024-01-01T00:00:00Z'),
        week_end: ISODate('2024-01-07T23:59:59Z'),
        weeks_to_complete: 12,
        ai_prompt: 'Criar plano de aprendizado semanal para Machine Learning',
        ai_response: 'Plano focado em fundamentos de ML.',
        tasks: [
          {
            _id: 'uslce5wybopxe48q0dpoi19s',
            title: 'Assistir curso introdutório de Machine Learning',
            completed: false,
            difficulty: 0,
            difficulty_name: 'Easy',
            references: [
              {
                name: 'Coursera - Machine Learning',
                description: 'Curso completo de ML',
                link: 'https://www.coursera.org/learn/machine-learning'
              }
            ]
          },
          {
            _id: 'iobbbwo9evmr7fcwwcpb1kex',
            title: 'Instalar e configurar ambiente Python',
            completed: true,
            difficulty: 0,
            difficulty_name: 'Easy',
            references: [
              {
                name: 'Python.org Tutorial',
                description: 'Tutorial oficial do Python',
                link: 'https://docs.python.org/3/tutorial/'
              }
            ]
          },
          {
            _id: 'toh04j937nefsbyfa1ec9adn',
            title: 'Estudar conceitos de regressão linear e classificação',
            completed: false,
            difficulty: 1,
            difficulty_name: 'Normal',
            references: [
              {
                name: 'Scikit-learn Documentation',
                description: 'Documentação oficial do Scikit-learn',
                link: 'https://scikit-learn.org/stable/'
              }
            ]
          }
        ]
      },
      {
        _id: 'ep6x56nes7x5hsdlmdh3tvb5',
        week_start: ISODate('2024-01-08T00:00:00Z'),
        week_end: ISODate('2024-01-14T23:59:59Z'),
        weeks_to_complete: 12,
        ai_prompt: 'Aprofundar em Deep Learning',
        ai_response: 'Estudar redes neurais e TensorFlow.',
        tasks: [
          {
            _id: 'g4p9cdg13j265o2b8rxpg02w',
            title: 'Implementar primeira rede neural com TensorFlow',
            completed: false,
            difficulty: 2,
            difficulty_name: 'Hard',
            references: [
              {
                name: 'TensorFlow Tutorials',
                description: 'Tutoriais oficiais do TensorFlow',
                link: 'https://www.tensorflow.org/tutorials'
              }
            ]
          },
          {
            _id: '4td1lha0jx07mfv0w6copqh8',
            title: 'Estudar arquiteturas de redes neurais convolucionais',
            completed: false,
            difficulty: 1,
            difficulty_name: 'Normal',
            references: [
              {
                name: 'Deep Learning Book',
                description: 'Livro sobre Deep Learning',
                link: 'https://www.deeplearningbook.org/'
              }
            ]
          }
        ]
      }
    ],
    created_at: new Date('2024-01-01'),
    migratedAt: new Date()
  },
  {
    _id: 'nc6vswk3ogx49mwthkjsoie2',
    title: 'Tornar-se Cloud Architect certificado em AWS e Azure',
    experience: 'Sou desenvolvedor backend com 5 anos de experiência. Já trabalho com Docker e Kubernetes, mas preciso dominar arquiteturas cloud nativas, serverless e multi-cloud. Objetivo é obter certificações AWS Solutions Architect e Azure Architect.',
    hours_per_day: 3,
    days_per_week: 6,
    user: {
      _id: 'lfjqjd1xpx40f9lzl3rr1n3f',
      name: 'Carlos Mendes',
      email: 'carlos.mendes@skillmate.com'
    },
    weekly_plans: [
      {
        _id: 'tqhoucoxvgo0fmxedjoshnhb',
        week_start: ISODate('2024-01-15T00:00:00Z'),
        week_end: ISODate('2024-01-21T23:59:59Z'),
        weeks_to_complete: 16,
        ai_prompt: 'Plano de estudos AWS',
        ai_response: 'Cobrir serviços fundamentais da AWS.',
        tasks: [
          {
            _id: 'i2rg069bos1nlhsc6s3iun1v',
            title: 'Configurar conta AWS e explorar console',
            completed: true,
            difficulty: 0,
            difficulty_name: 'Easy',
            references: [
              {
                name: 'AWS Getting Started Guide',
                description: 'Guia de início rápido da AWS',
                link: 'https://aws.amazon.com/getting-started/'
              }
            ]
          },
          {
            _id: 'nz3wg9udmv7cea1ygrkymd3t',
            title: 'Criar primeira instância EC2 e configurar segurança',
            completed: false,
            difficulty: 1,
            difficulty_name: 'Normal',
            references: [
              {
                name: 'AWS EC2 Documentation',
                description: 'Documentação do Amazon EC2',
                link: 'https://docs.aws.amazon.com/ec2/'
              }
            ]
          }
        ]
      },
      {
        _id: 'zzji97ix5ebp811debvn40pq',
        week_start: ISODate('2024-01-22T00:00:00Z'),
        week_end: ISODate('2024-01-28T23:59:59Z'),
        weeks_to_complete: 16,
        ai_prompt: 'Arquitetura Azure e Multi-Cloud',
        ai_response: 'Estudar serviços Azure e estratégias multi-cloud.',
        tasks: [
          {
            _id: 'p6w948twsl276ue1eypqhj1d',
            title: 'Estudar serviços fundamentais do Azure',
            completed: false,
            difficulty: 1,
            difficulty_name: 'Normal',
            references: [
              {
                name: 'Microsoft Azure Learn',
                description: 'Plataforma de aprendizado do Azure',
                link: 'https://learn.microsoft.com/azure/'
              }
            ]
          }
        ]
      }
    ],
    created_at: new Date('2024-01-15'),
    migratedAt: new Date()
  },
  {
    _id: 'jbh3e2kzez8uttixeatqbbid',
    title: 'Especializar-se em Design Thinking e prototipação avançada',
    experience: 'Designer gráfico há 3 anos, migrando para UX/UI. Preciso aprender metodologias de pesquisa com usuários, criação de personas, wireframes, prototipação em Figma e testes de usabilidade. Foco em produtos SaaS e mobile.',
    hours_per_day: 5,
    days_per_week: 4,
    user: {
      _id: 'qmzbsl7thsgz4332c5oa5wps',
      name: 'Mariana Costa',
      email: 'mariana.costa@skillmate.com'
    },
    weekly_plans: [
      {
        _id: 'mvm19i6ifqwt9wlqkpfedpih',
        week_start: ISODate('2024-02-01T00:00:00Z'),
        week_end: ISODate('2024-02-07T23:59:59Z'),
        weeks_to_complete: 8,
        ai_prompt: 'Fundamentos de Design Thinking',
        ai_response: 'Aprender metodologias de pesquisa com usuários.',
        tasks: [
          {
            _id: '9e77qve2vqwb8e04609au6pk',
            title: 'Aprender técnicas de entrevista com usuários',
            completed: false,
            difficulty: 1,
            difficulty_name: 'Normal',
            references: [
              {
                name: 'IDEO Design Thinking Toolkit',
                description: 'Kit de ferramentas de Design Thinking',
                link: 'https://www.ideou.com/pages/design-thinking'
              }
            ]
          },
          {
            _id: 'g0eumvwoat7luypd2p95y5va',
            title: 'Criar personas e mapas de empatia',
            completed: false,
            difficulty: 0,
            difficulty_name: 'Easy',
            references: [
              {
                name: 'Figma Design System',
                description: 'Guia de sistemas de design no Figma',
                link: 'https://www.figma.com/design-systems/'
              }
            ]
          }
        ]
      }
    ],
    created_at: new Date('2024-02-01'),
    migratedAt: new Date()
  },
  {
    _id: 'nyi5h2qxdeowoutt5wps64gl',
    title: 'Dominar análise preditiva e visualização de dados avançada',
    experience: 'Analista de dados júnior, conheço SQL e Excel avançado. Quero evoluir para Data Scientist, aprendendo Python para análise, bibliotecas como Pandas e Scikit-learn, e ferramentas como Tableau e Power BI para dashboards executivos.',
    hours_per_day: 4,
    days_per_week: 5,
    user: {
      _id: 'fj0tniy2r9s1pygwgaqa3fro',
      name: 'João Santos',
      email: 'joao.santos@skillmate.com'
    },
    weekly_plans: [
      {
        _id: 'kqefjdku5tqxrlomv2piu8n8',
        week_start: ISODate('2024-02-08T00:00:00Z'),
        week_end: ISODate('2024-02-14T23:59:59Z'),
        weeks_to_complete: 10,
        ai_prompt: 'Python para Análise de Dados',
        ai_response: 'Dominar Pandas e Scikit-learn para análise preditiva.',
        tasks: [
          {
            _id: 'ppr1fhnf5cr3g1hwatmt2g8z',
            title: 'Dominar manipulação de dados com Pandas',
            completed: false,
            difficulty: 1,
            difficulty_name: 'Normal',
            references: [
              {
                name: 'Pandas Documentation',
                description: 'Documentação oficial do Pandas',
                link: 'https://pandas.pydata.org/docs/'
              }
            ]
          },
          {
            _id: 'f86j1alvfwms2au6wpe0px02',
            title: 'Implementar modelo preditivo com Scikit-learn',
            completed: false,
            difficulty: 2,
            difficulty_name: 'Hard',
            references: [
              {
                name: 'Scikit-learn User Guide',
                description: 'Guia do usuário do Scikit-learn',
                link: 'https://scikit-learn.org/stable/user_guide.html'
              }
            ]
          }
        ]
      }
    ],
    created_at: new Date('2024-02-08'),
    migratedAt: new Date()
  }
]);

db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ 'role.acronym': 1 });
db.users.createIndex({ name: 1 });

db.roles.createIndex({ acronym: 1 }, { unique: true });
db.roles.createIndex({ name: 1 });

db.goals.createIndex({ 'user._id': 1 });
db.goals.createIndex({ created_at: -1 });
db.goals.createIndex({ title: 'text', experience: 'text' });
db.goals.createIndex({ hours_per_day: 1, days_per_week: 1 });

db.logs.createIndex({ datetime: -1 });
db.logs.createIndex({ table_name: 1, datetime: -1 });
db.logs.createIndex({ username: 1, datetime: -1 });
db.logs.createIndex({ operation: 1 });
