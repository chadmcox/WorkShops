#region my soap box
    #these are the core concepts
    #basic cmdlets
    ##get-command
    ##get-member
    ##get-help
    #Objects
    #working with cmdlets and objects in the pipeline.
    #once you get these focus on the scripting aspect of it.
#endregion

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
get-service | stop-service -WhatIf
restart-service -name w32time -confirm

#alias
get-help About_Aliases
get-alias
get-alias dir
get-alias ls

#should never have to use new-alias
new-alias -name bob -Value "get-service"
bob

#no way to clear alias
get-command *-alias*

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

#working with methods, brief intro
(get-service w32time).Stop()
$service = get-service w32time
$service.start()

#even a string is a object / type
" " | get-member

1234 | get-member
12.456 | Get-Member

$true | get-member
$false | get-member

get-command stop-service -Syntax
#Stop-Service [-InputObject] <ServiceController[]> 

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
#rarely used
new-variable -name constant_service -Option Constant -Value "abcdef"
#create a read only (can be forced to change
#rarely used
new-variable -name readonly_service -Option readonly -Value "tuvwx"
set-variable -name readonly_service -Value "abcd" -Force

#typing
[int]123
[int]"1234" 
$numbers = "1234"
[int]$numbers | get-member

#by default you do not need to type powershell figues this out.
$nonstrict = "ABC"
#trying to put a string in a variable typed for a int
[int]$strict = "ABC"

#"Quoting"
get-help About_Quoting_Rules

#literal strings
$service = (get-service -name w32time).name
$status = (get-service -name w32time).status
'$service is $status'
#Expanded strings
"$service is $status"

$service = get-service -name W32Time
write-host "Service: $service.name is in a status of $service.status"
write-host "Service: $($service.name) is in a status of $($service.status)"

#next line / line continuation 
get-service -name W32Time,netlogon | `
    select name, status | where name -ne "windows" | `
        export-csv c:\data\service_results.csv

#other things we discussed
#pipelines

#endregion
#region Day 2
get-help get-service -Examples
get-help get-service -full
get-help get-service -Detailed

get-help about_*
get-help about_WMI


#this is an example of how I would figure out how to look at a network adapter
#or find the cmdlets to disable the network adapter or change the ip address
#or dns settings.  instead of searching looking up using the get-command and get help

get-command Get-NetAdapter -Syntax
get-help Get-NetAdapter -full
get-netadapter | get-member
get-command *-netadapter*
get-netipaddress
Get-DnsClient | get-member


save-help -DestinationPath C:\data\helpsave
update-help -SourcePath c:\data\helpsave

#script blocks
get-help About_Script_Blocks
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
#functions are ideal for reusable code.  if you have to type anything more than once and if its more
#complicated or several repeated lines then a simple cmdlet consider putting in a function
get-help About_Functions

function get-aeroservice{
    $service = get-service -name w32time
    stop-service $service
    start-service $service
    write-host "$(get-service -name w32time)"
}
get-aeroservice
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
get-abcservice -name bob -something 2
#remoting
get-help About_Remote
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

#reusing persistant connections always faster than temporary connections
$sessions = new-pssessions -compuername dc1,app1
invoke-command -ScriptBlock {get-culture} -Session $sessions
#vs
invoke-command -ScriptBlock {get-culture} -computername dc1,app1

#core commands
get-help About_Core_Commands

#provider
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
#new reg key
new-item -Path HKCU:\ -Name Powershell
#new reg value
New-ItemProperty -Path HKCU:\Powershell  -Name registry1 -Value "NCC-1701"
New-ItemProperty -Path HKCU:\Powershell  -Name registry2 -Value "NCC-74656"
#change reg value
set-ItemProperty -Path HKCU:\Powershell  -Name registry1 -Value "NCC-1701-D“
#read reg key
Get-item –path HKCU:\Powershell
#rename a key
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

new-item c:\folder -ItemType Directory
new-item c:\data\something.txt -ItemType File

#scripts
#just save cmdlets in a file and save the file as a ps1

#execution policy remotesigned is default
get-help About_Execution_Policies
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
get-help about_requires
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


#endregion

#region day 3
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
1..6 -contains 5
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
get-help about_pipeline

get-service | where-object {-not ($_.name -eq "w32time")} | select-object name, displayname, state | Out-GridView


#filtering
#if a cmdlet has a -filter* parameter it is for a good reason use it
#always filter left to right

