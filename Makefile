.PHONY:build
build:
	bundle exec jekyll serve
serve:
	bundle exec jekyll serve
deploy:
	bundle exec jekyll build
	git add . && git ci "update" && git push