#Script For multiple servers
#Copy the Sql file to remote servers
#Execute the sql file on remote servers
#delete the sql files on remote servers

$serverlist = get-content C:\Windows\Temp\serverlist.txt
$user = domain\user
$pass = X12X12
$password = ConvertTo-SecureString -String $pass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $user,$password 

Foreach ($server in $serverlist) {

Write-Host "Analysing the server $server"

IF (Test-Connection -BufferSize 32 -Count 1 -ComputerName $server -Quiet) {

Write-Host "The server $server is Online" 

$Session = New-PSSession -ComputerName $server -Credential $credential

$Session | Connect-PSSession 

Copy-Item "C:\Windows\Temp\SQl-audit-script.sql" -Destination "C:\Windows\SQl-audit-script.sql" -ToSession $Session

Invoke-Command -Session $Session -ScriptBlock {
                                                        invoke-sqlcmd -inputFile C:\Windows\SQl-audit-script.sql
                                                        Remove-Item "C:\Windows\SQl-audit-script.sql" -Force
                                                        write-output "Executed Audit script on $server succesfully"
                                               }     

$Session | Disconnect-PSSession 
$Session | Remove-PSSession 

} Else {
Write-Host "Unable to execute the audit script, the remote server $server is Offline"
}
}
