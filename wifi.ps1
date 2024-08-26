param (
    [string]$Ssid = "Hotspot",
    [string]$Passphrase = "12345678"
)
$profile = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetInternetConnectionProfile()
$tm = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($profile)
if ($tm.TetheringOperationalState -eq 1) {
    echo "Stop Hotspot"
    $tm.StopTetheringAsync() | Out-Null
} else {
    echo "Start Hotsopot"
    $ap = $tm.GetCurrentAccessPointConfiguration()
    $ap.Ssid = $Ssid
    $ap.Passphrase = $Passphrase
    $tm.ConfigureAccessPointAsync($ap) | Out-Null
    $tm.StartTetheringAsync() | Out-Null
}
