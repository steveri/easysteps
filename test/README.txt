EASYSTEPS TEST

------------------------------------------------------------------------
HOW TO RUN THE TEST

1. Install easysteps and set EASYSTEPS_TOP = install location

    % git clone https://github.com/steveri/easysteps.git
    % export EASYSTEPS_TOP=$PWD/easysteps

2. Install mflowgen if you don't already have it

    % git clone https://github.com/mflowgen/mflowgen.git
    % pip install -e mflowgen

3. Build before-and-after versions of Tile_PE

    % TEST=$EASYSTEPS_TOP/test/test.sh
    % $TEST build

4. Compare before-and-after builds; should be the same

    % $TEST compare

Also see $EASYSTEPS_TOP/.travis.yml


------------------------------------------------------------------------
WHAT THE TEST DOES

Builds the same design construct.py files both with and without
easysteps, checks that results in both cases are identical.

To contrast the two styles (basic vs. easysteps), you can compare the
two design styles like this:

  % cd $EASYSTEPS_TOP/test
  % diff design_before/Tile_PE/construct.py design_after/Tile_PE/construct.py

The idea is that the enhancements make the construct file more
intuitive and easier to write.

To test and make sure everything is working, test.sh builds a complex
design both ways and compare the result, which should be the same in
both cases.




------------------------------------------------------------------------
NOTES/TODO

* Test should be set up as a pytest, I suppose.

