# !/bin/bash

# open termnal "xcode-select --install"
read -p $'\e[31mpath mobileprovision :  \e[0m' MOBILEPROV
read -p $'\e[31mpath Foldar :  \e[0m' pathFoldar
find -d "$pathFoldar" \( -name "*.ipa" \) > "$HOME/appPlus.txt"
# touch $HOME/Desktop/linkDwonlod.txt
touch $HOME/uplode.txt

# start loop                  ###################################################
while IFS='' read -r SOURCEIPA || [[ -n "$SOURCEIPA" ]];
do

  APPNAME=$(basename "${SOURCEIPA%.*}")
  # read -p $'\e[31mName application :  \e[0m' APPNAME
  # read -p $'\e[31mpath ipa :  \e[0m' SOURCEIPA
  # read -p $'\e[31mpath mobileprovision :  \e[0m' MOBILEPROV


  echo "Start resign the app..."

  OUTDIR="$HOME/Desktop/signApp"
  TMPDIR="$OUTDIR/tmp"
  APPDIR="$TMPDIR/app"

  mkdir -p "$OUTDIR"
  mkdir -p "$APPDIR"
  unzip -qo "$SOURCEIPA" -d "$APPDIR"


  # Must be modified
  DEVELOPER="iPhone Distribution: Asim Alotaibi (9XX532447M)"
  BUNDLEID="co.v33.$APPNAME"
  ipServer="root@151.80.198.157"
  userNameServer="root"
  linkFoldar="/home/v33/web/v33.co/public_html"
  WebSite="v33.co"




  APPLICATION=$(ls "$APPDIR/Payload/")
  IpaName=$(basename "$APPLICATION")
  IpaName="$APPNAME.ipa"
  Green="\[\033[0;32m\]"
  RED='\033[0;31m'
  NC='\033[0m'
  newFoldar=$RANDOM

  if [ -z "${MOBILEPROV}" ]; then
      echo "Sign process using existing provisioning profile from payload"
  else
      echo "Coping provisioning profile into application payload"
      cp "$MOBILEPROV" "$APPDIR/Payload/$APPLICATION/embedded.mobileprovision"
  fi

  echo "Extract entitlements from mobileprovisioning"
  security cms -D -i "$APPDIR/Payload/$APPLICATION/embedded.mobileprovision" > "$TMPDIR/provisioning.plist"
  /usr/libexec/PlistBuddy -x -c 'Print:Entitlements' "$TMPDIR/provisioning.plist" > "$TMPDIR/entitlements.plist"


  if [ -z "${BUNDLEID}" ]; then
      echo "Sign process using existing bundle identifier from payload"
  else
      echo "Changing BundleID with : $BUNDLEID"
      /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLEID" "$APPDIR/Payload/$APPLICATION/Info.plist"
      /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APPNAME" "$APPDIR/Payload/$APPLICATION/Info.plist"
  fi


  echo "Get list of components and resign with certificate: $DEVELOPER"
  find -d "$APPDIR" \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > "$TMPDIR/components.txt"

  var=$((0))
  while IFS='' read -r line || [[ -n "$line" ]]; do
  	if [[ ! -z "${BUNDLEID}" ]] && [[ "$line" == *".appex"* ]]; then
  	   echo "Changing .appex BundleID with : $BUNDLEID.extra$var"
  	   /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLEID.extra$var" "$line/Info.plist"
  	   var=$((var+1))
  	fi
      /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "$TMPDIR/entitlements.plist" "$line"
  done < "$TMPDIR/components.txt"


  echo "Creating the signed ipa"
  cd "$APPDIR"
  mkdir -p $HOME/Desktop/appPlus
  mkdir -p $HOME/Desktop/appPlus/$newFoldar
  cp iTunesArtwork $HOME/Desktop/appPlus/$newFoldar/
  zip -qr "../$IpaName" *
  cd ..
  mv $IpaName $HOME/Desktop/appPlus/$newFoldar/

  echo "Finish resign. Output:$IpaName"
  # # Start upload Diawi #########
  #
  #
  # echo -e $"${RED}   naw upload : $APPNAME ${NC}"
  # output=$(curl https://upload.diawi.com/ -F token='wRafPWI4qqClvX6I9fJTTodgraQpwPzocR8H6MQpeb' \
  # -F file=@$HOME/Desktop/appPlus/$newFoldar/$IpaName \
  # -F callback_emails='asimappios@gmail.com')
  # output=${output//:/: }
  # set $(awk '{for(n=1;n<=NF;n++)
  #             {if($n~"job")F=$(n+1);}}
  #            END {gsub("[\",){}]","",F);
  #             print F}' <<<"$output")
  # output=$1
  # sleep 7
  # output=$(curl -s "https://upload.diawi.com/status?token=wRafPWI4qqClvX6I9fJTTodgraQpwPzocR8H6MQpeb&job=$output")
  # output=${output//:/: }
  # output=${output//,/, }
  #
  # set $(awk '{for(n=1;n<=NF;n++)
  #            {if($n~"hash")F=$(n+1);}}
  #           END {gsub("[\",){}]","",F);
  #            print F}' <<<"$output")
  # output=$1
  # link="https://i.diawi.com/$output"
  #     # wget link
  #     cd $OUTDIR
  #     wget $link
  #     linkDiawi=$(grep "app-file" $OUTDIR/$output | cut -d'"' -f 4)
  #     # end
  #
  # # end upload Diawi #########


  cat > $HOME/Desktop/appPlus/$newFoldar/$APPNAME.plist <<END
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  	<key>items</key>
  	<array>
  		<dict>
  			<key>assets</key>
  			<array>
  				<dict>
  					<key>kind</key>
  					<string>software-package</string>
  					<key>url</key>
  					<string>https://$WebSite/appPlus/$newFoldar/$IpaName</string>
  				</dict>
  				<dict>
  					<key>kind</key>
  					<string>full-size-image</string>
  					<key>needs-shine</key>
  					<true/>
  					<key>url</key>
  					<string>https://$WebSite/appPlus/$newFoldar/iTunesArtwork</string>
  				</dict>
  				<dict>
  					<key>kind</key>
  					<string>display-image</string>
  					<key>needs-shine</key>
  					<true/>
  					<key>url</key>
  					<string>https://$WebSite/appPlus/$newFoldar/iTunesArtwork</string>
  				</dict>
  			</array>
  			<key>metadata</key>
  			<dict>
  				<key>bundle-identifier</key>
  				<string>club.apps5plus.$APPNAME</string>
  				<key>bundle-version</key>
  				<string>1.0</string>
  				<key>kind</key>
  				<string>software</string>
  				<key>title</key>
  				<string>$APPNAME</string>
  			</dict>
  		</dict>
  	</array>
  </dict>
  </plist>
