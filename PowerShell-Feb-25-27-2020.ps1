#region day1
#region remote basics
#remotely connect 1:1 interactive session
enter-pssession dc1
ipconfig
Exit-PSSession
#remote connect 1:many
Invoke-Command -ComputerName dc1,app1 -ScriptBlock {ipconfig}

#working with object on local system, dot naming
#objects
#properties
#methods
#object template is a type

$services = get-service
$service = get-service -name w32time
$service.stop()
$service.start()

$services | Get-Member

#working with serialized remote objects
$remote_services = invoke-command -ComputerName dc1,dc2,app1 -ScriptBlock {get-service}
$remote_service = invoke-command -ComputerName dc1 -ScriptBlock {get-service -name W32Time}
$remote_service. #just process
$remote_services | get-member
$remote_service | get-member

#does using cmdlets with -computername parameter go through the serialization process
get-command -ParameterName computername
get-service -ComputerName dc2
$different_service = get-service -ComputerName dc1, app1
$different_service | get-member

#nope!!!

#endregion
#region Object Demo
$obj = New-Object -TypeName pscustomobject
$obj | get-member
$obj | Add-Member -MemberType Noteproperty -Name cpu -Value "Xeon"
$obj | Add-Member -Membertype Scriptmethod -Name Proc –Value {(get-WMIobject win32_processor).name}
$obj | get-member
$obj.Proc()

$myHashtable = @{
    Name     = $env:USERNAME
    Language = 'Powershell'
    version  = $PSVersionTable.PSVersion.Major
} 

$myObject = New-Object -TypeName PSObject -Property $myHashtable


[pscustomobject]@{name=$env:USERNAME; language='PowerShell'; version=$PSVersionTable.PSVersion.Major} 