#filtering with wildcard with non filter parameters
get-service w* | select name, displayname, state
#bad
get-service | where {$_.name -like "w*"} | select name, displayname, status

#filtering with a filter param.  only returns the objects with bob as name
get-aduser -filter {name -eq "bob"} | select name
#this is bad, every user object gets past to the where cmdlet to be filtered
get-aduser -filter * | where {$_.name -eq "bob"} | select name

get-command -ParameterName *filter*

#endregion

#region day 4
get-help about_do
get-help about_while

# 5 loops
#while loop use to test condition if true run code in script block
#test condition again and repeat for as long as true
while($x -lt 15){

}
#do while use to run code in script block, then test condition
#if condition is true run script block again until condition is false
do {
    
}while($x -lt 15)
#do until is used to run code in a script block then test to see if a condition is false 
#run script block again, test condition, repeat on false exit with true.
do {

}until($x -gt 15)

# whiles need condition to be true to run script block and false to exit out of loop
# untils need condition to be false to run script block and true to exit out of loop

get-help about_for
# for is a loop where you initialize the counter, run the condition, and enumerate the counter
#at the begining, once the condition is no longer true then exit out of the loop
#this example is using the index of an object in an array or a particular item in a collection
$services = (get-service).name
$services.Count
#results will be the total count of objects in the variable
#only way to reference a particular object/item in an array or collection is by index position
#the very first itsm always starts with 0
$services[0]
#in this example there is 281 in the array so referencing index number 280 is the last object
$services[280]
#example of accessing what is object in index position 15
$services[15]
#back to the for loop.
# $i is set to 0.  the condition test to make sure the $i is less than 30
#if it is true then it runs the code in the script block, then it increments the $i using the $i++
#this  for loop I starts at 0 and will go to 29, each time it loops through the code block it will retrieve
#an item in the array by its index value
for($i=0;$i -lt 30; $i++){
    write-host "the current count is $($i) and the service name is $($services[$i])"
}

get-help about_foreach
#use foreach to loop through each object in an array or item in a collection
#each item gets assigned to a variable  for easy reference
#Ideally store objects in an array if you are building the array or if the datastore 
#or object collection is huge or takes a while to retrieve like get-aduser -filter *
$services = get-service 
foreach($service in $services){
    get-service $service
    stop-service $service -WhatIf
    Start-service $service -WhatIf
}
#if something local other than event logs can call directly, not ideal but possible keep in pipeline
foreach($service in get-service){
    get-service $service
    stop-service $service -WhatIf
    Start-service $service -WhatIf
}

#!!!!best way, always keep in pipeline if you can
#if you are enumerating objects from a get cmdlet keep it in the pipeline #
#and use foreach-object use the pipeline variable to give you the easy to use variable of the instance
get-service -PipelineVariable service | foreach-object{
    get-service $service
    stop-service $service -WhatIf
    Start-service $service -WhatIf
}

#!!!! reminder in ISE right click select snipet will give you a quick template of each loop type
#ctrl + j does as well

get-help about_if
#flow control or condition statements.
#us if statement to test a condition for true and then run a particular set of code in a script block
#can test multiple conditions and also provide a consolation or default condition if none of the others where true
#in a if statement only 1 condition can be true, the first one that is true is the only one ran
#so if more than 1 is true the first one meet is all that is ran against.
#if using several condition statement or elseif try to limit to a few if multiple use a switch (select case) instead

#basic
if($a -eq 6){
    write-host '$a is equal to 6'
}
#in some cases you just might need to check if a variable contains something or an object is retrieved.
#in this example going to use -not or ! to reverse to make False be True
#so if $a is null it will be true and run the script block
$a = ""
If(!($a)){
    $a = 5
}
#this example looks for a directory.  by default only if the directory is there will
#it return true.  But using the -not / ! to reverse so the directory not being there
#returns true and then runs the code in the script block which in this case creates the directory.
if(!(test-path c:\data1)){
    new-item c:\data1
}
#more advance
$a = 6
if($a -gt 3){
    write-host "Greater than 3"
}elseif($a -lt 7 -and 5 -gt 7){
    write-host "Less than 7 and greater than 5"
}elseif($a -eq 6){
    write-host "is equal to 6"
}else{
    write-Host "isnt any of the other conditions"
}
#the first condition meet is the only one returned
#answer Greater than 3
#if I change $a to = 3
#this will return the default of "isnt any of the other conditions"
#if changed to 6, where it matches two conditions will return the first 1
get-help about_switch
#a switch is just like if
#each condition that is meet will run
$number = 5
switch ($number){
    1 {write-host "number is 1"}
    3 {write-host "number is 3"}
    {$_ -lt 10} {write-host "$($_) is less than 10"} 
    5 {write-host "number is $($_)" -ForegroundColor yellow}
}

