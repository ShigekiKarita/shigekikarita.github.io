#!/usr/bin/env sh
d=`date +"%Y-%m-%d"`
n=`ls _posts | wc -w | xargs expr 1 + | xargs printf %03g`

cat <<EOF > _posts/${d}-${n}.md
---
layout: post
title:
comments: true
---
EOF
