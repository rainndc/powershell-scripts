$username = $args[0]
$userAD = $args[1]
$passwordAD = $args[2]

$passwordADSec = convertto-securestring $passwordAD -AsPlainText -Force
$cred = new-object System.Management.Automation.PSCredential -argumentlist ($userAD,$passwordADSec)

# Generate a random password
. “C:\path\to\repo\powershellScripts\GeneratePassword.ps1"
$newPassword = New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 8
$newPasswordSec = ConvertTo-SecureString -AsPlainText -Force -String $newPassword

Import-Module ActiveDirectory

Try
{
    Set-ADAccountPassword -Identity $username -Reset -NewPassword $newPasswordSec -Credential $cred
    Set-ADUser -Identity $username -ChangePasswordAtLogon $true -Credential $cred
    Write-Host "The password for $username has been reset. The New password is: $newPassword"
}
Catch [Exception]
{
    return $_.Exception.Message
    Write-Host "Something went wrong. Is the username you entered correct?`nPlease email email@example.com for more help"
}