#endregion
#region  com
#get a list of all com objects
$comlist =  Get-ChildItem -path HKLM:\Software\Classes | Where-Object -FilterScript `
{
    $_.PSChildName -match '^\w+\.\w+$' -and (Test-Path –Path "$($_.PSPath)\CLSID")
}

$comlist.count
$comlist

$WshShell = New-Object -ComObject WScript.Shell
$WshShell | get-member
$lnk = $WshShell.CreateShortcut("$Home\Desktop\PSHome.lnk")
$lnk | get-member
$lnk.TargetPath = $PSHome
$lnk.Save()

$WshShell.run("utilman")

#Look at running word processes
get-process winword

#Open a word document in PowerShell
$Word = New-Object -ComObject Word.Application	->   Note the application is running but bot yet visible	

#Look at running word processes
get-process winword	#			-> Should be 1 more now while it is not visible on screen
$Word | Get-Member
#Make word visible
$Word.Visible = $True

#Add a new blank document
$Document = $Word.Documents.Add()

#Add some text 
$Selection = $Word.Selection
$Selection.TypeText("My username is $($Env:USERNAME) and the date is $(Get-Date)")
$Selection.TypeParagraph()
$Selection.Font.Bold = 1
$Selection.TypeText("This is on a new line and bold!")

#Save the document to file and exit
$Report = "C:\temp\MyFirstDocument.docx" 
$Document | get-member
$Document.SaveAs([ref]$Report,[ref]$SaveFormat::wdFormatDocument)
$word.Quit() 

#Look at $word again everything is empty and clean due to common language runtime (CLR) garbage collector. Memory will be cleaned up no need to call dispose or GC.Collect()

#Look at $word
$word

#Recreate a new word document this time use strict switch to see it is using the .NET COM Interop
$Word2 = New-Object -ComObject Word.Application -strict

New-Object -ComObject WScript.Shell -Strict

#endregion
#region cim and wmi
#discover the cmdlets
get-command -noun *wmi*
get-command -noun *cim*

#get classes
get-wmiobject -list
get-cimclass

get-service | get-member
get-wmiobject -Class win32_service | get-member

Get-WmiObject –Class Win32_Process
Get-CimInstance –Class Win32_Process 

Get-WmiObject –Class Win32_Process | get-member
Get-CimInstance –Class Win32_Process | get-member

Get-WmiObject –Class Win32_Logicaldisk –Filter "drivetype=3" –Property name,freespace,size 
Get-CimInstance –Class Win32_Logicaldisk –Filter 'drivetype=3' –Property name,freespace,size

#query using WQL
Get-WmiObject –Query 'SELECT * FROM Win32_Process WHERE name like "svchost.exe" ' | select name, handlecount
Get-CimInstance –Query 'SELECT * FROM Win32_Process WHERE name like "svchost.exe" ' | select name, handlecount

#execute
new-item c:\data\Demo -ItemType Directory
$folder = Get-WmiObject -Query 'Select * From Win32_Directory Where Name ="C:\\data\\Demo " ' 
test-path c:\data\demo
$folder | Remove-WmiObject
test-path c:\data\demo


notepad.exe
$var = Get-CimInstance –Query 'Select * from Win32_Process where name LIKE "notepad%" '
Remove-CimInstance –InputObject $var

#use types
[wmi]"root\cimv2:Win32_Service.Name='spooler'"
[wmiclass] | get-member
([wmiclass]"Win32_Process").Create("Notepad.exe") 
[wmiclass]"Win32_Process" | get-member
$query = [wmisearcher]"Select * FROM Win32_Service WHERE State='Running'"
$query.Get() 

#sometimes cim output is better
Get-WmiObject -Class Win32_OperatingSystem | Select LastBootupTime
Get-CimInstance -Class Win32_OperatingSystem | Select LastBootupTime

#endregion
#region advance remoting
# PowerShell Remoting creates a temporary runspace in which it is being executed. 
# When exit or command execution is completed. The runspace is not available any more - all variables, functions, aliases and modules loaded are gone. 

# This is why you cannot access the variables defined
Invoke-Command -ComputerName MS -ScriptBlock {$a = 123; $b = 'abc'; $a; $b}
Invoke-Command -ComputerName MS -ScriptBlock {$a; $b}

# Whenever you are connecting to another machine, a process is being launched on the remote side: wsmprovhost, containing the runspace
# Run multiple times to demonstrate that the process ID is different. This means new process is launched every time
Invoke-Command -ComputerName ms -ScriptBlock {Get-Process -Name wsmprovhost | Format-Table -Property Name, Id}

# To create a persistent session we need to use New-PSSession
# you may specify alternative credentials as well (not required) -Credential Contoso\Administrator
New-PSSession -ComputerName MS -OutVariable sess

# Process id is the same, as it is a persistant session. 
# Run multiple times, to demonstrate consistent Process ID
Invoke-Command -Session $sess -ScriptBlock {Get-Process -Name wsmprovhost | Format-Table -Property Name, Id}

# Because it is persistent all of the variables, aliases, functions and modules will be there each and every time when connected. 

# Declare variables
Invoke-Command -Session $sess -ScriptBlock {$a = 123; $b = 'abc'; $a; $b}

# Call variables multiple times, to demonstrate, that they are available 
Invoke-Command -Session $sess -ScriptBlock {$a; $b}

# If we run again with ComputerName parameter, it creates again a temporary session, where the variables have not been declared and not available
Invoke-Command -ComputerName MS -ScriptBlock {$a; $b}   # returns NULL

# If we check the process, we'll see two results - one for the persistent session and one for the temporary
Invoke-Command -ComputerName MS -ScriptBlock {Get-Process -Name wsmprovhost | Format-Table -Property Name, Id}

#Run multiple times, to demonstrate that one process ID is constant (the persistent session), the other is changing (temporary session)
# Invoke in disconnected session
Invoke-Command -ComputerName DC -ScriptBlock {Get-Service} -InDisconnectedSession

# Show Session locally
Get-PSSession  

# show session on the remote computer
Get-PSSession -ComputerName DC

# Store session into variable
$sess = Get-PSSession -ComputerName DC

# Demo Connect and Disconnect
# Comment on state and availability
Connect-PSSession -ComputerName DC
Disconnect-PSSession -Session $sess

# Connect and Receive the output
# Receive also connects
Receive-PSSession -Session $sess

# Close the session
Get-PSSession | Remove-PSSession
Get-PSSession -ComputerName DC | Remove-PSSession
# importing the pssession
$session1 = new-pssession -ComputerName dc1
Import-PSSession -Session $session1 -Prefix DC1
Get-Command -noun dc1*

get-culture
get-dc1culture

#import just a module
Import-Module activedirectory -PSSession $session1 -Prefix blah
Get-blahADUser -Identity chad | get-member
get-aduser -Identity chad | get-member
#endregion
#region working with password
Consider demoing the following:

 
# Create credentials object
$UserName = 'Contoso\Administrator'
$secureString = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force

# Result
$secureString

# Create PSCredential object
$cred = New-Object -TypeName PSCredential -ArgumentList $UserName, $secureString
# Result
$cred

# Demo that it works with the created credentials
Invoke-Command -ComputerName MS -ScriptBlock {whoami} -Credential $cred

# Convert secure string as  encrypted string. 
$encryptedString = ConvertFrom-SecureString -SecureString $secureString

# Result
$encryptedString

# Convert back to Secure string
$convertedString = ConvertTo-SecureString -String $encryptedString

# Result
$convertedString

# Create PSCredential object with the converted secure string
$convertedCred = New-Object -TypeName PSCredential -ArgumentList $UserName, $convertedString

# Result
$convertedCred
$ConvertedCred.GetNetworkCredential().Password

# Demo that it works again
Invoke-Command -ComputerName ms -ScriptBlock {whoami} -Credential $convertedCred

# Cannot construct secure string from encrypted string, as it is encrypted twice : User and Computer
# Demo: When try to reconstruct secure string from encrypted string on another machine - it fails! 
Invoke-Command -ComputerName DC -ScriptBlock {$using:encryptedString}  # sending the credentials
Invoke-Command -ComputerName DC -ScriptBlock {ConvertTo-SecureString -String $using:encryptedString} # try to re-construct - fails!
# Result: Key not valid for use in specified state. 


##########

#endregion
#region follow up
#need better examples to explain RCW strict.
#could not find dc in the last part of lab 2 cim from remote computers.
#lab 1 didnt like fqdn

#endregion
#endregion
#region day2
#region regex
"Admin@Contoso.com" -match "admin"
"Admin@Contoso.com" -match "A...n"
"Admin@Contoso.com" -match "a...n"
"Admin@Contoso.com" -match [a..b]

# splits on each character
"Admin@Contoso.com" -split "."
 # splits on "."
"Admin@Contoso.com" -split "\." 
#any word character
"Admin@Contoso.com" -match "\w"
1234 -match "\w"
$matches[0]
#whitespace character
"abcd efgh" -match "\s"
#any decimal character
12345 -match "\d" 
#exact n match
"Admin@Contoso.com" -match "\w{2}"
$matches[0]
#at least n match
"Admin@Contoso.com" -match "\w{2,}"
"1ADmi1n@Contoso.com" -match "\w{2,}"
$matches[0]
#at least n no more than m
"Admin@Contoso.com" -match "\w{2,3}"
$matches[0]
#splitting text
$a = @"
1The first line.
2The second line.
3The third of three lines.
"@ 
$a -split "\d"
#remove the empty lines
($a -split "\d").trim()| Where-object –filterscript {$_ -ne ""}

#demo
#Any message that has error in it:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "error"}

#Any message that has restart in it:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "restart"}

#Any message that has stop in it:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "stop"}

#Using wildcard matching with ".":
#Any message that contains ProgramData on any driveletter:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "...ProgramData"} | select-object -first 5

#Any message that refferances an event ID with 1 character or digit in qoutes:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "Event ID '.'"} | select-object -first 5

#Using escape "\" character:
#Any message that references an exe file:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match ".\.exe"} | select-object -first 5 | select eventid, message |fl
$matches[0]

#Mixing regex symbols:
#Any message that contains search database related messages:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "\(\d\d\d\d,\w,\d\d\)"} | select-object -first 5 | select eventid, message |fl

#Any defined or undefined multiplication of a symbol:
#Anything that looks like a stop code:
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "0x\d"} | select-object -first 5 | select-object -first 5 | select eventid, message |fl
#Atleast 2 slashes so a fileshare or absolute path
Get-EventLog -LogName application | where-object -FilterScript {$_.message -match "\\{2,}"} | select-object -first 5 | select-object -first 5 | select eventid, message |fl

#Split takes regex as a input to act on:
#View gateway information from route command:
(route print 0*) -split "\s" -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
#use –match ,  -replace and -split  all with regex to extract the lost packages from a ping
(ping 8.8.8.80 -n 1) -match "lost" -replace "Packets: Sent = \d+, Received = \d+," -split "\(\d+% loss\),"
"$((ping 8.8.8.80 -n 1))" -match "lost = \d+"
$matches[0]
#----------------
#reg expression groups
$Signature = @"
Janine Mitchell
Property Manager | West Region
Janine.Mitchell@ContosoSuites.com
"@ 

$Signature -match "\w+\.\w+@\w+\.com"
$matches[0]

#matches is a hash table
"contoso\administrator" –match "(\w+)\\(\w+)"
$matches
$matches[1]

"contoso\administrator" –match "(?<Domain>\w+)\\(?<UserName>\w+)"
$matches
$matches["UserName"] 

$str = "Henry Hunt"
$str -match "(\w+)\s(\w+)"
$matches
$str -replace "(\w+)\s(\w+)",'$2,$1'

#replace example
"Henry Hunt 11/23/1970" -replace "(\d+)/(\d+)",'$2/$1'

#By default $matches shows the full match as group 0 as long as the input is a single string. 
"The ip address 40.68.221.249 is also known as ??.in-addr.arpa" -match "\d+\.\d+\.\d+\.\d+"
$matches  #  -> Shows just group 0 

#If we start to group this $matches will show all the capture groups
"The ip address 40.68.221.249 is also known as ??.in-addr.arpa" -match "(\d+)\.(\d+)\.(\d+)\.(\d+)"
$matches  #  -> Shows all 4 octets of the IP address and the full match group 0
"The ip address 40.68.221.249 is also known as ??.in-addr.arpa" -replace "(\d+)\.(\d+)\.(\d+)\.(\d+)",'$1.$2.$3'
#Using Replace we can use this to our advantage to resequencing matches or text
"The ip address 40.68.221.249 is also known as ??.in-addr.arpa" -replace "(\d+)\.(\d+)\.(\d+)\.(\d+) is also known as \?\?.in-addr.arpa",'40.68.221.249 is also known as $4.$3.$2.$1.in-addr.arpa'

#We can also add a name to each group for reference with $matches
"The ip address 40.68.221.249 is also known as ??.in-addr.arpa" -match "(?<Octet1>\d+)\.(?<Octet2>\d+)\.(?<Octet3>\d+)\.(?<Octet4>\d+)"
$matches    # ->  This will now show all named groups and group 0 showing the full match

#Using Replace we can now create a simpler replace command
"The ip address 40.68.221.249 is also known as ??.in-addr.arpa" -replace "\?\?","$($matches.octet4).$($matches.octet3).$($matches.octet2).$($matches.octet1)"

#----------
#static methods
$Data = "1a2b3cd"
$Pattern = '\d'
[regex] | get-member -static
[regex]::match($Data,$Pattern).value
[regex]::matches($Data,$Pattern).value[0]
#additional symbols
# This is always true
"abc"    -match "\w*"
"baggy"  -match "b.*y" 

#and or
"Contoso.com" –match "\.(com|net)"
"Consoto.net" –match "\.(com|net)"

#begin statement ^
#Is this a UNC path?
'\\server\share\' -match '^\\\\(\w+)\\(\w+)' 
$matches
'C:\folder\' -match '^\\\\\w+' 
#end statement using $
"book" -match "ok$"

#demo
#We can extract an IP address using .NET framework regex class System.Text.RegularExpressions.Regex with short class name is [regex]. The overload match returns the first hit
[regex]::match((ipconfig.exe),"\d+\.\d+\.\d+\.\d+")

#The overload matches will return all results found 
[regex]::matches((ipconfig.exe),"\d+\.\d+\.\d+\.\d+")

#You can view the values direct by using dotted notation
([regex]::matches((ipconfig.exe),"\d+\.\d+\.\d+\.\d+")).value

#The object returned is a regex group just like $matches system variable
$result = [regex]::matches((ipconfig.exe),"\d+\.\d+\.\d+\.\d+")
$result[0].gettype()

#You can also use the grouping with this static method
$result = [regex]::matches((ipconfig.exe),"(\d+)\.(\d+)\.(?<One>\d+)\.(?<Two>\d+)")
$result.groups | ft

#As ipconfig is an array of strings trying to match multiple lines with ^ and $ won`t work 
[regex]::Matches((ipconfig.exe),"(?m)^\s+IPv.*")

