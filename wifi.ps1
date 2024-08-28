param (
    [string]$Ssid = "Hotspot",
    [string]$Passphrase = "12345678"
)

# 获取当前网络配置文件
$profile = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetInternetConnectionProfile()
$tm = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($profile)

function Start-Hotspot {
    param (
        [string]$Ssid,
        [string]$Passphrase
    )

    $ap = $tm.GetCurrentAccessPointConfiguration()
    if ($Ssid) {
        $ap.Ssid = $Ssid
    }
    if ($Passphrase) {
        $ap.Passphrase = $Passphrase
    }
    $tm.ConfigureAccessPointAsync($ap) | Out-Null
    $tm.StartTetheringAsync() | Out-Null
    echo "Hotspot started with SSID '$($ap.Ssid)' and Passphrase '$($ap.Passphrase)'"
	echo ""
}

function Stop-Hotspot {
    $tm.StopTetheringAsync() | Out-Null
    echo "Hotspot stopped."
}

function Show-Menu {
	Write-Host "WiFi Hotspot Tools"
	Write-Host "--------------------"
    Write-Host "1. Setup the Hotspot"
    Write-Host "2. Start Hotspot"
    Write-Host "3. Stop Hotspot"
    Write-Host "4. Exit"
    $choice = Read-Host "Please select an option (1-4)"
    return $choice
}

if ($Ssid -and $Passphrase) {
    # 如果提供了SSID和Passphrase，自动配置并启动热点
    Start-Hotspot -Ssid $Ssid -Passphrase $Passphrase
} elseif ($Ssid -and !$Passphrase) {
    switch ($Ssid.ToLower()) {
        "auto" {
            if ($tm.TetheringOperationalState -eq 1) {
                Stop-Hotspot
            } else {
                Start-Hotspot
            }
        }
        "on" {
            Start-Hotspot
        }
        "off" {
            Stop-Hotspot
        }
        default {
            Write-Host "Invalid option."
        }
    }
} else {
    while ($true) {
        $choice = Show-Menu
        switch ($choice) {
            "1" {
                $newSsid = Read-Host "Enter new SSID"
                $newPassphrase = Read-Host "Enter new Passphrase"
                Start-Hotspot -Ssid $newSsid -Passphrase $newPassphrase
            }
            "2" {
                Start-Hotspot
            }
            "3" {
                Stop-Hotspot
            }
            "4" {
                exit
            }
            default {
                Write-Host "Invalid selection, please try again."
            }
        }
    }
}
