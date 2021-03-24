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

#remove old files
rm -rf *.$1
rm gauscan.txt
rm scan.raw
rm 200url.csv
rm endpoint.txt
rm rawurl.txt
rm sql_exploit.sh
rm possible_sqli.txt

#Find gau and waybackurl endpoints
echo "DUMPING ENDPOINTS SIT TIGHT"
echo $1 |gau -subs |qsreplace -a > rawurl.txt
echo $1 |waybackurls |qsreplace -a >> rawurl.txt

#validate 200 code
cat rawurl.txt |grep = |egrep -v ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" |qsreplace -a |gf interestingparams |ffuf -w - -u FUZZ -t 400 -mc 200,302 -o 200url.csv -of csv

#extract ffuf endpoints 
cat 200url.csv |cut -d , -f3|qsreplace -a > endpoint.txt

#extract ffuf endpoints 
cat 200url.csv |cut -d , -f2|qsreplace -a >> endpoint.txt

#find interesting params
cat endpoint.txt |grep = |egrep -v ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt|js)" |qsreplace -a |gf interestingparams |while read url; do xargs -n 1 -P 20 injectx.py -u $url -vn ; done |tee scan.raw

#convert the binary output to text
strings scan.raw |grep "Exploit Command" |sort -u |cut -c 9- > gauscan.txt

#extract sqlmap findings to put in file append output dir
cat gauscan.txt |grep sqlmap |cut -c 18- |sed 's/$/ --output-dir=.\//' > ./sql_exploit.sh

#remove sqlmap from results
sed -i '/sqlmap/d' gauscan.txt

#upload findings to slack without sqlmap
slackcat --channel bugbounty ./gauscan.txt

#validate sqlmap finds
bash ./sql_exploit.sh

#pull out sqlmap findings
find ./ -name 'target.txt' -exec cat {} \; |sort -u > ./possible_sqli.txt

#delete log file if empty
find ./ -name 'log'  -size  0 -print -delete

#Remove folders with only 2 files 
du -a | cut -d/ -f2 | sort | uniq -c | sort -nr |grep 3 |xargs rm -rf

#upload sqlmap findings to slack
slackcat --channel bugbounty ./possible_sqli.txt

}

if [ -z "$1" ]
  then
    kill
else
        recon $1
fi
