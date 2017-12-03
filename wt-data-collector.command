outputfile=systemInfo.txt
foldername=WT-BUGREPORT
DATE=`date '+%Y-%m-%d_%H-%M'`

if [ ! -d ~/Desktop/$foldername-$DATE ]; then
    bugfiles=~/Desktop/$foldername-$DATE
    mkdir $bugfiles
else
   printf "You've Already just created a report\n"
   exit
fi

SystemCore=$(uname -a)
printf "$SystemCore\n" >>$bugfiles/$outputfile 

printf "\nSoftware Information\n" >>$bugfiles/$outputfile
printf "_______________________________________\n" >>$bugfiles/$outputfile
for a in "System Version" "Kernel Version" "Boot Volume" "Boot Mode" "Secure Virtual Memory" "System Integrity Protection" "Time since boot"
do
    b=$(system_profiler SPSoftwareDataType | grep "$a" | awk -F': ' '{print $2}')
    printf "$a = $b\n" >>$bugfiles/$outputfile
done

printf "\nHardware Information\n" >>$bugfiles/$outputfile
printf "_______________________________________\n" >>$bugfiles/$outputfile
for a in "Model Name" "Model Identifier" "Processor Name" "Processor Speed" "L3 Cache (per Processor)" "Memory" "Processor Interconnect Speed" "Boot ROM Version" "SMC Version (system)" "SMC Version (processor tray)" "Hardware UUID"
do
    b=$(system_profiler SPHardwareDataType | grep "$a" | awk -F': ' '{print $2}')
    printf "$a = $b\n" >>$bugfiles/$outputfile
done

printf "\nGraphics Information\n" >>$bugfiles/$outputfile
printf "_______________________________________\n" >>$bugfiles/$outputfile
for a in "Chipset Model" "Type" "Bus" "Slot" "PCIe Lane Width" "VRAM (Total)" "Vendor" "Device ID" "Revision ID" "ROM Revision" "VBIOS Version" "EFI Driver Version" "Resolution" "Framebuffer Depth"
do
    b=$(system_profiler SPDisplaysDataType | grep "$a" | awk -F': ' '{print $2}')
    printf "$a = $b\n" >>$bugfiles/$outputfile
done

printf "\nStorage Information\n" >>$bugfiles/$outputfile
printf "_______________________________________\n" >>$bugfiles/$outputfile
system_profiler SPStorageDataType >>$bugfiles/$outputfile

cd /Users/temp/WarThunderLauncherLogs
for b in $(find * -mmin -30 -type f); do cp $b $bugfiles/$b; done > /dev/null 2>&1
cd /Users/temp/My\ Games/WarThunder/_game_logs
for b in $(find * -mmin -30 -type f); do cp $b $bugfiles/$b; done > /dev/null 2>&1
cd /Users/temp/Library/Logs/DiagnosticReports/
for b in $(find aces* -mmin -30 -type f); do cp $b $bugfiles/$b; done > /dev/null 2>&1
cd /Users/temp/Library/Application\ Support/CrashReporter/
for b in $(find aces* -mmin -30 -type f); do cp $b $bugfiles/$b; done > /dev/null 2>&1

clear
if [ -d $bugfiles ]
then
    printf "These files will be zipped for you to submit\n"
    printf "____________________________________________________\n"
    ls -l $bugfiles
    printf "____________________________________________________\n"
    printf "Add any additional files to the folder such a screen caps, replays, etc"
    read -p "Please review these files carefully, do you want to submit them?: (Y / N)" ans_yn
    case "$ans_yn" in
        [Yy]|[Yy][Ee][Ss]) echo "Zipping the files";;
                *) exit 3;;
    esac
fi


clear
zip -r -j $bugfiles.zip $bugfiles
rm -rf $bugfiles
clear
if [ -f $bugfiles.zip ]; 
then
    printf "The needed files are zipped for you to submit\n"
    printf "please attach the file below to your Bug Report Submission\n"
    printf "____________________________________________________\n"
    echo $bugfiles.zip
    printf "____________________________________________________\n"
fi
exit