#array
#arrays are a collection or multiple objects, pretty much everything you do in powershell
#involves working with an array
#arrays are easy are easy to assign
$service_array = get-service
#by default $service_array contains multiple objects

$array_of_numbers = 1,2,3,4,5,6,7

#to add to an array use
$array_of_numbers += 8

#it is not easy to find objects in an array.  only way to reference them is by their position
$array_of_numbers[0]
#returns 1 which is the first item in the array
$array_of_numbers[4]
#returns 5
#you can use -1 to return the last item
$array_of_numbers[-1]
$array_of_numbers[0..5] #works shows the first 6 entries
$array_of_numbers[0,-1] #shows first entry and last entry in array

#hashtable
#declares its going to contain or be a hash table
$hash_services = @{}
#each item in the table is a name = value combo
$Server = @{'computername'='HV-SRV-1'; 'ipaddress'='192.168.1.1'; 'Memory'=64GB ; 'Serial'='THX1138'}   
#can easily add and remove entries from hashtable
$server.add('model','hp')
$server.Remove("model")
$Server["CPUCores"] = 4
$Server.Drives="C", "D", "E"

#values in hash tables can be referenced by name.  does not use index number
$server['computername'] 
$server['memory']

#use group-object auto store data returned from a cmdlet into a hash table for quick 
#lookups vs storing in an array
$svcshash = Get-Service | Group-Object name -AsHashTable -AsString 
$svcshash['w32time']

#hashtable splatting
#allows you to create a hashtable where the names are the parametername and 
#the value is the value you want to call out for the parameter

#normal way to pass params
get-eventlog -LogName 'application' -Newest 10 -EntryType Warning 

#defining splat hashtable
$params = @{
  LogName      = "application"
  Newest       = 10
  EntryType    = "Warning"
}
#instead of using $ use @ for the hashtable name and the cmdlet will match up the parameters
Get-EventLog @Params 
#I would use to to simplify cmdlets if I am typing multiple times in the cli or to make scrpt

#Calculated properties
#i use this a lot, specifically for creating reports.  this allows me to run other things and 
#add additional properties to an object
#can just rename a property
get-service | select name, @{Name="Service State";Expression={$_.status}}
#perform a task and create a property in the object with the results of that task
#this will return all services and for each service will look to see if the name on the service
#matches a name of a process and will return true in the property if it does.
get-service | select name, `
    @{Name="is service names same as process name";Expression={if(get-process $_.name){$true}}}

#endregion



#region --------------------Example/DEMO SCRIPT --------------------------------------------
#Requires -version 5.0
<#
.Author
    Chad
.version
    2019.10.10.1

.description

.example

#>
#region variables
$path = c:\data\logs
$error_threshold = 0
$packages = "pack1.msi","pack2.msi"
#endregion
#region functions
function uninstall-packages{
    param()


}
function install-packages{
    param($packagename)
    invoke-expression -Command "msiexec $packagename -i -w"

    return $LASTEXITCODE
}
function check-eventlogs{
    $events = get-winevent -FilterHashtable @{logname='system';id=16}
    if($event | where description -like "*something*"){
        return $true
        }
}
#endregion
#region main
if(!(test-path $path)){
    new-item $path -ItemType Directory
}

foreach($package in $packages){
    $results = install-packages -packagename $package
    if(!($results -in 0,3010)){
        check-eventlogs

    }
    exit $results
}

#endregion

#endregion

#region random example ---------------------------
#how to read prompt user for something and read in input from user
$results = Read-Host -Prompt "do you want to do something y or n"
if($results -eq "y"){

}

#also talked about how in powershell you can leverage .net assemblies and create a gui
# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
# Create a new form object this is just like any other object that has properties and methods
$LocalPrinterForm   = New-Object system.Windows.Forms.Form

#run get-member to take a look
$LocalPrinterForm| get-member

#we are creating a new form object so need to define some of the properties first
# Define the size, title and background color
$LocalPrinterForm.ClientSize         = '500,300'
$LocalPrinterForm.text = "LazyAdmin - PowerShell GUI Example"
#then load the object
[void]$LocalPrinterForm.ShowDialog()


#endregion
