# Author: José M. C. Noronha

function oknotify {
    param(
        [string] $appId,
        [string] $title,
        [string] $message
    )
    if ([string]::IsNullOrEmpty($appId)) {
        $appId = $PID
    }
    $NotifyIcon = [System.Windows.Forms.NotifyIcon]::new()
    $NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $appId).Path)
    $NotifyIcon.Visible = $true
    $NotifyIcon.ShowBalloonTip(20000, $title, $message, 'None')
}

function errornotify {
    param(
        [string] $appId,
        [string] $title,
        [string] $message
    )
    if ([string]::IsNullOrEmpty($appId)) {
        $appId = $PID
    }
    $NotifyIcon = [System.Windows.Forms.NotifyIcon]::new()
    $NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $appId).Path)
    $NotifyIcon.Visible = $true
    $NotifyIcon.ShowBalloonTip(20000, $title, $message, 'Error')
}

function infonotify {
    param(
        [string] $appId,
        [string] $title,
        [string] $message
    )
    if ([string]::IsNullOrEmpty($appId)) {
        $appId = $PID
    }
    $NotifyIcon = [System.Windows.Forms.NotifyIcon]::new()
    $NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $appId).Path)
    $NotifyIcon.Visible = $true
    $NotifyIcon.ShowBalloonTip(20000, $title, $message, 'Info')
}

function warnnotify {
    param(
        [string] $appId,
        [string] $title,
        [string] $message
    )
    if ([string]::IsNullOrEmpty($appId)) {
        $appId = $PID
    }
    $NotifyIcon = [System.Windows.Forms.NotifyIcon]::new()
    $NotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $appId).Path)
    $NotifyIcon.Visible = $true
    $NotifyIcon.ShowBalloonTip(20000, $title, $message, 'Warning')
}
