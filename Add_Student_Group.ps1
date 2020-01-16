<#
.SYNOPSIS
This Powershell script adds the Active Directory group Student_Reset for users with the appropriate job role 

.NOTES
This is being done as these particular roles should automatically have this security group
Author: Josh Gold
#>

##################################################
# Start logging the script results to a text file
Start-Transcript -Path "E:\Output\Student_Reset.txt" -Append

Import-module ActiveDirectory

#switch to AD drive for better performance
set-location ad:

#variables we will be using
$user_department = ""
$student_reset_group = "STUDENT_RESET"
$student_reset_group_members = ""
$student_reset_staff =""
$student_reset_total_users = 0
$student_reset_added_users = 0

# Get enabled staff accounts who should get Student Reset group
$student_reset_staff = get-aduser  -searchbase "OU=PPS,DC=AD,DC=ppsnet" -Filter { ((idAutoPersonPositionCode -eq "SECTY") -or (title -like "*Library Assistant*") -or (title -like "*Media Specialist*") -or (title -like "*Instr Technology Asst*") -or (title -like "*Instr Spec*")) -and (LocationNumber -ne "500")  -and (Enabled -eq "true") } # | export-csv -path E:\output\student_reset.csv

# Get group members for Student_Reset group
$student_reset_group_members = Get-ADGroupMember -Identity $student_reset_group -Recursive | Select -ExpandProperty SamAccountName

# Add Student_Reset group for people in our array that do not already have it
foreach ($user in $student_reset_staff) {
    if ($student_reset_group_members -contains $user.SamAccountName) {
        #write-host "$user exists in $student_reset_group already"
        $student_reset_total_users++
    }
    else {    
        Add-ADGroupMember -Identity $student_reset_group -Members $user.distinguishedname
        write-host "$user added to $student_reset_group"
        $student_reset_added_users++
    } 
}

Write-Host "$student_reset_group group has $student_reset_total_users users.  We also added $student_reset_added_users users."

#Clear out variables
$student_reset_total_users = 0
$student_reset_added_users = 0

Stop-Transcript
