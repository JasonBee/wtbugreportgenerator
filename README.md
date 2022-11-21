# War Thunder Bug Report Generator (macOS)

This script will collect the files needed to file a bug report.

Have you ever posted a bug report only to find it was deleted or locked because you missed a file or two? 

This script automates the data collection for you, leaving you with a zip file containing the needed information. Never again will you post a bug report only to find it deleted a few days later because you failed to properly include the latest .clog files. 

Bad Gamer --> Good Gamer!

To use this script, download wt-data-collector.command to your computer and double click it. If .command files are correctly assigned it should open in Terminal.app. No privileges are required. Nothing is changed. Only a new desktop folder and a zip file are created from that folder.

The basic information requirements for the script were pulled from the (report guidelines.)[https://forum.warthunder.com/index.php?/topic/347718-mac-report-gudelines-important-read-before-posting/]

Be sure to post (bug reports here.)[https://forum.warthunder.com/index.php?/forum/569-moderated-bug-reports-mac/] 

Subject line should be formatted as requested in the link above: "[<full_version_number>]  <Issue>"

## Q: What does this script do?

## A: As follows.

1) It creates a folder on your desktop using today's date and time "WT-BUGREPORT-YEAR-MONTH-DAY_HH-MM".

2) It then reads out a number of system attributes useful to the developers (no more screen caps or typing out machine specs) and captures these stats to file. 
	
3) It copies files less than 30 minutes old from the following locations. Anything with a wildcard/file-mask ensures only the appropriate game-related files are collected:

	"~/WarThunderLauncherLogs"
	
	"~/My Games/WarThunder/_game_logs"
	
	"~/Library/Logs/DiagnosticReports/aces*"
	
	"~/Library/Application Support/CrashReporter/aces*"
	
	"/Library/Logs/DiagnosticReports/aces*"
	
4) Once this is done, a finder window is opened to the folder with the collected data. You are asked to review what's been collected. We do this so you can delete any garbage or incorrectly captured files. You can choose to add additional information such screen caps, missed log files, or love notes to the developers.

5) Finally, you are asked to enter a Y/N answer, and if Y is chosen the folder is zipped up and the source folder deleted. You will now have to manually create a bug report, and attach the zipped file you have created. Drag and drop is supported on the WT forums so adding the resulting zip file is easy and fast.

