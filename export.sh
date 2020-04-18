#!/usr/bin/env bash
emacs $1  -l `pwd`/export.el --batch -f org-html-export-to-html

