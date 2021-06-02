EASYSTEPS TEST

------------------------------------------------------------------------
HOW TO RUN THE TEST

1. Install easysteps and point EASYSTEPS_TOP at easysteps-alt packages

    % git clone https://github.com/steveri/easysteps.git
    % TEST=$PWD/easysteps/test/test.sh
    % export EASYSTEPS_TOP=$PWD/easysteps

2. Install mflowgen if you don't already have it

    % git clone https://github.com/mflowgen/mflowgen.git
    % pip install -e mflowgen

3. Build and compare before-and-after versions of Tile_PE;
   resulting designs should be identical.

    % $TEST build
    % $TEST compare

Also see $EASYSTEPS_TOP/.travis.yml


------------------------------------------------------------------------
WHAT THE TEST DOES

Builds the same design construct.py files both with and without
easysteps, checks that results in both cases are identical.

To contrast the two styles (basic vs. easysteps-alt), you can compare the
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
