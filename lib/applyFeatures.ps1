Push-Location $PSScriptRoot\..
& .\lib\loadModules.ps1
Import-Module ConfigLoader

function getInitScript([string]$name) {
    return [scriptblock]::Create(
        @("cd '$(Get-Location)'"
            "& '$PSScriptRoot\loadModules.ps1'"
            'Import-Module ConfigLoader'
            "cd features\$name"
        ) -join ';'
    )
}

foreach ($feature in Get-ChildItem .\features -Directory -Exclude _*) {
    if ($cfg = Get-FeatureConfig ($name = $feature.Name)) {
        Start-Job -Name $name -FilePath ".\features\$name\apply.ps1" -ArgumentList $cfg `
            -InitializationScript (getInitScript $name) | Out-Null

        $formatted = switch ($cfg) {
            1 { 'true' }
            0 { 'false' }
            Default { ConvertTo-Json $cfg }
        }
        Write-Host "let $name", '=', ($formatted + ';')
    }
}

Write-Output '', 'Running ...', ''

function Get-JobOrWait {
    [OutputType([Management.Automation.Job])] param()
    while (Get-Job) {
        if ($job = Get-Job -State Failed | Select-Object -First 1) { return $job }
        if ($job = Get-Job -State Completed | Select-Object -First 1) { return $job }
        if ($job = Get-Job | Wait-Job -Any -Timeout 1) { return $job }
    }
}

while ($job = Get-JobOrWait) {
    $name = $job.Name
    try {
        Receive-Job $job -ErrorAction Stop
        Write-Host -ForegroundColor Green `
            "Succeeded: $name $('({0:F2}s)' -f ($job.PsEndTime - $job.PsBeginTime).TotalSeconds)"
    }
    catch {
        Write-Host -ForegroundColor Red @"
Failed to add: $name, reason:
$($_.Exception.Message)

"@
    }
    finally {
        Remove-Job $job
    }
}

Pop-Location
Write-Output 'OK!', ''