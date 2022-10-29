curDate=$(date -u +"%Y_%m_%d")
logfile="logs/backup.log_$curDate"

remote_username="homeserver"
remote_address="homeserver"
remote_root_dir="/mnt/data_2tb/backup/backup_$curDate"

backup_dirs=("/etc" "/home/linus" "/opt" "/usr/local/bin" "/usr/local/sbin")

mkdir -p logs
touch $logfile

echo "-----------------------------------------------------" >> $logfile
echo "Creating backup using rsync: $curDate" >> $logfile
echo "-----------------------------------------------------" >> $logfile
# echo "RSYNC: /home/linus" >> $logfile
# sudo rsync --delete -r -t -p -o -g -v --progress -l -H -z -s --exclude-from=backup_ignores/rsync_ignore_home_linus /home/linus homeserver@homeserver:/mnt/data_2tb/backup/backup_$curDate/home/linus >> $logfile 2>&1


for dir in ${backup_dirs[@]}
do
  echo "Creating $remote_root_dir/$dir on remote"
  ssh $remote_username@$remote_address mkdir -p $remote_root_dir/$dir
  ignore_file="backup_ignores/rsync_ignore_$(echo $dir | tr "/" "_")"
  
  if [[ -f "$ignore_file" ]]; then
    echo "RSYNC: $dir" >> $logfile
    echo "RSYNC: $dir"
    sudo rsync -a --delete -v --progress -s -H -z --exclude-from=$ignore_file $dir/ $remote_username@$remote_address:$remote_root_dir/$dir >> logs/backup.log_$curDate 2>&1
  else
    echo "WARNING: No ignore file found for: $dir. Please edit $ignore_file if you want to exclude files from being backed up and run the command again" 
    
    echo "SKIPPED: $dir. Ignore file is not configured" >> $logfile
    touch $ignore_file
    echo "# rsync-excludes for $dir" >> $ignore_file
    echo "##############################################" >> $ignore_file
    echo "# Directories/Files that do not need backup  #" >> $ignore_file
    echo "##############################################" >> $ignore_file
  fi
done


