#region Day 1
#what is Powershell

#PowerShell Versions
#PowerShell Core vs Windows PowerShell vs PowerShell 7.0

#.net framework differences

#ISE vs VSCODE

#how to install PowerShell Core
#how to install VSCODE

#Objects, Data types
get-help About_Objects

#what is an object
#What is a property
#what is a method
#what is a type

get-service | get-member
get-service | get-member -MemberType Property
#properties with just set are read only and get;set are read and write
get-service | get-member -MemberType method

#working with methods, brief intro dot notation
(get-service -name w32time).Stop()
$service = get-service w32time
$service | get-member
$service.start()
$service.refresh()
$service.Status

#even a string is a object / type
" " | get-member
("chad").EndsWith("ad")

1234 | get-member
12.456 | Get-Member

$true | get-member
$false | get-member

#cmdlet

#Has parameters and switches
get-service -name w32time #just param
stop-service -name w32time -Force #with switch

#find cmdlets
Get-Command #list all
get-command *-service #using wildcard
get-command get-* #using wildcard

get-service -name w*

#find commands by verb
get-command -Verb get
#find commands by noun
get-command -noun service
#find command by parameter 
get-command -ParameterName computername
#only show cmdlets
get-command -CommandType Cmdlet

get-command | group commandtype

#verb-noun
#cmdlets are made up of verb-noun
Get-Service #verb-noun
get-verb #show a list of recommended verbs

#Has parameters and switches
get-service -name w32time #just param
stop-service -name w32time -Force #with switch

#alias
get-help About_Aliases
get-alias
get-alias dir
get-alias ls

get-service | where-object {$name -eq "w32time"}

#should never have to use new-alias
new-alias -name bob -Value "get-service"
bob

#no way to clear alias
get-command *-alias*
#endregion

#region Day two

#top 10 cmdlets
Get-Help
Set-ExecutionPolicy
Get-ExecutionPolicy
Get-Service
ConvertTo-HTML
Export-CSV
Select-Object
Get-EventLog
Get/Stop-Process
Get-Member

#I would also add
get-command

#region learn about help
#How to use get-help
get-help -name Get-Service -Examples
get-help Get-Service -Full
get-help get-service -Detailed

#can also be used to learn about powershell topics
get-help about_*
get-help about_objects
get-help about_if

#endregion
#region learn about get-service

#cmdlet anatomy
#cmdlets are made up of verb-noun
Get-Service #verb-noun
get-verb #show a list of recommended verbs

#Has parameters and switches
get-service -name w32time #just param
stop-service -name w32time -Force #with switch

#risk mitigation parameter whatif or confirm
get-service -name w32time | Stop-Service -WhatIf

#using the get command
#find cmdlets
Get-Command #list all
get-command *-service #using wildcard
get-command get-* #using wildcard

#find commands by verb
get-command -Verb get
#find commands by noun
get-command -noun service
#find command by parameter 
get-command -ParameterName computername
#only show cmdlets
get-command -CommandType Cmdlet

#show-command is worthless

#find cmdlet syntax
get-command get-service -Syntax

#get-member
get-service | get-member
get-service | get-member -MemberType Property
#properties with just set are read only and get;set are read and write
get-service | get-member -MemberType method

#working with methods, brief intro dot notation
(get-service -name w32time).Stop()
$service = get-service w32time
$service | get-member
$service.start()
$service.refresh()
$service.Status


#pipeline
#pipeline is to pass an object returned from one cmdlet to another cmdlet
#powershell is optomized to run in the pipeline.
get-service | sort-object Name
get-service | group-object status
get-service | where status -eq "running" | out-gridview
get-service | select-object Name, Displayname, status | export-csv c:\data\allservice.csv

#format-list and format-table should only be used ever as the last cmdlet in a pipeline.
#it is only to show results in the console

#pipeline variable
# $_ is the default reference of the current object in the current pipeline
get-service | where {$_.name -eq "w32time"}
#can also name the variable for read ability
get-service -PipelineVariable service | where {$service.name -eq "w32time"}

#in Linux PS6
service --list-all | get-member #returns a string
service --list-all | select-string "ssh" -SimpleMatch

#function example
#use functions to reuse code
function get-disservice{
    param($servicename) #functions can leverage params, the name of the param is the variable in the function
    write-host "im running a function"
    get-service -name $servicename | where name -eq w32time | select displayname
}

