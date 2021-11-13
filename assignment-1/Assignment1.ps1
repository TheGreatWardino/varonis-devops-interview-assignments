#imports necessary type for password generation
Add-Type -AssemblyName 'System.Web'

#function to create a new secure password
function New-SecurePassword(){

    #generate random string
    $script:PlainPass = [System.Web.Security.Membership]::GeneratePassword(20, 4)

    # convert to SecureString
    $script:SecurePass = $PlainPass | ConvertTo-SecureString -AsPlainText -Force

}

#generates secure password
New-SecurePassword

#creates the Varonis Assignment Group
New-AzureADGroup -DisplayName "Varonis Assignment Group" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

#gets the objectid of the group
[String]$AzureADGroup = (Get-AzureADGroup -SearchString "Varonis Assignment Group").ObjectId

#initializes an empty array
$ArrayofAzureADUsers = @()

#initiates a for loop that creates Test User 0 - 19
for($i = 0; $i -lt 2; $i++) {

    #creates a new PasswordProfile object
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile

    #stores the randomly generated string as a password 
    $PasswordProfile.Password = $SecurePass

    #creates the AzureAD User
    New-AzureADUser -DisplayName "Test User $i" -PasswordProfile $PasswordProfile -UserPrincipalName "testuser$i@m1992wgmail.onmicrosoft.com" -AccountEnabled $true -MailNickName "testuser$i"

    #gets the object ID of the user
    $AzureADUser = (Get-AzureADUser -ObjectId "testuser$i@m1992wgmail.onmicrosoft.com")

    #adds the ObjectId to the array
    $ArrayofAzureADUsers += $AzureADUser

}

foreach($AzureADUser in $ArrayofAzureADUsers) {

    #stores UPN of AzureAD user in variable
    $AzureADUser_Username = $AzureADUser.UserPrincipalName

    #stores ObjectId of AzureAD user in variable
    $AzureADUser_ObjectId = $AzureADUser.ObjectId

    #tries to add the user to the group
    try {

        #adds the AzureAD member to the group one at a time
        Add-AzureADGroupMember -ObjectId $AzureADGroup -RefObjectId $AzureADUser_ObjectId
    }

    #catches any errors from try statement; sets $err to true
    catch {
        $err = $true
    }

    #if err is true, result is stored as FAIL
    if($err -eq $true) {
        $Result = "FAIL"
    }

    #else if err is false, result is stored as SUCCESS
    else {
        $Result = "SUCCESS"
    }

    #stores the timestamp of when this script is running
    $timestamp = Get-Date -UFormat "%Y-%m-%d-%R"

    #location of log file
    $log = ".\test.log"

    #creates the log file
    Add-Content -Path $log -Value "Adding $AzureADUser_Username | Time: $timestamp | Result: $Result"

}
