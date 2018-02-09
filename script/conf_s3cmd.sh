#!/bin/bash

source ./env.sh
s3cmd --configure>/dev/null<<EOF
${SRCAK}
${SRCSK}
${SRCREGION}
s3.${SRCREGION}.amazonaws.com.cn
%(bucket)s.s3.${SRCREGION}.amazonaws.com.cn


No

y
y
EOF

s3cmd ls
