# Vetores e Strings em C

Anotações e exercícios da disciplina de **Linguagem C**, com foco em **vetores (arrays)** e **strings**.

Cada aula é um programa completo e independente, que pode ser compilado e executado sozinho.

## Estrutura do projeto

```
Vetores e Strings/
├── Aulas/
│   ├── Aula01.c   # Declaracao, acesso e alteracao de posicoes
│   ├── Aula02.c   # Leitura de vetor com scanf em ordem inversa
│   ├── Aula03.c   # Dois vetores e calculo posicao por posicao
│   ├── Aula04.c   # Vetor passado como parametro para uma funcao
│   ├── Aula05.c   # strlen, strcpy e strcmp
│   └── Aula06.c   # fgets, remocao do '\n' com strcspn e strlen
├── Atividade/
│   └── Atv01.c    # Soma e media de dois vetores
├── bin/           # Executaveis (.exe) - nao versionados
└── .vscode/       # Configuracao de build/debug do VS Code (gcc)
```

## Conteudo das aulas

| Arquivo | Tema | O que faz |
| --- | --- | --- |
| `Aula01.c` | Vetores | Cria `int v[5]`, imprime posicoes e altera o terceiro elemento |
| `Aula02.c` | Leitura de vetor | Le 5 idades com `scanf` e imprime na ordem inversa |
| `Aula03.c` | Operacoes com vetores | Le `v1`, gera `v2` com o dobro de cada valor e mostra lado a lado |
| `Aula04.c` | Vetores + funcoes | Funcao `soma_vetor` que soma os `n` primeiros elementos |
| `Aula05.c` | Strings | Conta o tamanho, copia e compara duas strings |
| `Aula06.c` | Strings | Le um nome com `fgets` e mostra a quantidade de caracteres |
| `Atv01.c` | Atividade | Soma posicao por posicao de dois vetores e calcula as medias |

## Como compilar e executar

Com o **GCC** (MinGW no Windows) instalado:

```bash
# compilar
gcc Aulas/Aula01.c -o bin/Aula01

# executar (Windows)
bin\Aula01.exe
```

Ou no **VS Code**: abra o arquivo `.c` e pressione `F5` / `Ctrl+Shift+B`
(as tarefas em `.vscode/tasks.json` compilam o arquivo ativo com `gcc`).
