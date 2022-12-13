#!/bin/sh

echo "Add files and do local commit"
git add -A
git commit -am "updated the ecs ingress rule"

echo "add elasetic chance"
git push
