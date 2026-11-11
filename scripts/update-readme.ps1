# update-readme.ps1 - regenera a arvore e o indice do README a partir dos .c.
#
# Cada exercicio se descreve na primeira linha do proprio arquivo:
#   // tema: Vetores | desc: Cria int v[5] e sobrescreve v[2]
# Arquivo sem essa linha entra com "sem descricao" em vez de sumir do README.
#
# Roda sozinho dentro do sync.ps1; tambem da para chamar na mao:
#   .\scripts\update-readme.ps1

[CmdletBinding()]
param([switch]$Silencioso)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$readme = Join-Path $repo 'README.md'

function Escrever {
    param([string]$Texto, [string]$Cor = 'Gray')
    if (-not $Silencioso) { Write-Host $Texto -ForegroundColor $Cor }
}

function Get-Exercicios {
    param([string]$Pasta)

    Get-ChildItem -Path (Join-Path $repo $Pasta) -Filter '*.c' -File |
        Sort-Object Name |
        ForEach-Object {
            $primeira = Get-Content -Path $_.FullName -TotalCount 1
            if ($primeira -match '^\s*//\s*tema:\s*(.+?)\s*\|\s*desc:\s*(.+?)\s*$') {
                $tema = $Matches[1]
                $desc = $Matches[2]
            }
            else {
                $tema = 'C'
                $desc = 'sem descricao'
            }
            [pscustomobject]@{ Nome = $_.Name; Tema = $tema; Desc = $desc }
        }
}

# Alinha o "#" da descricao na coluna 26, como no resto da arvore.
function Linha-Arvore {
    param([string]$Prefixo, [string]$Desc)
    $texto = if ($Prefixo.Length -lt 26) { $Prefixo.PadRight(26) } else { $Prefixo + ' ' }
    return $texto + '#  ' + $Desc
}

function Bloco-Pasta {
    param([string]$Pasta, [string]$Comentario, [object[]]$Itens)

    $linhas = @(Linha-Arvore "├── $Pasta/" $Comentario)
    for ($i = 0; $i -lt $Itens.Count; $i++) {
        $ramo = if ($i -eq $Itens.Count - 1) { '└──' } else { '├──' }
        $linhas += Linha-Arvore "│   $ramo $($Itens[$i].Nome)" $Itens[$i].Desc
    }
    return $linhas
}

$aulas = @(Get-Exercicios 'Aulas')
$atividades = @(Get-Exercicios 'Atividade')

$arvore = @('Vetores e Strings/')
$arvore += Bloco-Pasta 'Aulas' "$($aulas.Count) aulas, um programa independente cada" $aulas
$arvore += Bloco-Pasta 'Atividade' 'exercicios entregues em sala' $atividades
$arvore += @(
    (Linha-Arvore '├── scripts/' 'commit + push em um comando'),
    (Linha-Arvore '│   ├── sync.ps1' 'commit + push em um comando'),
    (Linha-Arvore '│   ├── auto-sync.ps1' 'watcher: sincroniza sozinho ao salvar'),
    (Linha-Arvore '│   └── update-readme.ps1' 'regenera esta arvore e o indice'),
    (Linha-Arvore '├── .opencode/' 'agente git-sync (OpenCode)'),
    (Linha-Arvore '│   ├── agents/' 'agente git-sync'),
    (Linha-Arvore '│   └── commands/' 'comando /sync'),
    (Linha-Arvore '├── bin/' 'executaveis (.exe) - fora do versionamento'),
    (Linha-Arvore '├── .vscode/' 'build & debug prontos (F5 / Ctrl+Shift+B)'),
    '├── .gitignore',
    '└── README.md'
)

$tabela = @(
    '| # | Arquivo | Tema | O que acontece |',
    '|:-:|:--|:--|:--|'
)
for ($i = 0; $i -lt $aulas.Count; $i++) {
    $numero = '{0:00}' -f ($i + 1)
    $tabela += '| `' + $numero + '` | [`' + $aulas[$i].Nome + '`](Aulas/' + $aulas[$i].Nome + ') | ' +
        $aulas[$i].Tema + ' | ' + $aulas[$i].Desc + ' |'
}
foreach ($atividade in $atividades) {
    $tabela += '| `⭐` | [`' + $atividade.Nome + '`](Atividade/' + $atividade.Nome + ') | ' +
        $atividade.Tema + ' | ' + $atividade.Desc + ' |'
}

$texto = [System.IO.File]::ReadAllText($readme)
$nl = if ($texto.Contains("`r`n")) { "`r`n" } else { "`n" }

function Trocar-Bloco {
    param([string]$Texto, [string]$Nome, [string]$Novo, [string]$Nl)

    $inicio = "<!-- ${Nome}:inicio -->"
    $fim = "<!-- ${Nome}:fim -->"
    $i = $Texto.IndexOf($inicio)
    $f = $Texto.IndexOf($fim)
    if ($i -lt 0 -or $f -lt $i) { throw "marcadores $inicio / $fim nao encontrados no README" }

    return $Texto.Substring(0, $i + $inicio.Length) + $Nl + $Novo + $Nl + $Texto.Substring($f)
}

$arvoreTxt = '```bash' + $nl + ($arvore -join $nl) + $nl + '```'
$indiceTxt = $tabela -join $nl

$novo = Trocar-Bloco (Trocar-Bloco $texto 'arvore' $arvoreTxt $nl) 'indice' $indiceTxt $nl
if ($novo -eq $texto) {
    Escrever '  = README ja estava em dia' 'DarkGray'
}
else {
    [System.IO.File]::WriteAllText($readme, $novo, (New-Object System.Text.UTF8Encoding($false)))
    Escrever '  + README atualizado' 'Green'
}
