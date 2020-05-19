#region day 1
#version of powershell
Get-Host
#PowerShell that is preinstalled on Windows is Windows PowerShell the last release was 5.1
#Windows Powershell 
#This gets updated as part of the windows management framework
#https://www.microsoft.com/en-us/download/details.aspx?id=54616

#Powershell core is open sourced multiple operating systems
#https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6

#PowerShell 7 is just PowerShell and is the latest release
#


#get-history
$MaximumHistoryCount #4096 is the default
get-history
(get-history).CommandLine
(get-history).CommandLine | add-content c:\data\history.ps1

#collapsible code
<#regions#>
#region example

#endregion

#commands opens in seperate process
ping 192.168.1.20
#cmdlets runs in same powershell process.
Test-NetConnection -ComputerName 192.168.1.20

#cmdlets are made up of verb-noun
Get-Service #verb-noun
get-verb #show a list of recommended verbs

#Has parameters and switches
get-service -name w32time #just param
stop-service -name w32time -Force #with switch

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
get-command -CommandType Alias

#show-command is worthless

#find cmdlet syntax
get-command get-service -Syntax

get-service -name AarSvc_8efc3, w32time, netlogon -ComputerName DC1,DC2,DC3

#risk mitigation parameters
restart-service -name w32time -WhatIf
get-service | restart-service -whatif
restart-service -name w32time -confirm

#alias
get-help About_Aliases
get-alias
get-alias dir
get-alias ls

#should never have to use new-alias
new-alias -name test -Value "get-service"
test

#no way to clear alias
get-command *-alias*

#new line or backtick try to keep the amount of characters to a line to about 150 use ` backtick for the next line
get-service -name AarSvc_8efc3, AJRouter,Appinfo,AppReadiness,AppMgmt,AppMgmt,AppMgmt | `
    where-object status -eq "running" | Select-Object name, status | `
        export-csv c:\data\results.csv -NoTypeInformation 


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

get-command stop-service -Syntax
get-process | stop-service -WhatIf

#object returned is a type System.ServiceProcess.ServiceController
#more about this type
#https://docs.microsoft.com/en-us/dotnet/api/system.serviceprocess.servicecontroller?view=dotnet-plat-ext-3.1

#even a string is an object / type
"my name is chad" | get-member

#dot notation, this is the ability to access a property or call an objects method directly
#using parenthesis
(get-service -name w32time).Stop()
get-service -name w32time
(get-service -name w32time).Start()
get-service -name w32time
(get-service -name w32time).Status

Start-Process notepad
(Get-Process -name notepad).kill()
Get-Process -name notepad | Stop-Process

#store object in a variable reference that way
$service = get-service -name w32time #get service object
#or
get-service -name w32time -OutVariable service

$service | get-member

$service.status #show just the current status
$service.stop() #stop the service
(get-service -name w32time).status #show the actual service status
$service.status #show the object stored in variable status
$service.Refresh()
$service.Start() #start the service
(get-service -name w32time).status #show actual status
$service.Refresh() #update object in variable to reflect new status


#variable
#always name variables describing what it contains
#variables start with a $

Get-Help about_Automatic_Variables
get-help about_Variables

#display all variables
Get-Variable

#user defined variable
$chad = "this is my name"
$chad | get-member
$randomnumber = 12345
$randomnumber | get-member

#make sure to name variables using readable names, for readability try not to use generic terms
$blah = get-service #example of bad name
$services = get-service
$time_service = get-service -name w32time
$string_name = "Chad"
$strname = "Chad"
$first_name
$firstname

#create a constant variable not able to change
new-variable -name constant_service -Option Constant -Value "abcdef"
#create a read only (can be forced to change
new-variable -name readonly_service -Option readonly -Value "tuvwx"
set-variable -name readonly_service -Value "abcd" -Force

#"Quoting"
get-help About_Quoting_Rules

#literal strings
write-host 'my name is chad'
$name = "Chad"
write-host 'my name is $name'
#Expanded strings
write-host "my name is $name"
$service = get-service -name w32time
write-host '$service.name is currently $service.status'
write-host "$($service.name) is currently $($service.status)"
write-host "$((get-service -name w32time).name) is currently $((get-service -name w32time).status)"
"$((get-service -name w32time).name) is currently $((get-service -name w32time).status)" | out-file c:\data\status.txt

#endregion
#region day 2
#Type
#there are times you may need to change a value to a spcific type
#This examples shows a guid sitting in a string, the type is a string
"23b62876-f4a8-453e-b54a-a06b1468a30b" | get-member
#Able to cast the string as a guid type
[guid]"23b62876-f4a8-453e-b54a-a06b1468a30b" | get-member

#example with int
"12345"  | get-member
'12345'  | get-member
[int]'12345' | get-member
[int]$randomnumber = 12345

