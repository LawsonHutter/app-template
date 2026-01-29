# Start Docker stack (foreground)
# Wrapper around scripts/start-docker-stack.ps1 for backwards compatibility.

param(
    [ValidateSet("dev", "prod")]
    [string]$Mode = "dev",

    [switch]$Build
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$scriptDir\start-docker-stack.ps1" -Mode $Mode -Build:$Build