#We need to convert the output of Ipconfig from array to a string with line formatting
$ipconfigstring = ipconfig.exe
[string]$ipconfigstring = ipconfig.exe | foreach-object –process {"$_`n"}
[regex]::Matches(($ipconfigstring),"(?m)^\s+IPv.*")  #      	-> start with IPv ignore white space show whole line
[regex]::Matches(($ipconfigstring),"(?m).*(\.240)$")	#	-> ending ip on 240  show whole line
[regex]::Matches(($ipconfigstring),"(?m)^\s+IPv.*|.*(\.240)$")	#-> start with IPv or ending ip on 0 ignore white space show whole line

#------
#select-string
#look for bugcheck
Get-EventLog -LogName application | Select-String -InputObject {$_.message} -Pattern "\dx\w\d+"
cd c:\data
Dir –recurse –Filter *.ps1 | Select-String -pattern 'OldAdminAccount'

$str = "Mr. Henry Hunt, Mrs. Sara Samuels, Ms. Nicole Norris"
$str -match "(Mr|Mrs|Ms)\. (\w*)\s(\w*)(, )?"
$matches
$str -replace "(Mr|Mrs|Ms)\. (\w*)\s(\w*)(, )?","`$3, `$2`n"
#ranges
"copy" -match "c..y"
"big"  -match "b[iou]g"
"and"  -match "[a-e]nd"
"and"  -match "[^brt]nd"
#looking for word character
"amcd efgk" -match "\w+"
$matches
#case sensitive not looking for word character
"amcd efgk" -match "\W+"
$matches
#number range
#[a-z] = matches any lowercase character between a to z
$text = @("www.microsoft.com", "www.Microsoft.com","contoso.com","Contoso.com")
[regex]::matches($text,"[a-z]icrosoft.com").value
[regex]::matches($text,"[t-z]icrosoft.com").value
#is case sensitive
[regex]::matches($text,"[A-Z]icrosoft.com").value
[regex]::matches($text,"[A-Z]\w+\.com").value
[regex]::matches($text,"[A-Zl-m]\w+\.com").value
[regex]::matches($text,"[A-Zl-m]\w+\.\w{3}").value
$text = @("www.1icrosoft.com", "www.8icrosoft.com")
[regex]::matches($text,"[1..5]icrosoft.com")

