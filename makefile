deploy:
	hexo clean
	hexo g --d
	git pull origin master
	git add --all
	git commit -m "update files"
	git push origin master
	echo Done!
