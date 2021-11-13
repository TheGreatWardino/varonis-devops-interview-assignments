#imports necessary type for password generation
Add-Type -AssemblyName 'System.Web'

#function to create a new secure password
function New-SecurePassword(){

    #generate random string
    $script:PlainPass = [System.Web.Security.Membership]::GeneratePassword(20, 4)

    # convert to SecureString
    $script:SecurePass = $PlainPass | ConvertTo-SecureString -AsPlainText -Force

}

#checks to see if the Varonis Assignment Group exists
$GroupExists = (Get-AzureADGroup -SearchString "Varonis Assignment Group")

if(!$GroupExists) {

    #creates the Varonis Assignment Group
    New-AzureADGroup -DisplayName "Varonis Assignment Group" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

}

else {
    Write-Warning "Found a duplicate group name; skipping group creation..."
}

#gets the PSObject of the group
$AzureADGroup = (Get-AzureADGroup -SearchString "Varonis Assignment Group")

#initializes an empty array
$ArrayofAzureADUsers = @()

#initiates a for loop that creates Test User 0 - 19
for($i = 0; $i -lt 20; $i++) {

    #generates secure password
    New-SecurePassword

    #creates a new PasswordProfile object
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile

    #stores the randomly generated string as a password 
    $PasswordProfile.Password = $SecurePass

    #creates the AzureAD user
    New-AzureADUser -DisplayName "Test User $i" -PasswordProfile $PasswordProfile -UserPrincipalName "testuser$i@m1992wgmail.onmicrosoft.com" -AccountEnabled $true -MailNickName "testuser$i"

    #gets the PSObject of the user
    $AzureADUser = (Get-AzureADUser -ObjectId "testuser$i@m1992wgmail.onmicrosoft.com")

    #adds the user PSObject to the array
    $ArrayofAzureADUsers += $AzureADUser

}

#location of log file
$logfile = ".\Assignment1.log"

foreach($AzureADUser in $ArrayofAzureADUsers) {

    #by default, the $Result will be a success, unless an error is thrown
    $Result = "SUCCESS"

    #attempts to add the user to the group
    try {
        #adds the AzureAD member to the group one at a time
        Add-AzureADGroupMember -ObjectId $AzureADGroup.ObjectId -RefObjectId $AzureADUser.ObjectId
    }

    #catches any errors from try statement; if an error is caught, sets $Result to FAIL
    catch {
        $Result = "FAIL"
    }

    #cleans up Error variable
    finally {
        $Error.Clear()
    }

    #stores the timestamp of when this script is running
    $timestamp = Get-Date -UFormat "%Y-%m-%d-%R"

    #creates the log file
    Add-Content -Path $logfile -Value "Adding $($AzureADUser.MailNickName) to $($AzureADGroup.DisplayName) | Time: $timestamp | Result: $Result"

}