<div align="center">

```
 ██╗   ██╗███████╗████████╗ ██████╗ ██████╗ ███████╗███████╗
 ██║   ██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝██╔════╝
 ██║   ██║█████╗     ██║   ██║   ██║██████╔╝█████╗  ███████╗
 ╚██╗ ██╔╝██╔══╝     ██║   ██║   ██║██╔══██╗██╔══╝  ╚════██║
  ╚████╔╝ ███████╗   ██║   ╚██████╔╝██║  ██║███████╗███████║
   ╚═══╝  ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝
                        &  S T R I N G S
```

### `char *tema = "vetores e strings";`

Anotações e exercícios de **Linguagem C** — arrays, strings e a base de tudo que vem depois.

![Linguagem](https://img.shields.io/badge/C-00599C?style=for-the-badge&logo=c&logoColor=white)
![Compilador](https://img.shields.io/badge/GCC-MinGW-7A0099?style=for-the-badge&logo=gnu&logoColor=white)
![Editor](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white)
![Status](https://img.shields.io/badge/status-em_andamento-2ea44f?style=for-the-badge)

</div>

---

## 📂 `tree -L 2`

```bash
Vetores e Strings/
├── Aulas/                # 6 aulas, um programa independente cada
│   ├── Aula01.c          #  array: leitura, escrita e mutação
│   ├── Aula02.c          #  scanf em laço + saída invertida
│   ├── Aula03.c          #  dois vetores, operação posição a posição
│   ├── Aula04.c          #  array como parâmetro de função
│   ├── Aula05.c          #  strlen / strcpy / strcmp
│   └── Aula06.c          #  fgets + strcspn + strlen
├── Atividade/
│   └── Atv01.c           #  soma e média de dois vetores
├── scripts/
│   ├── sync.ps1          #  commit + push em um comando
│   └── auto-sync.ps1     #  watcher: sincroniza sozinho ao salvar
├── .opencode/
│   ├── agents/           #  agente git-sync (OpenCode)
│   └── commands/         #  comando /sync
├── bin/                  #  executáveis (.exe) — fora do versionamento
├── .vscode/              #  build & debug prontos (F5 / Ctrl+Shift+B)
├── .gitignore
└── README.md
```

---

## 📚 `cat index.md`

| # | Arquivo | Tema | O que acontece |
|:-:|:--|:--|:--|
| `01` | [`Aula01.c`](Aulas/Aula01.c) | Vetores | Cria `int v[5]`, imprime índices e sobrescreve `v[2]` |
| `02` | [`Aula02.c`](Aulas/Aula02.c) | Laço + vetor | Lê 5 idades e devolve na ordem inversa |
| `03` | [`Aula03.c`](Aulas/Aula03.c) | Dois vetores | `v2[i] = v1[i] * 2` e mostra lado a lado |
| `04` | [`Aula04.c`](Aulas/Aula04.c) | Vetor + função | `soma_vetor()` percorre `n` posições |
| `05` | [`Aula05.c`](Aulas/Aula05.c) | Strings | Copia, compara e mede `"banana"` |
| `06` | [`Aula06.c`](Aulas/Aula06.c) | Strings | `fgets` + remove o `\n` com `strcspn` |
| `⭐` | [`Atv01.c`](Atividade/Atv01.c) | Atividade | Soma posição a posição + média de cada vetor |

---

## ⚙️ `gcc --version`

```bash
gcc (MinGW-W64) 13.x
```

### Compilar

```bash
gcc Aulas/Aula01.c -o bin/Aula01
```

### Executar

```bash
# Windows
bin\Aula01.exe

# Linux / macOS
./bin/Aula01
```

### Atalhos no VS Code

| Ação | Atalho | Resultado |
|:--|:--|:--|
| Compilar arquivo ativo | `Ctrl + Shift + B` | gera `bin/<arquivo>.exe` |
| Compilar e depurar | `F5` | abre o terminal com `gdb` |

---

## 🤖 `git push --auto`

Este repositório tem um **sincronizador automático**: toda vez que um arquivo é
salvo, criado ou apagado, ele faz `add` → `commit` → `push` sozinho.

```bash
# ligar o vigia (fica rodando no terminal)
.\scripts\auto-sync.ps1

# sincronizar uma vez, na mão
.\scripts\sync.ps1

# commit com mensagem própria, sem push
.\scripts\sync.ps1 -Mensagem "add: exercicio de strings" -SemPush
```

**Como funciona**

```text
salvou o arquivo
      │
      ▼
FileSystemWatcher  ──►  aguarda 10s de silêncio
      │
      ▼
git add -A  ──►  git commit  ──►  git push origin main
                                   (rebase automático se o remoto estiver na frente)
```

| Camada | Arquivo | Quando roda |
|:--|:--|:--|
| Automação total | [`scripts/auto-sync.ps1`](scripts/auto-sync.ps1) | ao salvar qualquer arquivo (task `Git: auto-sync`, roda ao abrir a pasta) |
| Um comando | [`scripts/sync.ps1`](scripts/sync.ps1) | `Ctrl+Shift+P` → *Run Task* → `Git: sync agora` |
| Dentro do agente | [`.opencode/agents/git-sync.md`](.opencode/agents/git-sync.md) | pedindo ao agente, ou com o comando `/sync` |

<details>
<summary><b>Ignorados pelo vigia</b></summary>

`.git/`, `bin/`, `*.exe`, `*.o`, `*.obj`, `*.log` — nada disso gera commit.
O log da automação fica em `.git/auto-sync.log` (fora do versionamento).

</details>

<details>
<summary><b>Desligar a automação</b></summary>

No VS Code: `Ctrl+Shift+P` → **Tasks: Manage Automatic Tasks** → *Disallow Automatic Tasks*.
Ou simplesmente feche o terminal do watcher com `Ctrl+C`.

</details>

---

## 🧠 `cat notas.md`

<details>
<summary><b>Vetor é índice 0, sempre</b></summary>

```c
int v[5] = {10, 20, 30, 40, 50};
//           0   1   2   3   4
printf("%d\n", v[0]);  // 10
printf("%d\n", v[4]);  // 50  (o último, não o quinto)
```

> `v[5]` não existe nesse vetor — e o compilador não avisa. C confia em você.

</details>

<details>
<summary><b>Array decai para ponteiro na função</b></summary>

```c
int soma_vetor(int v[], int n) {   // recebe o endereço, não uma cópia
    int soma = 0;
    for (int i = 0; i < n; i++) soma += v[i];
    return soma;
}
```

> Por isso o `n` precisa ser passado à mão: dentro da função não dá para saber o tamanho.

</details>

<details>
<summary><b>String em C é vetor de <code>char</code> com <code>'\0'</code> no fim</b></summary>

```c
char a[20] = "banana";
strlen(a);          // 6  (não conta o '\0')
strcpy(b, a);       // copia byte a byte, inclusive o '\0'
strcmp(a, b) == 0;  // 0 = iguais; NÃO use ==
```

> `==` compara endereços de memória. `strcmp` compara o conteúdo.

</details>

<details>
<summary><b><code>fgets</code> guarda o <code>\n</code> — e isso quebra tudo</b></summary>

```c
char nome[30];
fgets(nome, 30, stdin);              // "Ana\n\0"
nome[strcspn(nome, "\n")] = '\0';    // "Ana\0"
```

> Sem essa linha, `strlen` conta o enter e o `printf` pula de linha sozinho.

</details>

---

<div align="center">

**`make it work, make it right, make it fast`**

`0 erros, 0 warnings, 0 desculpas.`

</div>
