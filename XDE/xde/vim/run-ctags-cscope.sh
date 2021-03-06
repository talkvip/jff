#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage: run-ctags-cscope.sh source-dir-list"
    exit 1
fi

while read d; do
    /usr/bin/find "$d" -type f -iregex '.*\.\(c\|h\|hpp\|cpp\|java\|cc\|cxx\)' -print
done < "$1"  > cscope.files

rm -f cscope.*out tags
cscope -b -q -k
ctags -L cscope.files --fields=+ainS --extra=+fq --c-kinds=+px --c++-kinds=+px --totals

