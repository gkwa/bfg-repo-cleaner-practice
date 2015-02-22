#/bin/sh

set -o errexit

bfgver=1.12.3
bfgjar=bfg-$bfgver.jar
bfgjarPath=$bfgjar
wget --timestamping http://repo1.maven.org/maven2/com/madgag/bfg/$bfgver/$bfgjar

start_folder=`pwd`


bannedlist=banned.txt

rm -rf /tmp/$0.tmp

rm -rf nsis-streambox3.git
rm -rf nsis-streambox3
rm -rf nsis-streambox3b

git clone --mirror ~/pdev/nsis-streambox2 nsis-streambox3.git
git clone nsis-streambox3.git nsis-streambox3

cat << __EOT__ >>/tmp/$0.tmp
regedit.exe
7za.exe
autoit-v3-setup.exe
nsis-2.46-Unicode-setup.exe
nsis-2.46-setup.exe
sed-4.2-1-bin.zip
sed-4.2-1-dep.zip
7z920.msi
__EOT__

cd $start_folder/nsis-streambox3
cat /tmp/$0.tmp | sort | while read f; do rm -f $f; done;

git commit -am "Deleting large files"
git push

bfg_delete_files_args="{$(cat /tmp/$0.tmp | sort | tr '\n' ',' | sed -e 's,.$,,')}"

# echo $bfg_delete_files_args

cd $start_folder/nsis-streambox3
echo secret_password >$bannedlist

JAVA=java
[[ `uname -s` == *"CYGWIN"* ]] && JAVA='cmd /c java'

cd $start_folder/nsis-streambox3
$JAVA \
    -jar ../$bfgjarPath \
    --replace-text $bannedlist \
    --delete-files "$bfg_delete_files_args" \
    ../nsis-streambox3.git

cd $start_folder

cd $start_folder/nsis-streambox3.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

cd $start_folder

git clone nsis-streambox3.git nsis-streambox3b

du -sh ~/pdev/nsis-streambox2
du -sh nsis-streambox3.git
du -sh nsis-streambox3b
