#!/bin/bash -e

echo "convert file $1 to ~/myspace/content/blog/study/"

#git blame "$1" | sed 's|hitzhangjie ||' &> ~/myspace/content/blog/study/"$1".md
cat "$1" | sed 's|hitzhangjie ||' &> ~/myspace/content/blog/study/"$1".md
