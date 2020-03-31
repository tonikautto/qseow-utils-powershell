# Input dialog to request new service credentials
Write-Host -ForegroundColor Green "Changing service credentials to "
$Credential = Get-Credential -message "`nProvide credentials to apply for Qlik Sense services.`n"
Write-Host -ForegroundColor Green -NoNewLine "$($Credential.UserName.ToUpper()) for Qlik Sense services...`n`n"

# Qlik Sense servces to apply new credentials on
# Exclude QRD service, as it runs with Local System

$QlikServices = Get-Service "Qlik*" | Where-Object {($_.Name -like "QlikSense*" -and $_.Name -notlike "QlikSenseRepositoryDatabase") -or ($_.Name -eq "QlikLoggingService")}
$QlikServices.DisplayName

# Stop all Qlik Sense services 
# Include services that have name starting with QlikSense
# Exclude Repository Database as it is expected to run as Local System

$QlikServices | Stop-Service -Force 

# Set same new service credentail for all services
$QlikServices | ForEach-Object{ (Get-WMIObject Win32_Service -Filter "Name='$($_.Name)'").change($null,$null,$null,$null,$null,$null, $Credential.UserName,$Credential.GetNetworkCredential().Password,$null,$null,$null)} | Out-Null

# Start all services again
$QlikServices | Start-Service 

Write-Host -ForegroundColor Green -NoNewLine "DONE! Check that services are running with expected credentials."
