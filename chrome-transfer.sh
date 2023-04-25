#!/bin/bash

if [ -z "${BASH_VERSION:-}" ]
then
  abort "Bash is required to interpret this script."
fi

chrome_dir="/Users/$(id -un)/Library/Application Support/Google/Chrome/"
old_profile_dir="$chrome_dir"Default/
backup_folder="/Users/$(id -un)/Desktop/Chrome Backup"
i=1

echo -e "Closing Google Chrome...\n"
pkill -x "Google Chrome"

echo -e "Found the following Profiles: \n"
find "/Users/$(id -un)/Library/Application Support/Google/Chrome/" -type d -name "Profile*" -exec stat -f "Creation date of %N: %Sm" {} \;
echo ""

for folder in "$chrome_dir"Profile*/; do
  modification_date=$(stat -f "%m" "$folder")
  if [[ $modification_date -gt $(date -j -f "%Y-%m-%d" "2023-04-19" "+%s") ]]; then
    new_profile_dir+="$i) $folder\n"
    ((i++))
  fi
done

if [ $(echo -e "$new_profile_dir" | wc -l) -eq 2 ]; then
  new_profile_dir=$(echo -e "$new_profile_dir" | cut -d ")" -f 2)
elif [ $(echo -e "$new_profile_dir" | wc -l) -gt 2 ]; then
  echo -e "Found multiple new profile directories: \n"
  echo -e "$new_profile_dir"
  
  while true; do
    echo "Which folder is the newly created profile?"
    read -p "Please choose from this menu by just typing the number associated with the correct folder: " menu_number
    if [ -n "$(echo -e "$new_profile_dir" | grep "^$menu_number)")" ]; then
      new_profile_dir=$(echo -e "$new_profile_dir" | grep "^$menu_number)" | cut -d ")" -f 2 | sed 's/^[^\/]*\///;s/\(.*\)/\/\1/')
      #don't look at this sed.... it's ugly but it somehow works... (thanks ChatGPT :P)
      break
    else
      echo -e "Invalid menu option. Please choose from the following options: \n"
      echo -e "$new_profile_dir"
    fi
  done
fi

echo This is the new folder: ==="$new_profile_dir"===
echo -e This is the old folder ==="$old_profile_dir"===
echo ""
echo "========================================================================================================================================="
echo First we are going to create a backup of both folders. juuuuust in case we break it.....
echo You can find a backup tarball of both the old profile folder and the new profile folder on the Desktop in a folder called "Chrome Backup"
echo "Now let's do it!!"
echo -e "=========================================================================================================================================\n"

mkdir "$backup_folder"
echo -e "Creating backup files...\n"
echo "(This can take a while if the Google Chrome profile is large)"
tar Pczf "$backup_folder"/default_profile.tar.gz "$old_profile_dir"
tar Pczf "$backup_folder"/new_profile.tar.gz "$new_profile_dir"

rsync -avq --include='*' --recursive "$old_profile_dir" "$new_profile_dir"

echo "All done! Please open Google Chrome and have a look!"
open -a "Google Chrome"