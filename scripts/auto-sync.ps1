# auto-sync.ps1 - vigia a pasta do projeto e, a cada mudanca salva,
# faz commit e push automaticamente (via scripts\sync.ps1).
#
# Uso:
#   .\scripts\auto-sync.ps1                # espera 10s de silencio, depois sincroniza
#   .\scripts\auto-sync.ps1 -Espera 30     # espera 30s
#   .\scripts\auto-sync.ps1 -SemPush       # apenas commit local
#
# Para parar: Ctrl+C no terminal.

[CmdletBinding()]
param(
    [int]$Espera = 10,
    [switch]$SemPush
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$scriptSync = Join-Path $PSScriptRoot 'sync.ps1'
$log = Join-Path (Join-Path $repo '.git') 'auto-sync.log'

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

if (-not (Test-Path (Join-Path $repo '.git'))) {
    Write-Host "x esta pasta nao e um repositorio git: $repo" -ForegroundColor Red
    exit 1
}

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repo
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, DirectoryName, LastWrite, Size'
$watcher.InternalBufferSize = 65536
$watcher.EnableRaisingEvents = $true

Registrar "watch ligado em $repo | espera ${Espera}s | push=$(-not $SemPush)" 'Cyan'
Write-Host '  (Ctrl+C para parar)' -ForegroundColor DarkGray

$pendente = $false
$ultima = Get-Date

try {
    while ($true) {
        $evento = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::All, 1000)

        if (-not $evento.TimedOut) {
            if (-not (Ignorar $evento.Name)) {
                if (-not $pendente) {
                    Registrar "mudanca detectada: $($evento.Name)" 'Yellow'
                }
                $pendente = $true
                $ultima = Get-Date
            }
        }

        $parado = ((Get-Date) - $ultima).TotalSeconds -ge $Espera
        if ($pendente -and $parado) {
            $pendente = $false
            Registrar 'sincronizando...' 'Cyan'

            $argumentosSync = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptSync)
            if ($SemPush) { $argumentosSync += '-SemPush' }

            try {
                $saida = & powershell @argumentosSync 2>&1
                $codigo = $LASTEXITCODE
                if ($codigo -eq 0) { Registrar 'sync concluido' 'Green' }
                else {
                    Registrar "sync terminou com codigo $codigo" 'Red'
                    foreach ($linha in $saida) { Registrar "  $linha" 'DarkRed' }
                }
            }
            catch {
                Registrar "erro no sync: $($_.Exception.Message)" 'Red'
            }
        }
    }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Registrar 'watch encerrado'
}
