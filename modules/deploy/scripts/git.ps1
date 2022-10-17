$pkgfile = Get-PackageFile "Git-*-64-bit.exe"
if (!$PSSenderInfo) {
    if (-not $pkgfile) { return }
    return @{
        name   = 'Git'
        target = 'C:\Program Files\Git\cmd\git.exe'
    }
}

Start-Process $pkgfile "/LOADINF=$pkgCfgFolder/git.ini /SILENT /SUPPRESSMSGBOXES /NORESTART /SP-" -PassThru | Wait-Process

Push-SystemPath "C:\Program Files\Git\bin"

if (!(Test-Path "$env:USERPROFILE\.minttyrc")) {
    Copy-Item "$pkgCfgFolder\.minttyrc" $env:USERPROFILE
}