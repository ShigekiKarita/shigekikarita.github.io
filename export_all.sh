#!/usr/bin/env bash

for f in **/*.org; do
    echo "=== building $f ==="
    emacs $f  -l `pwd`/export.el --batch -f org-html-export-to-html
done
