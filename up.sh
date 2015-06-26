#########################################################################
# File Name: up.sh
# Author: wayne
# mail: zhwayne@qq.com
# Created Time: 五  6/26 15:26:18 2015
#########################################################################
#!/bin/bash
hexo clean
git pull origin master
git add --all
git commit -m "update files"
git push origin master
echo Done!
