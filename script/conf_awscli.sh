#!/bin/bash

source ./env.sh
aws configure>/dev/null<<EOF
${SRCAK}
${SRCSK}
${SRCREGION}

EOF

echo [dst] >> /root/.aws/credentials
echo aws_access_key_id = ${DSTAK} >> /root/.aws/credentials
echo aws_secret_access_key = ${DSTSK} >> /root/.aws/credentials

aws s3 ls
