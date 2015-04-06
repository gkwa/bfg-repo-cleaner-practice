#/bin/sh

set -o errexit

bfgver=1.12.3
bfgjar=bfg-$bfgver.jar
bfgjarPath=$bfgjar
wget --timestamping http://repo1.maven.org/maven2/com/madgag/bfg/$bfgver/$bfgjar

start_folder=`pwd`


bannedlist=banned.txt

rm -rf /tmp/$0.tmp

rm -rf nsisscripts.git
rm -rf nsisscripts
rm -rf nsisscriptsb

git clone --mirror ~/pdev/nsis-streambox2 nsisscripts.git
git clone nsisscripts.git nsisscripts

cat << __EOT__ >>/tmp/$0.tmp
regedit.exe
7za.exe
autoit-v3-setup.exe
nsis-2.46-Unicode-setup.exe
nsis-2.46-setup.exe
sed-4.2-1-bin.zip
sed-4.2-1-dep.zip
pathman.exe
7z920.msi
nsis-plugins
pathed.exe
curl.exe
regedit_xp
regjump.exe
robocopy.exe
sc.exe
setx.exe
handle.exe
taskkill.exe
devcon
display-path.bat
give-nsis-priority.bat
give-nsisunicode-priority.bat
install-streambox-assets-to-nsis-folder.bat
setenv
uninstall.bat
setup.bat
setup-autoit.bat
sleep.exe
Graphics
Docs
Icons
__EOT__

cd $start_folder/nsisscripts
cat /tmp/$0.tmp | sort | while read f; do rm -rf $f; done;

git commit -am "Deleting large files"
git push

bfg_delete_files_args="$(
{
    cat /tmp/$0.tmp
    git diff-tree --no-commit-id --name-only -r HEAD | awk -F/ '{print $(NF)}'
} | sort -u | sed -e 's/$/,/' | tr -d '\n' | sed -e 's,.$,,' -e 's,^,{,' -e 's,$,},')"

# echo $bfg_delete_files_args

cd $start_folder/nsisscripts
echo secret_password >$bannedlist

JAVA=java
[[ `uname -s` == *"CYGWIN"* ]] && JAVA='cmd /c java'

cd $start_folder/nsisscripts
$JAVA \
    -jar ../$bfgjarPath \
    --replace-text $bannedlist \
    --delete-files "$bfg_delete_files_args" \
    ../nsisscripts.git

cd $start_folder

cd $start_folder/nsisscripts.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

cd $start_folder

git clone nsisscripts.git nsisscriptsb

du -sh ~/pdev/nsis-streambox2
du -sh nsisscripts.git
du -sh nsisscriptsb