END


cat > $HOME/Desktop/appPlus/$newFoldar/index.php <<END
  <<?php
  header("location:itms-services://?action=download-manifest&url=https://$WebSite/appPlus/$newFoldar/$APPNAME.plist")

   ?>
END


linkDwonlod=$(cat $HOME/Desktop/linkDwonlod.txt)
cat > $HOME/Desktop/linkDwonlod.txt <<END
$linkDwonlod
$APPNAME
https://$WebSite/appPlus/$newFoldar
END

# linkDiawi=$(cat $HOME/Desktop/linkDiawi.txt)
# cat > $HOME/Desktop/linkDiawi.txt <<END
# $linkDiawi
# $APPNAME
# $link
# END

uplode=$(cat $HOME/uplode.txt)
cat > $HOME/uplode.txt <<END
$uplode
cd $linkFoldar/
mkdir appPlus
mkdir appPlus/$newFoldar

put $HOME/Desktop/appPlus/$newFoldar/* $linkFoldar/appPlus/$newFoldar/
END

rm -fr $OUTDIR
done < "$HOME/appPlus.txt"

## stop loop                ##########################################


rm -fr $HOME/appPlus.txt
linkDwonlod=$(cat $HOME/Desktop/linkDwonlod.txt)
linkDiawi=$(cat $HOME/Desktop/linkDiawi.txt)
cat > $HOME/Desktop/linkDwonlod.txt <<END
link my server
$linkDwonlod

***********************
link diawi
$linkDiawi
END
rm -fr $HOME/Desktop/linkDiawi.txt
# # upload diawi
# rm -fr $HOME/Desktop/linkDownload.txt
# touch $HOME/Desktop/linkDownload.txt
# find -d "$HOME/Desktop/appPlus/" \( -name "*.ipa" \) > "$HOME/appPlus.txt"
# while IFS='' read -r PATHIPA || [[ -n "$PATHIPA" ]];
# do
# APPNAME=$(basename "${PATHIPA%.*}")
# echo -e $"${RED}   naw upload : $APPNAME ${NC}"
# output=$(curl https://upload.diawi.com/ -F token='wRafPWI4qqClvX6I9fJTTodgraQpwPzocR8H6MQpeb' \
# -F file=@$PATHIPA \
# -F callback_emails='asimappios@gmail.com')
# output=${output//:/: }
# set $(awk '{for(n=1;n<=NF;n++)
#             {if($n~"job")F=$(n+1);}}
#            END {gsub("[\",){}]","",F);
#             print F}' <<<"$output")
# output=$1
# sleep 5
# output=$(curl -s "https://upload.diawi.com/status?token=wRafPWI4qqClvX6I9fJTTodgraQpwPzocR8H6MQpeb&job=$output")
# output=${output//:/: }
# output=${output//,/, }
#
# set $(awk '{for(n=1;n<=NF;n++)
#            {if($n~"hash")F=$(n+1);}}
#           END {gsub("[\",){}]","",F);
#            print F}' <<<"$output")
# output=$1
# link="https://i.diawi.com/$output"
#
# linkDownload=$(cat $HOME/Desktop/linkDownload.txt)
# cat > $HOME/Desktop/linkDownload.txt <<END
# $linkDownload
# $APPNAME
# $link
# END
#
# done < "$HOME/appPlus.txt"
# rm -fr $HOME/appPlus.txt
# # end upload diawi

conact sftp

comSftp=$(cat $HOME/uplode.txt)
echo -e "${RED}Enter Password root Server${NC}"
sftp -R 128 -B 100000 $ipServer << EOF
$comSftp
exit
EOF

# echo -e "                              ${RED}https://$WebSite/appPlus/$newFoldar${NC}"
echo -e "${Green} *******Congratulations All programs have been upload******* ${NC}"
rm -fr $HOME/uplode.txt
rm -fr $HOME/Desktop/appPlus
