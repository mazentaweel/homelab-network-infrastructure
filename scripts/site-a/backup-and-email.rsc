# /system script "backup-and-email" (sanitized)
#### Modify these values to match your requirements ####
:local toemail "<EMAIL>"

############## Script Logic ##############
:local sysname [/system identity get name]
:local time [/system clock get time]
:local date [/system clock get date]

# Format date to remove slashes
:local newdate ""
:for i from=0 to=([:len $date]-1) do={ 
    :local tmp [:pick $date $i]
    :if ($tmp != "/" && $tmp != "-") do={ :set newdate "$newdate$tmp" }
}

# Replace spaces in identity with underscores
:local cleanName ""
:for i from=0 to=([:len $sysname]-1) do={ 
    :local tmp [:pick $sysname $i]
    :if ($tmp != " ") do={ :set cleanName "$cleanName$tmp" } else={ :set cleanName "$cleanName_" }
}
:set sysname $cleanName

:local textfilename "$newdate-$sysname.rsc"
:local backupfilename "$newdate-$sysname.backup"

# Generate files
/export file=$textfilename
/system backup save name=$backupfilename

# Dynamic wait until backup files physically populate local storage
:local timeout 0
:while ([/file find name=$backupfilename] = "" && $timeout < 15) do={
    :delay 1s
    :set timeout ($timeout + 1)
}

:log info "Emailing backups..."

# FIX: Removed square brackets entirely to guarantee parser compatibility
:local rscSubject ("Config Backup RSC - " . $sysname . " " . $time)
:local binSubject ("Config Backup BIN - " . $sysname . " " . $time)

# First Email (.rsc)
/tool e-mail send to=$toemail subject=$rscSubject file=$textfilename
:delay 5s

# Second Email (.backup)
/tool e-mail send to=$toemail subject=$binSubject file=$backupfilename

# Allow 30 seconds for outbound transfer to finish before purging files
:delay 30s

# Clean files from local disk
/file remove [find name=$textfilename]
/file remove [find name=$backupfilename]
:log info "Backup script execution finished successfully."
