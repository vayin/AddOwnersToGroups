
function ConnectToExchangeOnline{
try{
    $AdminCreds=Get-Credential
    $Session=New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $AdminCreds -Authentication Basic -AllowRedirection
    Import-PSSession $Session -AllowClobber
    Write-Host('info: Connected to Exchange Online') -ForegroundColor Green
    }    
catch{
 Write-Host $_.Exception.Message -ForegroundColor Red
}
}
function AddOwnersToGroup{
  try{
    $path='C:\My\Logs'
    $reportLog=$path.Trim()+'\logreport_0717_1.csv'
    Out-File -FilePath $reportLog -InputObject "Alias, Status1, Status2, Status3" -Encoding utf8
    $GroupsInfo=Import-Csv -Path 'C:\Users\deepa_000\Desktop\VinayWorkingDocs\Powershell\DevTenantSites.csv'
    ForEach($item in $GroupsInfo){
        $GroupAlias=$item.Alias
        $OwnersColl=$item.Owners
        $GroupName=$item.SiteName
        #Turing off the Welcome Note
        Set-UnifiedGroup -Identity $GroupAlias -UnifiedGroupWelcomeMessageEnabled:$false
        $status1='Welcome note Disabled'
        if($OwnersColl.indexOf(";") -gt -1)
        {
            foreach($ownerEmail in $OwnersColl.Split(";")){
                Add-UnifiedGroupLinks -Identity $GroupAlias -LinkType Members -Links $ownerEmail
                Add-UnifiedGroupLinks -Identity $GroupAlias -LinkType Owners -Links $ownerEmail
            }
        }
        $status2='Owners Added'
      sleep -Seconds 30
      Set-UnifiedGroup -Identity $GroupAlias -UnifiedGroupWelcomeMessageEnabled:$true
      $status3='Welcome note Enabled'
      Add-Content -Path $reportLog -Value "$GroupAlias, $status1, $status2, $status3"
     }       
    }
    catch{
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}
function Disconnect{
$SessionName=Get-PSSession
Write-Host ($SessionName)
Remove-PSSession -Name  $SessionName.Name
}

ConnectToExchangeOnline
sleep -Seconds 10
#AddOwnersToGroup
sleep -Seconds 10
Disconnect