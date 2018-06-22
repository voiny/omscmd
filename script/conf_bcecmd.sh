#!/bin/bash

source ./env.sh
bcecmd --configure>/dev/null<<EOF
${SRCAK}
${SRCSK}








EOF

bcecmd bos ls
