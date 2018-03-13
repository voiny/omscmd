#!/bin/bash

source ./env.sh
export PATH=$PATH:/usr/bin

ossutil config>/dev/null<<EOF
${SRCREGION}
${SRCAK}
${SRCSK}

EOF

ossutil ls
