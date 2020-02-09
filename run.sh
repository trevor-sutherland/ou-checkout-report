OUCAMPUS="a.cms.omniupdate.com"
SKIN="uark"
ACCOUNT="www"
SAUSERNAME="api_admin"
SAPASSWORD="mikeandtrevorapi2020"
USERNAME="ts023@uark.edu"
SITE="development-omniupdate-admin"

curl -c cookies.txt --data "skin=${SKIN}&username=${SAUSERNAME}&password=${SAPASSWORD}" https://${OUCAMPUS}/authentication/admin_login > /dev/null
curl -b cookies.txt --data "skin=${SKIN}&account=${ACCOUNT}&username=${USERNAME}" https://${OUCAMPUS}/authentication/login > /dev/null

usernames=`curl -s -b cookies.txt https://${OUCAMPUS}/groups/view?group=UREL | python -m json.tool | ./jq-linux64 -r '.members | .[] | .username'`

for username in $usernames
do
	echo "$username"

	login=`curl -s -b cookies.txt --data "skin=${SKIN}&account=${ACCOUNT}&username=$username" https://${OUCAMPUS}/authentication/login`
	sites=`echo "$login" | ./jq-linux64 -r ' .sites | .[] | .name' `

	email=$(for site in $sites
	do

		files=$(curl -s -b cookies.txt "https://${OUCAMPUS}/files/checkedout?site=$site" | ./jq-linux64 -r ' .[] | .path')
		if ( echo "$files" | grep -q '[A-Za-z]' )
		then
			echo "<h2>$site</h2>"
			echo "<ul>"
			for file in $files
			do
				echo "<li><a href=\"https://a.cms.omniupdate.com/10?skin=uark&account=www&site=$site&action=de&path=$file\">$file</a></li>"
			done
			echo "</ul>"
		fi
	done )

	if ( echo "$email" | grep -q '[A-Za-z]' )
	then
		echo "$email" | mutt -e "set content_type=text/html" -s "Checked out files for $username" ts023@uark.edu,mike@uark.edu
	fi

done
