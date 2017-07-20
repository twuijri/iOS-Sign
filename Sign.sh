# !/bin/bash




read -p "Name application :  " APPNAME
read -p "path ipa" SOURCEIPA
read -p "path mobileprovision :  " MOBILEPROV


echo "Start resign the app..."

OUTDIR=$(dirname "${SOURCEIPA}")
TMPDIR="$OUTDIR/tmp"
APPDIR="$TMPDIR/app"


mkdir -p "$APPDIR"
unzip -qo "$SOURCEIPA" -d "$APPDIR"

APPLICATION=$(ls "$APPDIR/Payload/")
IpaName=$(basename "$APPLICATION")
IpaName="${IpaName%.*}++.ipa"
RED='\033[0;31m'
NC='\033[0m'
DEVELOPER="iPhone Distribution: ASIM ALOTAIBI (USA79RSNZY)"
BUNDLEID="club.apps5plus.$APPNAME"
newFoldar=$RANDOM
ipServer="root@163.172.187.199"
userNameServer="root"
linkFoldar="/home/vvco/web/vvco.co/public_html"
WebSite="vvco.co"


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
mkdir -p $HOME/Desktop/appPlus/$newFoldar
cp iTunesArtwork $HOME/Desktop/appPlus/$newFoldar/
zip -qr "../$IpaName" *
cd ..
mv $IpaName $HOME/Desktop/appPlus/$newFoldar/

echo "Finish resign. Output:$IpaName"


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


echo -e "${RED}Enter Password root Server${NC}"
sftp -R 128 -B 65536 $ipServer << EOF
cd $linkFoldar/appPlus/
mkdir $newFoldar

put $HOME/Desktop/appPlus/$newFoldar/* $linkFoldar/appPlus/$newFoldar/

EOF

echo -e "                              ${RED}https://$WebSite/appPlus/$newFoldar${NC}"
