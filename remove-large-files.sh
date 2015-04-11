#/bin/sh

set -o errexit

bfgver=1.12.3
bfgjar=bfg-$bfgver.jar
bfgjarPath=$bfgjar
wget --timestamping http://repo1.maven.org/maven2/com/madgag/bfg/$bfgver/$bfgjar

toplevel="$(git rev-parse --show-toplevel)"


start_folder=`pwd`


bannedlist=banned.txt

rm -rf /tmp/$0.tmp
rm -rf /tmp/$0.tmp*
set +e
ls /tmp/$0.tmp*
set -e

rm -rf mysql_win_installer.git
rm -rf mysql_win_installer
rm -rf mysql_win_installerb

git clone --bare ~/pdev/streambox/mysql_win_installer mysql_win_installer.git
# git clone --bare git@gitlab.com:streambox/mysql_win_installer.git mysql_win_installer.git
(cd mysql_win_installer.git
 git remote rm origin
 git remote
 git remote add origin git@gitlab.com:streambox/mysql_win_installer.git
)
git clone mysql_win_installer.git mysql_win_installer

cat << __EOT__ >>/tmp/$0.tmp
nsis-streambox2
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

cd $start_folder/mysql_win_installer
cat /tmp/$0.tmp | sort | while read f; do rm -rf $f; done;

git commit -am "Deleting large files" ||:
git push


git diff-tree --no-commit-id --name-only -r HEAD |
    awk -F/ '{print $(NF)}' >/tmp/$0.tmp2

{
    cat /tmp/$0.tmp
    cat /tmp/$0.tmp2
} | sort -u >/tmp/$0.tmp3

# FIXME:
sed -i.bak '/^Makefile/d' /tmp/$0.tmp3

cat /tmp/$0.tmp3 | sed -e 's/$/,/' | tr -d '\n' | sed -e 's,.$,,' -e 's,^,{,' -e 's,$,},' >/tmp/$0.tmp4

bfg_delete_files_args="$(cat /tmp/$0.tmp4)"

# echo $bfg_delete_files_args

cd $start_folder/mysql_win_installer
echo secret_password >$bannedlist

JAVA=java
[[ `uname -s` == *"CYGWIN"* ]] && JAVA='cmd /c java'

cd $start_folder/mysql_win_installer
$JAVA \
    -jar "$toplevel/$bfgjarPath" \
    --replace-text $bannedlist \
    --strip-blobs-bigger-than 100k \
    --delete-files "$bfg_delete_files_args" \
    $start_folder/mysql_win_installer.git

cd $start_folder

cd $start_folder/mysql_win_installer.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

cd $start_folder

git clone mysql_win_installer.git mysql_win_installerb

du -sh ~/pdev/streambox/mysql_win_installer
du -sh mysql_win_installer.git
du -sh mysql_win_installerb

echo now run:
echo "cd mysql_win_installer.git && git push --set-upstream origin master"
