<#

Script to create a new user in AD. The script takes several command line arguments and uses them to create an AD user.
Along with creating a user, the script will add a user to a specific groups based on the OU specified. Not everyone may need this functionality.
Finally, the script will send out an email to a specified address upon completion or failure.

#>

$firstName = $args[0]
$lastName = $args[1]
$username = $args[2]
$orgUnit = $args[3]
$userAD = $args[5]
$passwordAD = $args[6]

$firstName = $firstName.substring(0,1).toupper()+$firstName.substring(1).tolower()
$lastName = $lastName.substring(0,1).toupper()+$lastName.substring(1).tolower()
$username = $username.ToLower()
$passwordADSec = convertto-securestring $passwordAD -AsPlainText -Force
$cred = new-object System.Management.Automation.PSCredential -argumentlist ($userAD,$passwordADSec)
$basedn = “CN=Users,DC=local,DC=example,DC=com”

# Generate a random password
. “C:\path\to\repo\powershellScripts\GeneratePassword.ps1"
$newPassword = New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 8
$newPasswordSec = ConvertTo-SecureString -AsPlainText -Force -String $newPassword

# Create the DN string where the user should be created
switch ($orgUnit)
{
	OU1 { $orgUnit_DN = "OU=OU1,” + $basedn; break }
	OU2 { $orgUnit_DN = "OU=OU2,” + $basedn; break }
	OU3 { $orgUnit_DN = "OU=OU3,” + $basedn; break }
	OU4 { $orgUnit_DN = "OU=OU4,” + $basedn; break }
	OU5 { $orgUnit_DN = "OU=OU5,” + $basedn; break }
	OU6 { $orgUnit_DN = "OU=OU6,” + $basedn; break }
	OU7 { $orgUnit_DN = "OU=OU7,” + $basedn; break }
}

# Create an array of groups that the user should be a member of
switch ($orgUnit)
{
	Group1 { $groups = “OU=Group1,” + $basedn; break }
	Group2 { $groups = “OU=Group2,” + $basedn; break }
	Group3 { $groups = “OU=Group3,” + $basedn; break }
	Group4 { $groups = “OU=Group4,” + $basedn; break }
	Group5 { $groups = “OU=Group5,” + $basedn; break }
	Group6 { $groups = “OU=Group6,” + $basedn; break }
	Group7 { $groups = “OU=Group7,” + $basedn; break }
}


Import-Module ActiveDirectory

Try
{
    New-ADUser -AccountPassword $newPasswordSec -DisplayName ($firstName + " " + $lastName) -GivenName $firstName -Surname $lastName -EmailAddress ($username + “@example.org") -UserPrincipalName ($username + “@“ + “local.example.com”) -SamAccountName $username -Department $orgUnit -Name ($firstName + " " + $lastName) -Path $orgUnit_DN -Credential $cred -PassThru | Enable-ADAccount
    $output = Get-ADUser -Identity $username
    Set-ADUser -Identity $userName -ChangePasswordAtLogon 1 -Credential $cred
	
    ForEach ($group in $groups)
    {
        Add-ADGroupMember -Identity $group -Members $username -Credential $cred
    }
    
    exit
}
Catch [Exception]
{
    Write-host $_
	$ErrorMessage = $_
    exit
}

Finally
{
    $EmailFrom = “email@example.com”
    If (!$output)
    {
        $EmailSubject = "Unable to create the user " + $username
        $EmailBody = $userAD + " tried to create a new employee named" + " " + $firstName + " " + $lastName + ", but something went wonky. The error message is:`n" + $ErrorMessage
    }
    Else
    {
        $EmailSubject = "A New employee has been created in" + " " + $OrgUnit
        $EmailBody = "`n
                      Username: $username`n
                      First Name: $firstName`n
                      Last Name: $lastName`n
                      Department: $OrgUnit`n

    }
    $msg = new-object Net.Mail.MailMessage
    $msg.From = $EmailFrom
    $msg.to.Add(“email@example.com”)
    $msg.Subject = $EmailSubject
    $msg.Body = $EmailBody
    $SMTPClient = New-Object Net.Mail.SmtpClient(“smtp.example.com”, 587)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential(“email@example.com”, “p@ssw0rd”)
    $SMTPClient.Send($msg)
}
