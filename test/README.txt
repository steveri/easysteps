EASYSTEPS TEST

------------------------------------------------------------------------
HOW TO RUN THE TEST

1. Install easysteps and set EASYSTEPS_TOP = install location

    % git clone https://github.com/steveri/easysteps.git
    % export EASYSTEPS_TOP=$PWD/easysteps

2. Install mflowgen if you don't already have it

    % git clone https://github.com/mflowgen/mflowgen.git
    % cd mflowgen; pip install -e .


(cd /tmp; $TEST)


------------------------------------------------------------------------
WHAT THE TEST DOES

Builds the same design construct.py files both with and without using esteps2 enhancements, verify that the results in both cases are identical.

To contrast the two styles (basic vs. easystesp), you can compare the design without easystep enhancements vs. the design rewritten with enhancements

   diff design_before/Tile_PE/construct.py design_after/Tile_PE/construct.py

The idea is that the enhancements make the construct file more intuitive and easier to write.

To test and make sure everything is working, test.sh builds a complex design both ways and compare the result, which should be the same in both cases.

# # Compare before and after: construction scripts
# wc -l $testdir/design_{before,after}/Tile_PE/construct.py
# sdiff $testdir/design_{before,after}/Tile_PE/construct.py | less




NOTES/TODO
- make a test rig and/or pytest that does this automatically, for CI you know.
- should be a pytest I suppose
- set it up for travis CI



