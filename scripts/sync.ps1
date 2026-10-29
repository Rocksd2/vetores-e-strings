# sync.ps1 - faz commit de tudo que mudou e envia para o GitHub.
#
# Uso:
#   .\scripts\sync.ps1                      # commit automatico + push
#   .\scripts\sync.ps1 -Mensagem "minha msg" # commit com mensagem propria
#   .\scripts\sync.ps1 -SemPush              # so commit, sem enviar
#
# Codigos de retorno: 0 = ok/sem mudancas | 1 = falha no commit | 2 = falha no push

[CmdletBinding()]
param(
    [string]$Mensagem,
    [switch]$SemPush,
    [switch]$Silencioso
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$semPush = [bool]$SemPush

function Escrever {
    param([string]$Texto, [string]$Cor = 'Gray')
    if (-not $Silencioso) { Write-Host $Texto -ForegroundColor $Cor }
}

# Wrapper do git: o git escreve avisos no stderr e, com ErrorActionPreference=Stop,
# o PowerShell trataria isso como erro fatal. Aqui stderr vira texto normal e a
# decisao fica sempre com o exit code.
function Invoke-Git {
    param([string[]]$Argumentos)

    $anterior = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $saida = & git @Argumentos 2>&1
        $codigo = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $anterior
    }

    return [pscustomobject]@{
        Codigo = $codigo
        Saida  = @($saida | ForEach-Object { "$_" })
    }
}

function Invoke-Sync {
    Push-Location $repo
    try {
        $branch = Invoke-Git -Argumentos 'rev-parse', '--abbrev-ref', 'HEAD'
        if ($branch.Codigo -ne 0) {
            Escrever '  x nao consegui identificar a branch' 'Red'
            return 1
        }
        $branch = ($branch.Saida -join '').Trim()

        $status = Invoke-Git -Argumentos 'status', '--porcelain'
        if (($status.Saida -join '').Trim() -eq '') {
            Escrever '  = nada para commitar' 'DarkGray'
            return 0
        }

        $null = Invoke-Git -Argumentos 'add', '-A'

        $staged = Invoke-Git -Argumentos 'diff', '--cached', '--name-only'
        $arquivos = @($staged.Saida | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
        if ($arquivos.Count -eq 0) {
            Escrever '  = nada para commitar' 'DarkGray'
            return 0
        }

        if ($Mensagem) {
            $titulo = $Mensagem
        }
        else {
            $quantidade = $arquivos.Count
            if ($quantidade -eq 1) { $titulo = "auto: atualiza $($arquivos[0])" }
            else { $titulo = "auto: atualiza $quantidade arquivos" }
        }

        $commit = Invoke-Git -Argumentos 'commit', '-m', $titulo, '-m', "Arquivos alterados:`n$($arquivos -join "`n")"
        if ($commit.Codigo -ne 0) {
            Escrever "  x falha no commit:`n$($commit.Saida -join "`n")" 'Red'
            return 1
        }
        Escrever "  + commit: $titulo" 'Green'

        if ($semPush) {
            Escrever '  - push ignorado (SemPush)' 'DarkGray'
            return 0
        }

        $remote = Invoke-Git -Argumentos 'remote'
        if (($remote.Saida -join '').Trim() -eq '') {
            Escrever '  ! repositorio sem remote: commit feito apenas localmente' 'Yellow'
            return 0
        }

        $push = Invoke-Git -Argumentos 'push', 'origin', $branch
        if ($push.Codigo -ne 0) {
            Escrever "  ~ push recusado, sincronizando com origin/$branch..." 'Yellow'
            $pull = Invoke-Git -Argumentos 'pull', '--rebase', 'origin', $branch
            if ($pull.Codigo -ne 0) {
                $null = Invoke-Git -Argumentos 'rebase', '--abort'
                Escrever '  x conflito no rebase: resolva manualmente e rode o sync de novo' 'Red'
                return 2
            }
            $push = Invoke-Git -Argumentos 'push', 'origin', $branch
            if ($push.Codigo -ne 0) {
                Escrever "  x push falhou:`n$($push.Saida -join "`n")" 'Red'
                return 2
            }
        }

        Escrever "  ^ enviado para origin/$branch" 'Cyan'
        return 0
    }
    finally {
        Pop-Location
    }
}

$codigo = Invoke-Sync
exit $codigo