#endregion
#region jobs
#Please note that in order to run these commands on a Windows 10 Operating System it required to enable Remoting;
#Enable-PsRemoting

#Background Job:
#not working in ISE
Start-Job {Get-Service Spooler} | Out-Null
Get-Job
get-job -name  | Receive-Job

get-command -ParameterName asjob

#WmiJob :
Get-WMiObject –Class Win32_Service –Filter "Name='Spooler'" –AsJob | Out-Null

#RemoteJob: 
Invoke-Command -ScriptBlock {Get-Service Spooler} -AsJob -Session (New-PSSession) | Out-Null

Workflow Job:
Workflow Test {}; Test –AsJob | Out-Null

#Scheduled Jobs:
Register-ScheduledJob -ScriptBlock {Get-ChildItem} -Name Test -RunNow

#List the Jobs:
Get-Job

Start-job –ScriptBlock {Get-ChildItem -Path C:\ -Recurse}

#demo child job
Start-Job { Get-Service Spooler, FakeService } 
get-job -IncludeChildJob
$job = Get-Job 

#get output stream
$job.ChildJobs[0].Output

#get error stream
$job.ChildJobs[0].Error

#this fails in the ISE
cd c:\
get-job | Remove-Job
Start-Job { Get-ChildItem c:\data –Recurse –Filter *.vhdx } 
Get-Job | Wait-Job
Get-Job | Receive-Job

