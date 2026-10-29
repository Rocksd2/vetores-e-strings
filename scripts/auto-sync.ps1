# auto-sync.ps1 - vigia a pasta do projeto e, a cada mudanca salva,
# faz commit e push automaticamente (via scripts\sync.ps1).
#
# Uso:
#   .\scripts\auto-sync.ps1                     # espera 10s de silencio, depois sincroniza
#   .\scripts\auto-sync.ps1 -Espera 30          # espera 30s
#   .\scripts\auto-sync.ps1 -SemPush            # apenas commit local
#   .\scripts\auto-sync.ps1 -VerificarCada 60   # rede de seguranca: confere o status a cada 60s
#
# Para parar: Ctrl+C no terminal.

[CmdletBinding()]
param(
    [int]$Espera = 10,
    [int]$VerificarCada = 30,
    [switch]$SemPush
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$scriptSync = Join-Path $PSScriptRoot 'sync.ps1'
$log = Join-Path (Join-Path $repo '.git') 'auto-sync.log'
$semPush = [bool]$SemPush

if (-not (Test-Path (Join-Path $repo '.git'))) {
    Write-Host "x esta pasta nao e um repositorio git: $repo" -ForegroundColor Red
    exit 1
}

function Registrar {
    param([string]$Texto, [string]$Cor = 'DarkGray')
    $linha = '[{0}] {1}' -f (Get-Date -Format 'dd/MM/yyyy HH:mm:ss'), $Texto
    Add-Content -Path $log -Value $linha -Encoding UTF8
    Write-Host $linha -ForegroundColor $Cor
}

# O que nunca deve disparar um sync (evita loop infinito com o proprio .git)
function Ignorar {
    param([string]$Nome)
    if (-not $Nome) { return $true }
    $p = $Nome -replace '/', '\'
    if ($p -match '^\.git\\') { return $true }
    if ($p -match '^bin\\') { return $true }
    if ($p -match '\.(exe|o|obj|pdb|ilk|log)$') { return $true }
    return $false
}

# Rede de seguranca: se o FileSystemWatcher perder algum evento (buffer cheio,
# editor que salva via arquivo temporario, etc), o status do git revela a mudanca.
function TemMudancaNoGit {
    try {
        $saida = & git -C $repo status --porcelain 2>$null
        return -not [string]::IsNullOrWhiteSpace(($saida | Out-String))
    }
    catch {
        return $false
    }
}

function Invocar-Sync {
    $argumentos = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptSync)
    if ($semPush) { $argumentos += '-SemPush' }

    $saida = & powershell @argumentos 2>&1
    $codigo = $LASTEXITCODE
    return [pscustomobject]@{ Codigo = $codigo; Saida = @($saida) }
}

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repo
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, DirectoryName, LastWrite, Size'
$watcher.InternalBufferSize = 65536
$watcher.EnableRaisingEvents = $true

Registrar "watch ligado em $repo | espera ${Espera}s | verificacao ${VerificarCada}s | push=$(-not $semPush)" 'Cyan'
Write-Host '  (Ctrl+C para parar)' -ForegroundColor DarkGray

# Se o buffer do watcher encher, o evento de erro avisa em vez de falhar calado.
Register-ObjectEvent -InputObject $watcher -EventName Error -Action {
    Add-Content -Path $event.MessageData -Value ('[{0}] buffer do watcher estourou: {1}' -f (Get-Date -Format 'dd/MM/yyyy HH:mm:ss'), $EventArgs.GetException().Message) -Encoding UTF8
} -MessageData $log | Out-Null

$pendente = $false
$ultima = Get-Date
$proximaVerificacao = (Get-Date).AddSeconds($VerificarCada)

try {
    while ($true) {
        try {
            $evento = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::All, 1000)

            if (-not $evento.TimedOut -and -not (Ignorar $evento.Name)) {
                if (-not $pendente) { Registrar "mudanca detectada: $($evento.Name)" 'Yellow' }
                $pendente = $true
                $ultima = Get-Date
            }

            if ((Get-Date) -ge $proximaVerificacao) {
                $proximaVerificacao = (Get-Date).AddSeconds($VerificarCada)
                if (-not $pendente -and (TemMudancaNoGit)) {
                    Registrar 'mudanca encontrada pelo status do git' 'Yellow'
                    $pendente = $true
                    $ultima = Get-Date
                }
            }

            if ($pendente -and ((Get-Date) - $ultima).TotalSeconds -ge $Espera) {
                $pendente = $false
                Registrar 'sincronizando...' 'Cyan'
                try {
                    $resultado = Invocar-Sync
                    if ($resultado.Codigo -eq 0) {
                        Registrar 'sync concluido' 'Green'
                    }
                    else {
                        Registrar "sync terminou com codigo $($resultado.Codigo)" 'Red'
                        foreach ($linha in $resultado.Saida) { Registrar "  $linha" 'DarkRed' }
                    }
                }
                catch {
                    Registrar "erro no sync: $($_.Exception.Message)" 'Red'
                }
            }
        }
        catch {
            Registrar "erro no vigia: $($_.Exception.Message)" 'Red'
            Start-Sleep -Seconds 5
        }
    }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Get-EventSubscriber | Unregister-Event -ErrorAction SilentlyContinue
    Registrar 'watch encerrado'
}