get-DISservice -servicename w32time

#Execution Policy
#remote signed is the 
Get-ExecutionPolicy –List #shows which execution policy and where it is applied

#to create a script simply name the file with a ps1 extension

#modules are used to store multiple scripts in a single location

#endregion
#region learn about comments
<#
this is
a sample
of multiline
comments
#>
#step 1 connect to machine
#endregion
$random 

#static types
[guid] | get-member -Static
[guid]::newguid()
[datetime] | get-member -static
[datetime]::isleapyear(2022)
[datetime]::UtcNow

#powershell core has optimized improvements
#we ran this in the different versions
measure-command{1..10000 | write-host "$($_)"}

#one last note if a cmdlet has a filter object always use the filter

#VSC Code Collaberation we discussed as a capability but did not get the opportunity to go through

#remoting
#use this to run 1 to many
Invoke-Command -computername server1,server2 -ScriptBlock {get-service}
#use this to do more a one to one interactive
Enter-PSSession -computername server1
exit-psession
#showed you guys how to set up JEA, for least privilaged use
Get-PSSessionConfiguration

New-Item -Path "C:\JEAConfig" -ItemType Directory
New-PSSessionConfigurationFile -Path "C:\JEAConfig\JEADemo.pssc"
psedit "C:\JEAConfig\JEADemo.pssc"
New-PSSessionConfigurationFile -Path "C:\JEAConfig\JEADemo.pssc" -full
psedit "C:\JEAConfig\JEADemofull.pssc"
Copy-Item -Path "C:\JEAConfig\JEADemo.pssc" -Destination "C:\JEAConfig\JEARestrictedAdmin.pssc"
psedit "C:\JEAConfig\JEARestrictedAdmin.pssc"

#add the below in and replace the existing
<#
SessionType = 'RestrictedRemoteServer'
TranscriptDirectory = "C:\JEAConfig\Transcripts"
RunAsVirtualAccount = $true
RoleDefinitions = @{'Contoso\Basic Users' = @{ VisibleCmdlets =  'Get-Service',’Get-Process’,'start-service','stop-service','restart-computer'}}
#>

Register-PSSessionConfiguration -Name 'NonAdmin' -Path "C:\JEAConfig\JEARestrictedAdmin.pssc"
Enter-PSSession -ComputerName . -ConfigurationName NonAdmin


#OpenSSH in Windows
#ships in server 2019 as a feature and in windows 10 aprile 2018 update
#https://github.com/PowerShell/Win32-OpenSSH
#https://aka.ms/OpenSSHDocs 

#endregion
#region day 3
#Covered debugging.  We did not go through the complete exercise as it isnt as relateable
#focus was on using the toggle breakpoint where you want to stop the code. 
#and using the step in to go through each command

#using GIT  we didnt cover this section as not everyone used git and the ones who do didnt need it.
#did discuss considering setting up an additional repo to share scripts and modules
Register-PSRepository –Name PSPrivateGallery –SourceLocation "\\server\share" –InstallationPolicy Trusted –PackageManagementProvider NuGet `
-ScriptSourceLocation "\\server\share"

#one note to make, this require nuget to update.  may have to open and close console again for the newest version to appear.
Get-PSRepository

New-ScriptFileInfo C:\data\get-allservices.ps1 -version 1.0 -Author "chad.cox@microsoft.com" -Description "my first upload to the repo"

new-item -ItemType file -name get-allservices.ps1 -path c:\data
psedit C:\data\get-allservices.ps1
Test-ScriptFileInfo -Path C:\data\get-allservices.ps1

Publish-Script -Path C:\data\get-allservices.ps1 -Repository "PSPrivateGallery"
#make changes to the file
Publish-Script -Path C:\data\get-allservices.ps1 -Repository "PSPrivateGallery"

Register-PSRepository -PackageManagementProvider

Find-Script

#Here was my demo for Azure
#in azure you need to create each object that is used to build the server.  my demo used the defaults.
$RG = "Demoz"
$vmname = "MyTry"

#create Azure Resource Group
New-AzResourceGroup `
   -ResourceGroupName $RG `
   -Location "westus"

#tag the resource group
Set-AzResourceGroup -Name $RG -Tag @{ Dept="IT"; Environment="Test" }

#create VM's local admin account
$cred = Get-Credential

#get the different image publishers
Get-AzVMImagePublisher -Location "westus"



Get-AzVMImageOffer `
   -Location "westus" `
   -PublisherName "MicrosoftWindowsServer"

#get the different VM Size
Get-AzVMImageSku `
   -Location "EastUS" `
   -PublisherName "MicrosoftWindowsServer" `
   -Offer "WindowsServer"
 

