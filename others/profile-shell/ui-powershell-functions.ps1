# Author: José M. C. Noronha

function notify {
    [cmdletbinding()]
    param (
        [string] $appId,
        [string] $title,
        [string]
        [parameter(ValueFromPipeline)]
        $message,
        [string] $icon
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($title)) > $null
    ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($message)) > $null
    if (![string]::IsNullOrEmpty($icon)) {
        ($RawXml.toast.visual.binding.image|Where-Object {$_.id -eq "1"}).SetAttribute('src', $icon) > $null
    }

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)
    Write-Host $SerializedXml.ToString()

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "$appId"
    $Toast.Group = "$appId"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("$appId")
    $Notifier.Show($Toast);
}

function oknotify {
    [cmdletbinding()]
    param (
        [string] $appId,
        [string]
        [parameter(ValueFromPipeline)]
        $message,
        [string] $icon
    )
    notify -appId "$appId" -title "Success" -message "$message" -icon "$icon"
}

function infonotify {
    [cmdletbinding()]
    param (
        [string] $appId,
        [string]
        [parameter(ValueFromPipeline)]
        $message,
        [string] $icon
    )
    notify -appId "$appId" -title "Information" -message "$message" -icon "$icon"
}

function warnnotify {
    [cmdletbinding()]
    param (
        [string] $appId,
        [string]
        [parameter(ValueFromPipeline)]
        $message,
        [string] $icon
    )
    notify -appId "$appId" -title "Warning" -message "$message" -icon "$icon"
}

function errornotify {
    [cmdletbinding()]
    param (
        [string] $appId,
        [string]
        [parameter(ValueFromPipeline)]
        $message,
        [string] $icon
    )
    notify -appId "$appId" -title "Error" -message "$message" -icon "$icon"
}

function selectfiledialog {
    # Load Assembly
    Add-Type -AssemblyName System.Windows.Forms
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.ShowDialog() | Out-Null
    $filename = $OpenFileDialog.FileName
    $data = @{ selected="$filename"; }
    ConvertTo-Json $data -Depth 1 | Out-String
}