Get-Job | Receive-Job | get-member
#remote jobs
Invoke-Command -ComputerName dc1 -ScriptBlock {Get-EventLog -LogName System } -AsJob 
get-job | wait-job
get-job | receive-job

#schedule jobs
Invoke-Command -ComputerName dc1 -ScriptBlock {Get-EventLog -LogName System } -AsJob 
get-job | wait-job
get-job | receive-job

$trigger = New-JobTrigger –Daily –At "04:45:00PM"
$options = New-ScheduledJobOption -RunElevated
$credential = get-credential
Register-ScheduledJob `
–Name Test `
–Trigger $trigger `
–ScheduledJobOption $options `
-Credential $credential `
–ScriptBlock { Restart-Service DHCP –Force -Verbose} 

Get-ScheduledJob
Get-ScheduledJob | Get-JobTrigger | Disable-JobTrigger
Get-ScheduledJob | Add-JobTrigger –Trigger (New-JobTrigger –At "04/17/2017 04:00:00AM" –Once)
(Get-ScheduledJob).Options | Set-ScheduledJobOption –RunElevated:$false
Set-ScheduledJob –Name "Test" –Credential (Get-Credential)
Get-ScheduledJob | Set-ScheduledJob –FilePath "C:\Scripts\RunTask.ps1"
Get-ScheduledJob | Unregister-ScheduledJob
#region issues
#lab 2 excercise 5  receive-job not working without a get-job first
#endregion
#endregion
#endregion
#region day 3
#view default winrm endpoints
Get-PSSessionConfiguration | ft name, PSSessionConfigurationTypeName
new-item c:\data -ItemType Directory
cd c:\data

#Make sure the WINRM service is running
Get-service –name winrm      #-> If it has not started start it       
#if stopped run start-service –name Winrm

#Show the current Ps session configurations. Make sure you run PowerShell as administrator
Get-PSSessionConfiguration | ft name, PSSessionConfigurationTypeName

#Create a new JEA endpoint on a machine: 

#Create a new PS session configuration file
New-PSSessionConfigurationFile -SessionType RestrictedRemoteServer -Path .\MyJEAEndpoint.pssc 

#Register a new PS session using the just created file 
Register-PSSessionConfiguration -Path .\MyJEAEndpoint.pssc  -Name 'JEAMaintenance' -Force 

#Look at the WSMAN configuration / show some of the sub properties
Cd wsman:\localhost\plugin        #->  look at some sub folders 

#Remove the endpoint again
Unregister-PSSessionConfiguration -Name 'JEAMaintenance' -Force

#------- create a restricted
#Create a JEA session configuration file

#Create a JEA session configuration file with standard options
New-PSSessionConfigurationFile -Path "c:\data\MyJEAEndpoint.pssc"

#Create a JEA session configuration file with all options
New-PSSessionConfigurationFile -Path "c:\data\MyJEAEndpointfull.pssc" –full

#Open both files and show the difference in option logged in the files

#Copy the standard options file to use as a restricted file
Copy-Item -Path "C:\data\MyJEAEndpoint.pssc" -Destination "C:\data\MyJEAEndpointrestricted.pssc"

#Open the C:\MyJEAEndpointrestricted.pssc and change the session type to Restrictedremoteserver
SessionType = 'RestrictedRemoteServer'

#Create 2 new JEA endpoint on a machine: 

#Register a new PS session using the just created file 
Register-PSSessionConfiguration -Path "c:\MyJEAEndpoint.pssc"  -Name "JEADefault"

Register-PSSessionConfiguration -Path "C:\MyJEAEndpointrestricted.pssc"  -Name "JEARestricted"

#Restart WinRM to make the configuration active
Restart-Service –name winrm

#Show the configuration on both endpoints in different

#Connect to the default session
Enter-PSSession -ComputerName localhost -ConfigurationName "JEADefault"

#Run get command to show all available commands
Get-Command

#Disconnect from the session
Exit

#Connect to the Restricted session
Enter-PSSession -ComputerName localhost -ConfigurationName "JEARestricted"

#Run get command to show all available commands
Get-Command              -> Only 8 cmdlets should show up

#Run a cmdlet that not available
Get-host

#Disconnect from the session
Exit

#Re-Run a cmdlet that was not available but is in normal shell
Get-host

#----------------------demo role capability
#Start PowerShell as an Administrator.

#Create a new AD groups used to map the role capability to group
New-Adgroup –name "Role1" –groupscope "Global" –server "dc"

#Start winRM service if this is a client machine
Start-service –name Winrm                    #                 -> or start manual via services.msc

#Create a JEA session configuration file

#Create a JEA session configuration file with standard options
New-PSSessionConfigurationFile -Path "c:\Pshell\MyJEARoleEndpoint.pssc"

#Open the file and change the following role capabilities:

psedit "c:\Pshell\MyJEARoleEndpoint.pssc"

#Add /change the following role capability
SessionType = 'RestrictedRemoteServer'	#	->> Needed to get basic command instead of a empty shell
RoleDefinitions = @{ 'CONTOSO\role1' = @{ RoleCapabilities = 'role1'}}

#Register a new PS JEA session using the just created file 
Register-PSSessionConfiguration -Path "c:\Pshell\MyJEARoleEndpoint.pssc"  -Name "JEARoles" -Force 

#Restart WinRM to make the configuration active
Restart-Service –name winrm

#Create a new JEA role capability files: 

#File 1 – role 1
New-PSRoleCapabilityFile -Path c:\Pshell\role1.psrc

#Open the file and change the following keywords:

psedit "c:\Pshell\role1.psrc"

#Change the keyword Modulestoimport
Modulestoimport = 'Activedirectory'                     # -> Don`t forget to uncomment, Might need to update quotes if you copy paste
Visiblecmdlets =  'get-ad*'                                   #     -> Don`t forget to uncomment, Might need to update quotes if you copy paste

