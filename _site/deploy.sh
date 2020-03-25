#!/bin/bash
bundle exec jekyll build
git add . && git ci "update" && git push
