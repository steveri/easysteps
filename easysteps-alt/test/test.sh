#!/bin/bash

cat <<EOF
Don't use this script to test easysteps-alt. Do this instead:
  export EASYSTEPS_TOP=/installdir/easysteps/easysteps-alt
  /installdir/easysteps/test.sh $*
EOF
exit 13
