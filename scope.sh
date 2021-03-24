echo "dumping bc wildcards"
bbscope bc -b | grep -E '(^\*\.)' |cut -d '/' -f1 |cut -c 3- > scope.txt
echo "dumping h1 wildcards"
bbscope h1 -b --noToken | grep -E '(^\*\.)' |cut -d , -f1 | cut -d / -f1| cut -c 3- >> scope.txt
echo "dumping chaos wildcards"
curl https://raw.githubusercontent.com/projectdiscovery/public-bugbounty-programs/master/chaos-bugbounty-list.json |jq -r '.programs[] | select(.bounty == true) | .domains' |sort -u |cut -d '"' -f2  >> scope.txt
echo "sorting files"
cat scope.txt |sort -u > scope.raw
cat scope.raw  > scope.txt
rm scope.raw