#Copy the file to the rolecapabilityfolder in the AD module directory
New-item –path "c:\windows\system32\Windowspowershell\v1.0\modules\activedirectory\Rolecapabilities" –type "Directory"
Copy-item –path "c:\Pshell\role1.psrc" –destination "c:\windows\system32\Windowspowershell\v1.0\modules\activedirectory\Rolecapabilities\role1.psrc"

#Show the configuration is different depending on group membership

#Connect to the JEA session
Enter-PSSession -ComputerName WIN10 -ConfigurationName "JEARoles"    #  	-> will fail as your not member of the AD group

#Add yourself to the group "Role1"
Add-adgroupmember –identity role1 –members power

#Re-Connect to the JEA session
Enter-PSSession -ComputerName WIN10 -ConfigurationName "JEARoles"

#Run get command to show all available commands
Get-Command	-> AD get commands should now be there

#Disconnect from the session
Exit

#Remove your self from the group
Remove-Adgroupmember –identity role1 –members power 		

#From the same shell Re-Connect to the JEA session
Enter-PSSession -ComputerName WIN10 -ConfigurationName "JEARoles"#		-> This should work as the enter-pssession reuses its session to connect on

#From a new shell Re-Connect to the JEA session
Enter-PSSession -ComputerName WIN10 -ConfigurationName "JEARoles"	#	-> This should fail as it creates a new session with new authorisation

#Disconnect from the session
Exit

#endregion
