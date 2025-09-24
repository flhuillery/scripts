[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string[]]$Targets,
    
    [Parameter(Mandatory=$false)]
    [int]$Duration = 60,
    
    [Parameter(Mandatory=$false)]
    [int]$Interval = 1
)

function Test-TargetValidity {
    param (
        [string]$Target
    )
    
    $ipRegex = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    $fqdnRegex = "^(?!-)[A-Za-z0-9-]+([-.]{1}[a-z0-9]+)*\.[A-Za-z]{2,6}$"
    
    if ($Target -match $ipRegex -or $Target -match $fqdnRegex) {
        return $true
    }
    return $false
}

# Initialiser les statistiques
$stats = @{}
foreach ($target in $Targets) {
    $stats[$target] = @{
        "Sent" = 0
        "Received" = 0
        "Lost" = 0
        "MinTime" = [double]::MaxValue
        "MaxTime" = 0
        "TotalTime" = 0
        "SuccessfulPings" = 0
    }
}

Write-Host "Démarrage du test de ping multiple..."
Write-Host "Cibles: $($Targets -join ", ")"
Write-Host "Durée: $Duration secondes"
Write-Host "Intervalle: $Interval seconde(s)`n"

$startTime = Get-Date
$endTime = $startTime.AddSeconds($Duration)

while ((Get-Date) -lt $endTime) {
    foreach ($target in $Targets) {
        if (-not (Test-TargetValidity $target)) {
            Write-Warning "Cible invalide: $target"
            continue
        }
        
        $stats[$target]["Sent"]++
        $ping = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
        
        if ($ping) {
            $stats[$target]["Received"]++
            $responseTime = $ping.ResponseTime
            
            $stats[$target]["MinTime"] = [Math]::Min($stats[$target]["MinTime"], $responseTime)
            $stats[$target]["MaxTime"] = [Math]::Max($stats[$target]["MaxTime"], $responseTime)
            $stats[$target]["TotalTime"] += $responseTime
            $stats[$target]["SuccessfulPings"]++
            
            Write-Host "$(Get-Date -Format "HH:mm:ss") - $target : ${responseTime}ms" -ForegroundColor Green
        }
        else {
            $stats[$target]["Lost"]++
            Write-Host "$(Get-Date -Format "HH:mm:ss") - $target : Timeout" -ForegroundColor Red
        }
    }
    
    Start-Sleep -Seconds $Interval
}

Write-Host "`nRésultats du test de ping :"
Write-Host "=========================="

foreach ($target in $Targets) {
    Write-Host "`nCible : $target"
    Write-Host "-------------------------"
    
    $targetStats = $stats[$target]
    $lossPercentage = [math]::Round(($targetStats["Lost"] / $targetStats["Sent"]) * 100, 2)
    $avgTime = if ($targetStats["SuccessfulPings"] -gt 0) {
        [math]::Round($targetStats["TotalTime"] / $targetStats["SuccessfulPings"], 2)
    } else {
        0
    }
    
    Write-Host "Paquets envoyés: $($targetStats["Sent"])"
    Write-Host "Paquets reçus: $($targetStats["Received"])"
    Write-Host "Paquets perdus: $($targetStats["Lost"]) ($lossPercentage%)"
    if ($targetStats["SuccessfulPings"] -gt 0) {
        Write-Host "Temps minimum: $($targetStats["MinTime"])ms"
        Write-Host "Temps maximum: $($targetStats["MaxTime"])ms"
        Write-Host "Temps moyen: ${avgTime}ms"
    }
    else {
        Write-Host "Aucune réponse reçue"
    }
}