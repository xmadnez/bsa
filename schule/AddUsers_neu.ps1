# AddUsers.ps1
# Powershell Script to add AD Users from a CSV file.
# Version 0.1 
# last edit: 2024-07-01

$csvPath = "$PSScriptRoot\Students.csv"  # PsScriptRoot zeigt auf Order in der das Script liegt.

$userData = Import-Csv -Path $csvPath

foreach ($entry in $userData) 
{
    if ($entry.Klasse -eq "IAV2325")
    {
        Write-Host "$($entry.Vorname) ist in der Klasse $($entry.Klasse)"
        # Create vars for the new user.
        $username =  ($entry.Vorname + "." + $entry.Nachname).ToLower()
        $mail = $username + "@schule.de"
        $password = $entry.Geburtstag
        # convert passwort from string to SecureString
        $accountPW = ConvertTo-SecureString -AsPlainText $password -Force
        
        $ouName = $entry.Klasse
        $ouPath = "OU=Benutzer,OU=BSAP,DC=bsap,DC=exam"
        # Check if the OU already exists
        if (-not (Get-ADOrganizationalUnit -Filter { Name -eq $ouName })) {
            # Create the OU
            New-ADOrganizationalUnit -Name $ouName -Path $ouPath -ProtectedFromAccidentalDeletion $false
        } else {
            Write-Host "OU '$ouName' already exists."
        }
        # set ou path where the user should be added.
        $ouPath = "OU=$ouName,OU=Benutzer,OU=BSAP,DC=bsap,DC=exam" 

        New-AdUser -SamAccountName $username -UserPrincipalName $username -Name $username -AccountPassword $accountPW  -Enabled $true -ChangePasswordAtLogon $true -Path $ouPath -EmailAddress $mail

    }
}

Write-Host "Alles fertig."


# Script offen halten am Ende
Read-Host "Press enter to continue."  