# Output the current time zone
$timeZone = [System.TimeZone]::CurrentTimeZone
Write-Output "The current system time zone is: $($timeZone.StandardName)"