1234 | get-member
[double]1234.5 | get-member
#notice how when this rounds it switches based on odd and even whole number
[int]1.5
[int]2.5
[int]3.5
[int]4.5

#leverage static type methods to gain additional capability
[guid] | get-member -Static
[datetime] | get-member -Static
[datetime]::IsLeapYear(2020)
[datetime]::IsLeapYear(2021)
[datetime]::IsLeapYear(2019)
[datetime]::daysinmonth(2020,12)

[System.Net.Dns] | get-member -Static

#help
#only covering get-help we will discuss function and script help after we introduce those topics
get-help get-service
get-help get-service -Examples
get-help get-service -Detailed
get-help get-service -full
get-help get-service -Parameter name
get-help get-service -online

get-help about_*
get-help about_variable 
get-help about_variable -ShowWindow

update-help -Force
save-help c:\data\savefiles
update-help c:\data\savefiles

#functions / script block
#basic form of a script block
{


}
#some cmdlets contain script blocks
Get-command –parametername scriptblock

Measure-Command -Expression {
get-service
get-process
}

Invoke-Command -ScriptBlock {
    get-service
    get-process
} -ComputerName dc1

start-job -ScriptBlock {
    get-service
    get-process
}
#conditional statements and loops use script blocks
if($something -eq $true){

get-service

}
#functions use script blocks
#functions are in essence a named script block
#that is also reusable
#functions have to be read into the script first before they can be referenced
#Powershell you usually want to define a function at the top of the script

function get-w32timeservice{
    get-service -name w32time
}
#how to call to a function

get-w32timeservice
#example of a function with parameters
#notice the variables defined in the param()  they also act as the named parameters for the function\
#when a value is passed to the named value it is stored inside the function in the associated variable
#When naming functions always use something friendly do not use the name of something already in use.

function get-ABCService{
[cmdletbindings()]
    param($servicename,$computername="localhost",$status,[switch]$enforce)
    if($enforce -eq $true){
        if((get-service -name $servicename -computername $computername).status -eq $status){
            write-host "$servicename from computer $computername is $status"
        }
    }

}
#calling a function with parameters
get-ABCService -servicename W32time -computername dc1 -status "Running" -enforce
get-ABCService -servicename W32time -computername dc1 -status "Running" -enforce
get-ABCService -servicename W32time  -status "Running" -enforce
#demo of using credentials with functions
#region function
function do-something{
    param([System.Management.Automation.PSCredential]$credential)

    Invoke-Command -ScriptBlock {get-culture} -Credential $credential
}


#endregion


#region main code

do-something

$cred = (get-credential)

do-something -credential $cred
#endregion

#remoting
#some cmdlets have builtin native remote capability
#use get-command with the following parameter to retrieve cmdlets that use this capability
get-command -ParameterName computername
get-service -ComputerName contoso-dc1
Get-Process -ComputerName contoso-dc1
get-hotfix -ComputerName contoso-dc1

#interact with a connection to a remote computer
Enter-PSSession -ComputerName contoso-dc1 #192.168.0.95
Exit-PSSession

#show the syntax options for invoke-command
get-command invoke-command -Syntax

#temp connection to computer run a command against a single or many machines 
invoke-command -ComputerName "contoso-dc1","contoso-dc2","contoso-app1" -ScriptBlock {ipconfig}
invoke-command -ComputerName "contoso-dc1" -ScriptBlock {ipconfig}

#also can run a local script against remote computers
invoke-command -computer "contoso-dc1" -FilePath c:\data\remotescript.ps1

#pass credentials
#Here is a list of cmdlets that allow you to pass creds
Get-Command -ParameterName credential

#use alternate creds, it will prompt to enter a password
Enter-PSSession -ComputerName contoso-dc1 -Credential "contoso\adminbob"
Exit-PSSession

#proactively store a credential object and use it when making connections
$cred = get-credential
Enter-PSSession -ComputerName contoso-dc1 -Credential $cred
Exit-PSSession

Invoke-Command -ComputerName contoso-dc1 -ScriptBlock{get-culture} -Credential $cred

#creating a reusable session
Get-PSSession #retrieve existing sessions
$comp1 = New-PSSession -ComputerName contoso-dc1
Get-PSSession #retrieve existing sessions should now see at least one
#interactively connect to the session
enter-pssession -Session $comp1
exit-pssession
#run quick cmdlet against session
Invoke-Command -Session $comp1 -ScriptBlock {get-culture}
#by default wsman or powershell remoting has 4 runspaces to remote connect to
#use this to view the configuration of the runspaces
Get-PSSessionConfiguration

