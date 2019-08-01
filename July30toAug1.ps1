
#region day 1
#version of powershell
Get-Host
#Powershell core
#https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6

#Windows Powershell
#This gets updated as part of the windows management framework
#https://www.microsoft.com/en-us/download/details.aspx?id=54616

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

#show-command is worthless

#find cmdlet syntax
get-command get-service -Syntax

#risk mitigation parameters
restart-service -name w32time -WhatIf
restart-service -name w32time -confirm

#alias
get-alias
get-alias dir
get-alias ls

#should never have to use new-alias
new-alias -name test -Value "get-service"
test

#no way to clear alias
get-command *-alias*

#Objects, Data types
#what is an object
#What is a property
#what is a method
#what is a type

get-service | get-member
get-service | get-member -MemberType Property
#properties with just set are read only and get;set are read and write
get-service | get-member -MemberType method

#even a string is a object / type
" " | get-member

#variable
#always name variables describing what it contains
#variables start with a $

Get-Help about_Automatic_Variables
get-help about_Variables
#display all variables
get-variable
#user defined variable
$service = get-service -name w32time
#create a constant variable not able to change
new-variable -name constant_service -Option Constant -Value "abcdef"
#create a read only (can be forced to change
new-variable -name readonly_service -Option readonly -Value "tuvwx"
set-variable -name readonly_service -Value "abcd" -Force

#literal strings
$name = "Tom"
'My name is $name'
#Expanded strings
"My Name is $name"

$service = get-service -name W32Time
write-host "Service: $service.name is in a status of $service.status"
write-host "Service: $($service.name) is in a status of $($service.status)"

#next line / line continuation 
get-service -name W32Time,netlogon | `
    select name, status | where name -ne "windows" | `
        export-csv c:\data\service_results.csv

#endregion

#region day2

#my opinion: basic pipeline should be taught here

#help
get-help about_help

get-help get-service -Examples
get-help get-service -full
get-help get-service -Detailed


get-help about_*
get-help about_WMI

save-help -DestinationPath C:\data\helpsave
update-help -SourcePath c:\data\helpsave

#script blocks
#script blocks are areas within cmdlets, conditional statements, and functions
#that allow you to type additional statements that need to be run inside of the cmdlet, function, statement
#script block statements exist between {} braces
#example
Measure-Command -Expression {get-service <#this is a cmdlet not a string#>}
invoke-command -ComputerName DC1 -ScriptBlock {get-service <#this is a cmdlet not a string#>}
#script block in conditional statements
if(2 -gt 4){ #start script block
    #Code that needs to run in script block
    get-service
} #end script block
#script block example for function
function scriptblockexample {
    #Code that needs to run in script block
    get-service
}

#functions
#functions when creating always have to start with the word function, then must contain a name 
#for the function, then has code that inside script blocks
#functions are idea or reusable code.  if you have to type anything more than ones and if its more
#complicated or several repeated lines then a simple cmdlet consider putting in a function
function get-abcservice{
    $service = get-service -name w32time
    stop-service $service
    start-service $service
    write-host "$(get-service -name w32time)"
}
#function with parameters
#parameter names are defined like variables must be contained within a param() statement
function get-abcservice{
    param($name,$something,$blah)
    $service = get-service -name $name
    stop-service $service
    start-service $service
    write-host "$(get-service -name $name)"
    write-host "$something"
    write-host "$blah"
    return $blah
}
#remoting
#cmdlets that use -computername are not using windows remoting
get-command -ParameterName computername
#example
get-service -name w32time -ComputerName dc1
#interactive remote session
enter-pssession -ComputerName dc1
#run cmdlets, once done use
exit-psesssion
#when just needing to run one cmdlet that doesnt have built in remoting
invoke-command -ComputerName dc1 -ScriptBlock {get-childitem c:\data}

#provider
#providers are installed by default and also as part of modules
#providers give powershell the ability to navigate and interface with certain
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
test-path -Path c:\data\file.txt
split-path -Path c:\data\file.txt -Parent
split-path -Path c:\data\file.txt -leaf
set-location c:\data

#scripts
#just save cmdlets in a file and save the file as a ps1

#execution policy remotesigned is default
Get-ExecutionPolicy
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy Undefined

#-----single line comment
<#
Multi line comment
 goes in
 here
#>

# Requires statements go at the very top of a script
# most common are:
#Requires -modules azure
#Requires -runasadministrator
#Requires -version 3.0

#Command Precedence
#Full path
#Alias
#Function
#cmdlet
#External command (like ping)
#Example:
new-alias -name ping -Value "test-netconnection"
ping 192.168.1.2

#Operators
get-help About_Operators

#comparison operators

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

#endregion

#region day 3

#endregion
