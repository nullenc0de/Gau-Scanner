#!/bin/bash -i

banner (){
echo -e "
@nullenc0de"
}

kill (){
        banner
    echo -e "LAZY ENDPOINT SCANNER FOR BUGBOUNTY"
    echo "USAGE:./gauscan.sh domain.com"
    exit 1
}

recon (){
banner

echo $1 |gau -subs |qsreplace -a| ffuf -w - -u FUZZ -t 400 -mc 200 -o 200url.csv -of csv
cat 200url.csv |cut -d , -f3|qsreplace -a > endpoint.txt
cat endpoint.txt |grep = |egrep -v ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" |qsreplace -a |gf interestingparams |while read url; do injectx.py -u $url -vn ; done |tee scan.raw
strings scan.raw |grep "Exploit Command" |sort -u |cut -c 9- > gauscan.txt
slackcat --channel bugbounty ./gauscan.txt
rm gauscan.txt
rm scan.raw
rm 200url.csv
rm endpoint.txt

}

if [ -z "$1" ]
  then
    kill
else
        recon $1
fi
