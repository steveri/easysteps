#!/bin/bash
set -e ; # Exit on *any* error within the script

# This script installs mflowgen and mflowgen/easysteps

echo "+++ Clone mflowgen"
git clone https://github.com/mflowgen/mflowgen.git
echo ""

echo "+++ Prepare a virtual environment"
python -m venv venv
source ./venv/bin/activate
echo ""

echo "+++ Install mflowgen"
# cd $erig/mflowgen
which mflowgen || echo should give error
(cd mflowgen; pip install -e .)
which mflowgen
pip list --format=columns | grep mflowgen
echo ""

echo "+++ Install easysteps"
(cd mflowgen; git clone https://github.com/steveri/easysteps.git)
echo ""