#providers
#providers are installed by default and also as part of modules
#providers give powershell the ability to navigate and interface with certain
get-help About_Providers
#data structures as if it is a file system drive
get-psprovider
#get drives already mounted using the providers
get-psdrive
#mount a new drive with a provider
New-PSDrive -Name x -PSProvider FileSystem -Root c:\windows
#network share
New-PSDrive -Name h -PSProvider FileSystem -Root \\memberserver\share

get-command *psdrive # list the cmdlets around psdrive

#commandlets used to work with psdrives
get-command *item* -module Microsoft.PowerShell.Management
#change current location like cd
Set-Location c:\windows
#list all the items inside a folder
Get-ChildItem -Path C:\Windows
#copy
Copy-Item c:\Logs -Destination d:\Logs –Recurse
#working with the registry and key values
new-item -Path HKCU:\ -Name Powershell
New-ItemProperty -Path HKCU:\Powershell  -Name registry1 -Value "NCC-1701"
New-ItemProperty -Path HKCU:\Powershell  -Name registry2 -Value "NCC-74656"
set-ItemProperty -Path HKCU:\Powershell  -Name registry1 -Value "NCC-1701-D“
Get-item –path HKCU:\Powershell
Rename-ItemProperty -Path HKCU:\Powershell -Name registry1 -NewName Ship1
Rename-ItemProperty -Path HKCU:\Powershell -Name registry2 -NewName Ship2
Get-item –path HKCU:\Powershell
new-item -Path HKCU:\ -Name "Intrepid"
new-item -Path HKCU:\ -Name "Galaxy"
Copy-ItemProperty -Path HKCU:\Powershell -Destination HKCU:\Intrepid -Name Ship2
Move-ItemProperty -Path HKCU:\Powershell -Destination HKCU:\Galaxy -name Ship1
Get-item –path HKCU:\Intrepid
Get-item –path HKCU:\galaxy
Remove-ItemProperty -Path HKCU:\Galaxy -Name Ship1
Remove-Item -Path HKCU:\Galaxy
Remove-Item -Path HKCU:\Intrepid 
#adding and reading from file
Add-Content -Value "this will be added to a file" -Path c:\data\file.txt
get-content -Path c:\data\file.txt
#path cmdlets
get-help about_Locations
test-path -Path c:\data\file.txt
split-path -Path c:\data\file.txt -Parent
split-path -Path c:\data\file.txt -leaf
set-location c:\data
#using the sqlserver provider
#https://docs.microsoft.com/en-us/sql/powershell/navigate-sql-server-powershell-paths?view=sql-server-ver15

#Scripts
#save a file as a .ps1, runs the list of cmdlets into a powershell script
#execution policies
get-help about_Execution_Policies
#When running a script locally or remotely against a computer
#need to be mindful of the execution policy that is assigned
#to that computer
#to view a computers execution policy
Get-ExecutionPolicy -List
#there are 4 options Restricted, AllSigned, Remotesigned and unrestricted
#default starting in 2012r2 and beyond is remotesigned
#you can change the policy via group policy or using the below cmdlet with the policy you want to pass to it
Set-ExecutionPolicy -ExecutionPolicy Undefined
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
#the powerpoint student slides have instructions on how to sign a script
#Requires
get-help about_requires
#these are used to make sure powershell has the things needed to run the script successfully
<#the most common ones and they must be the first lines of the script
#Requires -Version 3.0 *any version
#Requires -Modules sqlserver, activedirectory *list the modules required
#Requires -RunAsAdministrator *if the powershell session needs to be ran as admin
#>
#command lookup Precedence
#full path / alias / function / cmdlet / external commands
#try not to create an alias that is already used by something else
#try not to create a function name that is used by something else
#endregion
#region day 3
#Powerhsell does not use =,<,>,==
# -eq for equals
1 -eq 1
$emptyvariable -eq $true
$emptyvariable -eq $false
# -ne for not equals
2 -ne 5
# -gt for greater than or -ge for greater than or equal to
4 -gt 2
5 -ge 5
# -lt for less than or -le for less than or equal to
4 -le 9
#case sensitive versions are available with prefixing with a
# c, example -ceq, -cne   also lower case if needed
#wild card
# -like  * (astricks) is used for wild card before or after
"elephant" -like "*ph*"
$emptyvariable -like "*"

# -match is used with regex where you are looking for a string match

#array containment
$services = (get-service).Name
#does array contain w32time
$services -contains "w32time"
#is w32time in the array
"w32time" -in $services

#logic operators
# -and 
(2 -eq 2) -and (3 -eq 15)
# -or
(2 -eq 2) -or (3 -eq 15)
# -not (reverse results)
-not (2 -eq 2)
!(2 -eq 2)
#example if the variable is empty make results true 
#so that we can put something in the variable
if(!($emptyvariable)){
    $emptyvariable = "not empty anymore"
}

