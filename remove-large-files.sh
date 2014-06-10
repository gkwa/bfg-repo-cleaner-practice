#/bin/sh

bannedlist=$(pwd)/banned.txt

rm -rf /tmp/nsis-streambox3.git
rm -rf /tmp/nsis-streambox3

git clone --mirror ~/pdev/nsis-streambox2 /tmp/nsis-streambox3.git
git clone /tmp/nsis-streambox3.git /tmp/nsis-streambox3

cd /tmp/nsis-streambox3

git config -l | grep -i url

rm -f autoit-v3-setup.exe
rm -f nsis-2.46-Unicode-setup.exe
rm -f nsis-2.46-setup.exe
rm -f sed-4.2-1-bin.zip
rm -f sed-4.2-1-dep.zip
rm -f 7z920.msi

git commit -am "Deleting large files"
git push

echo ***REMOVED*** >$bannedlist

java \
    -jar /Users/demo/Downloads/bfg-1.11.6.jar \
    --strip-blobs-bigger-than 1M \
    --replace-text $bannedlist \
    /tmp/nsis-streambox3.git

cd /tmp/nsis-streambox3.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

du -sh ~/pdev/nsis-streambox2
du -sh /tmp/nsis-streambox3.git
