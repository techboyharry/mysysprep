. '.\lib\load-env-with-cfg.ps1'
. '.\lib\load-commonfn.ps1'
. '.\lib\load-reghelper.ps1'

$cfg = $modules.registry

. '.\lib\load-commonfn.ps1'

if ($cfg.optimze) {
    $Script:msg = Get-Translation 'Optimzed.' -cn '已优化'

    & "$PSScriptRoot\scripts\optimze.ps1"
    logif1
}

if ($cfg.protectMyPrivacy) {
    $Script:msg = Get-Translation 'Disabled privacy collectors.' `
        -cn '已屏蔽隐私收集器'

    & "$PSScriptRoot\scripts\protect-privacy.ps1"
    logif1
}

if ($cfg.disableAd) {
    $Script:msg = Get-Translation 'Disabled Ad.' `
        -cn '已屏蔽广告系统'

    Set-ItemProperty (
        Get-CurrentAndNewUserPaths    'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
    ) Enabled 0
    Remove-ItemProperty -Force 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' Id -ea 0

    logif1 -f
}

if ($cfg.enableClassicPhotoViewer) {
    $Script:msg = Get-Translation 'Enabled classic photoviewer.' `
        -cn '激活经典图片查看器'

    reg.exe import "$PSScriptRoot\scripts\classic-photoviewer.reg" 2>&1 | Out-Null

    logif1 -f
}

if ($cfg.preferTouchpadGestures) {
    $Script:msg = Get-Translation 'Changed touchpad gestures schema.' `
        -cn '已改变触摸板手势方案'

    applyRegfileForMeAndDefault "$PSScriptRoot\scripts\touchpad-gestures.reg"
    logif1
}

if ($cfg.advancedRemapIcons) {
    & "$PSScriptRoot\scripts\remap-icon.ps1"
}

if ($cfg.components) {
    foreach ($component in Get-ChildItem .\modules\registry\components\*.ps1) {
        $name = $component.BaseName
        $props = $cfg.components[$name]
        $path = "$PSScriptRoot\components\$name.ps1"
        if ((Test-Path $path) -and ($null -ne $props)) { & $path @props }
    }
}