#Numeric range operator
1..6
1..1000
1..-100
#character relies on regex
#example this will retrieve all files/folders that start with j or z
Get-ChildItem C:\windows\System32\[jz]*
#from a to c
Get-ChildItem C:\windows\System32\[a-c]*

#byte multipliers
#use kb,mb,gb,tb
$size = 123456789
$size / 1KB
$size / 1MB
$size / 1GB
$size / 1TB
$size / 1PB

#Pipeline
#Series of commands connected by the pipeline character.
#Powershell is optimized to work in the pipeline
get-service -name w32time | Stop-Service
#the goal is to get an object and then do something with that object
#As powershell is retrieving each object it passes the object to the next commandlet
#External cmds can be used in the pipeline

#example read from text file
(get-service).name | out-file c:\data\servicesname.txt
get-content c:\data\servicesname.txt | get-service

#pipelines usually start with a get cmdlet

#Common object cmdlets
#soft-object allows you to sort objects based on a property
get-service | sort-object name 
get-service | sort-object status -Descending

#select-object selects objects properties
get-service | select name, status
#notice the rest of the objects properties and methods no longer show after a select
get-service | select name, status | get-member

#group-object groups object by a property and also shows counts of those groupings
get-service | group-object status

#measure-object great to get a count of objects
get-service | measure-object 

#format is always the last cmdlet on a pipeline and should only be used to help format results on the screen
get-service | format-list
get-service | format-table
#this helps with the full data not showing
get-service | Format-Table -Property name, displayname, status -AutoSize
get-service | Format-Table -Property name, displayname, status -AutoSize -wrap

#this is one of my most common used cmdlets
#export-csv is used to write objects properties to a csv 
get-service | select name, displayname, status | export-csv c:\data\services.csv
#by default the data will export and will include info about the object type
#if you dont plan on importing the data then use the notypeinformation switch to leave that out of the csv file
get-service | select name, displayname, status | export-csv c:\data\services.csv -NoTypeInformation
#Export-Clixml is used for xml import
#it is also possible to import the csv file as an object
#import-csv
import-csv c:\data\services.csv | restart-service -whatif

#there are a few out-* cmdlets that are useful in the pipeline
get-command out-*
# Out-file Sends output to a file similiar to add-content and set-content
ipconfig | out-file c:\data\ipconfig.txt
get-services | select-object name, status | out-file c:\data\services.txt # writes to file just like seen on the screen

#out-gridview
get-service | select name, status | Out-GridView
#can use for filtering as well using passthru, usually the out-* are the last cmdlet in pipeline
get-service | Out-GridView -PassThru

get-command -ParameterName passthru

#pipeline variables
#the current object in the pipeline can be references by $_
get-server | where-object {$_.name -eq "w32time"}

#being able to reference specific properties allows you do do additional things like filter

#it is also possible to name the pipeline variable for read ability and to be able to to work with multiple nested pipelines
#each cmdlet should have a common parameter called -pipelinevariable
get-process | export-csv c:\data\process.csv
get-service -PipelineVariable service | foreach{
    import-csv c:\data\process.csv -PipelineVariable process | where {$service.name -eq $process.name}
} 
#note I am able to reference two different objects one in the main pipeline and then the pipeline in the foreach
#because powershell runs faster in the pipeline leverage the foreach-object cmdlet if you need to process multiple things 
#to an object
get-service | foreach{
    $_ | stop-service
    $_ | start-service
    write-host "just restarted $($_.name)"
}

#use the where-object to filter
#!!!!!important if a cmdlet has an option to filter, use it before using the where-object
get-service | where-object status -eq "Running" #possible with powershell 3 or newer

#if neededing to something a little more complext use
get-service | where {$_.name -like "w*" -and $_.status -eq "Running"}
#once again for better performance consider using
get-service -name w* | where status -eq "running"

#using begin, process and end in foreach
get-process | foreach -Begin {
    #establish connection to a database
    #runs when the first object comes through
} `
-process{
    #write each object results to database
} `
-end{
    #close connection to database
    #only runs after the last object
}

#How do I know what type of object a cmdlet will accept
get-command restart-service -Syntax
#Restart-Service [-InputObject] <ServiceController[]>
#this will let you know the type of object and if it takes and object

#you can also see is certain paramaters will accept a property or object value
Get-Help Restart-Computer -Parameter ComputerName
#Accept pipeline input?       True (ByPropertyName, ByValue)

#powershell does arithmetic operators
1 + 1
3 - 1
3 * 5
15 / 3

#assignment operators
$value = 10
$value
$value += 10
$value
$value -= 10
$value
$value *= 10
$value
$value /= 10
$value
$value %= 2
$value

#endregion
#region day 4
#endregion
