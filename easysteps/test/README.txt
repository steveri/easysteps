EASYSTEPS TEST

Build the same design construct.py files both with and without using easysteps enhancements, verify that the results in both cases are identical.

To contrast the two styles (basic vs. easystesp), you can compare the design without easystep enhancements vs. the design rewritten with enhancements

   diff design_before/Tile_PE/construct.py design_after/Tile_PE/construct.py

The idea is that the enhancements make the construct file more intuitive and easier to write.

To test and make sure everything is working, we build a complex design both ways and compare the result, which should be the same in both cases.

NOTES/TODO
- make a test rig and/or pytest that does this automatically, for CI you know.

------------------------------------------------------------------------
HOW TO TEST:

# Build a clean test rig
erig=~/tmpdir/easysteps_test

ls -ld ${erig}*
mv ${erig} ${erig}.deleteme2


mkdir -p $erig; cd $erig

# Set up a virtual environment I guess
cd $erig
python -m venv venv
source ./venv/bin/activate

# Clone mflowgen
cd $erig
git clone https://github.com/mflowgen/mflowgen.git

# Install mflowgen
cd $erig/mflowgen
TOP=$PWD; export MFLOWGEN_TOP=$PWD
which mflowgen  # should give error
pip install -e .
which mflowgen
pip list --format=columns | grep mflowgen

# Install easysteps
cd $erig/mflowgen
git clone https://github.com/steveri/easysteps.git

########################################################################
# Build before-and-after test designs: BEFORE

testdir=$erig/mflowgen/easysteps/easysteps/test
which mflowgen
cd $testdir; mkdir build_before
cd $testdir/build_before
mflowgen run --design $testdir/design_before/Tile_PE


########################################################################
# Build before-and-after test designs: AFTER

testdir=$erig/mflowgen/easysteps/easysteps/test
which mflowgen
cd $testdir; mkdir build_after; cd build_after
mflowgen run --design $testdir/design_after/Tile_PE

########################################################################
# COMPARE before & after

# Compare before and after: construction scripts
wc -l $testdir/design_{before,after}/Tile_PE/construct.py
sdiff $testdir/design_{before,after}/Tile_PE/construct.py | less

# Compare before and after: final designs (result should be NULL (identical))
diff -r $testdir/design_{before,after} --exclude='construct*'