#Create VM, let Azure create all the resources
#this will run the default version of windows
New-AzVm `
    -ResourceGroupName $RG `
    -Name $vmname `
    -Location "westus" `
    -VirtualNetworkName "mydemoVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "myDemoNetworkSecurityGroup" `
    -PublicIpAddressName "myDemopublicIpAddress" `
    -Credential $cred

#get the IP Address
Get-AzPublicIpAddress `
   -ResourceGroupName $RG  | Select IpAddress

#list all vm in resource group
Get-AzVM -ResourceGroupName $RG
#info about vm
Get-AzVM -ResourceGroupName $RG -Name $vmname

Stop-AzVM `
   -ResourceGroupName $RG `
   -Name $vmname -Force

Start-AzVM `
   -ResourceGroupName $RG `
   -Name $vmname

#We didnt spend to much time on Azure DSC because DSC wasnt introduced yet.

#Desired State Configuration
Set-Location c:\data

# The module that makes DSC possible
Get-Command -Module PSDesiredStateConfiguration

# Engine status
Get-DscLocalConfigurationManager

# No configuration applied
Get-DscConfiguration

# CTRL-J and select DSC Configuration (simple)
# Use CTRL-SPACE to invoke Intellisense on the resource keywords to find out their syntax

Configuration MyFirstConfig
{
    Node localhost
    {
        Registry RegImageID {
            Key = 'HKLM:\Software\Contoso'
            ValueName = 'ImageID'
            ValueData = '42'
            ValueType = 'DWORD'
            Ensure = 'Present'
        }

        Registry RegAssetTag {
            Key = 'HKLM:\Software\Contoso'
            ValueName = 'AssetTag'
            ValueData = 'A113'
            ValueType = 'String'
            Ensure = 'Present'
        }

        Registry RegDecom {
            Key = 'HKLM:\Software\Contoso'
            ValueName = 'Decom'
            ValueType = 'String'
            Ensure = 'Absent'
        }

        Service Bits {
            Name = 'Bits'
            State = 'Running'
        }

    }
}

# Generate the MOF
MyFirstConfig

# View the MOF

Get-ChildItem MyFirstConfig
notepad .\MyFirstConfig\localhost.mof

# Check state manually
Get-ItemProperty HKLM:\Software\Contoso
Get-Service BITS

# Check state with cmdlet
Test-DscConfiguration

# Sets it the first time
start-DscConfiguration -Wait -Verbose -Path .\MyFirstConfig

# Check state manually
Get-Item HKLM:\Software\Contoso
Get-Service BITS

# View the config of the system
Get-DscConfiguration

# Check state with cmdlet
Test-DscConfiguration

# Change the state
Set-ItemProperty HKLM:\Software\Contoso -Name ImageID -Value 12
New-ItemProperty HKLM:\Software\Contoso -Name Decom -Value True
Stop-Service Bits

# Check state manually
Get-Item HKLM:\Software\Contoso
Get-Service BITS

# View the config of the system
Get-DscConfiguration

# Do I have the registry key Is the value correct
Test-DscConfiguration

# Reset the state
Start-DscConfiguration -Wait -Verbose -Path .\MyFirstConfig

# Check state manually
Get-Item HKLM:\Software\Contoso
Get-Service BITS

# View the config of the system
Get-DscConfiguration

# Check state with cmdlet
Test-DscConfiguration

#endregion
#Current Issues----------------------
#in module 1 lab
#installing powershell core in ubuntu server doesnt work because its the wrong
#package need to change 18.04 to 16.04

#in module 3
#task wants you to open module 3 workspace.  no workspace is created so had them 
#add folder to workspace then samed the workspace

#Module 5, task 4 might be good to say on client 2. and they introduce 
#SSHD Config on Ubuntu, ubuntu1 is missing ssh in module 7 task 2
sudo apt update
sudo apt install openssh-server

#module 11
#when remotely applying the configuration to linux it asked for sudo and after about 1 hour on the lab we stopped.
#Working out the update.
