#!/bin/bash

source ./env.sh
aws configure>/dev/null<<EOF
${SRCAK}
${SRCSK}
${SRCREGION}

EOF

aws s3 ls
