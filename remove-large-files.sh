#/bin/sh

set -o errexit

bfgver=1.12.3
bfgjar=bfg-$bfgver.jar
bfgjarPath=$(pwd)/$bfgjar
wget --timestamping http://repo1.maven.org/maven2/com/madgag/bfg/$bfgver/$bfgjar

bannedlist=$(pwd)/banned.txt

rm -rf /tmp/$0.tmp

rm -rf /tmp/nsis-streambox3.git
rm -rf /tmp/nsis-streambox3
rm -rf /tmp/nsis-streambox3b

git clone --mirror ~/pdev/nsis-streambox2 /tmp/nsis-streambox3.git
git clone /tmp/nsis-streambox3.git /tmp/nsis-streambox3

cd /tmp/nsis-streambox3

git config -l | grep -i url

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

cat /tmp/$0.tmp | sort | while read f; do rm -f $f; done;

git commit -am "Deleting large files"
git push

bfg_delete_files_args="{$(cat /tmp/$0.tmp | sort | tr '\n' ',' | sed -e 's,.$,,')}"

# echo $bfg_delete_files_args

echo ***REMOVED*** >$bannedlist

java \
    -jar $bfgjarPath \
    --replace-text $bannedlist \
    --delete-files "$bfg_delete_files_args" \
    /tmp/nsis-streambox3.git

cd /tmp/nsis-streambox3.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

git clone /tmp/nsis-streambox3.git /tmp/nsis-streambox3b

du -sh ~/pdev/nsis-streambox2
du -sh /tmp/nsis-streambox3.git
du -sh /tmp/nsis-streambox3b
