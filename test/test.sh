#!/bin/bash
set -e ; # Exit on *any* error within the script

# This script builds a test rig directory "./erig" and then does the following:
# - installs mflowgen in dir ./erig/mflowgen
# - installs easysteps in dir ./erig/mflowgen/easysteps
# 


erig=`pwd`/erig
testdir=$erig/mflowgen/easysteps/test

# EASYSTEPS_TEST_REUSE=  ; # Unset for clean install from zero
# EASYSTEPS_TEST_REUSE=1 ; # Set to reuse existing test rig setup
if ! [ "$EASYSTEPS_TEST_REUSE" ]; then
    echo "+++ Building test rig '$erig'"; echo ""
    mkdir $erig

    ########################################################################
    # INSTALL mflowgen and easysteps

    echo "+++ Clone mflowgen"
    cd $erig
    git clone https://github.com/mflowgen/mflowgen.git
    echo ""

    echo "+++ Prepare a virtual environment"
    cd $erig
    python -m venv venv
    source ./venv/bin/activate
    echo ""

    echo "+++ Install mflowgen"
    cd $erig/mflowgen
    which mflowgen || echo should give error
    pip install -e .
    which mflowgen
    pip list --format=columns | grep mflowgen
    echo ""

    echo "+++ Install easysteps"
    cd $erig/mflowgen
    git clone https://github.com/steveri/easysteps.git
    export EASYSTEPS_TOP=$PWD/easysteps
    echo ""
fi


########################################################################
# BUILD before & after designs

echo "+++ Build before-and-after test designs: BEFORE"
export EASYSTEPS_TOP=$erig/mflowgen/easysteps
mkdir $erig/build_before && cd $erig/build_before
mflowgen run --design $testdir/design_before/Tile_PE
echo ""

echo "+++ Build before-and-after test designs: AFTER"
export EASYSTEPS_TOP=$erig/mflowgen/easysteps
mkdir $erig/build_after && cd $erig/build_after
mflowgen run --design $testdir/design_after/Tile_PE
echo ""


########################################################################
# COMPARE before & after designs

echo "+++ Compare before and after designs (result should be NULL (identical))"

DBG=
log=$erig/results.log
test -e $log && mv $log $log.$$

echo '# Look for "only in build_before" files...'
(cd $erig; for f1 in `find build_before -type f`; do
  f=`echo $f1 | sed "s|build_before/||"`
  f2=build_after/$f
  test -f "$f2" || echo Only in build_before: $f
done) |& tee -a $log
echo ''

echo '# Look for "only in build_after" files...'
(cd $erig; for f1 in `find build_after -type f`; do
  f=`echo $f1 | sed "s|build_after/||"`
  f2=build_before/$f
  test -f "$f2" || echo Only in build_after: $f
done) |& tee -a $log
echo ''

echo '# Compare remaining files straight across...'
(cd $erig; for f1 in `find build_before -type f`; do
  f=`echo $f1 | sed "s|build_before/||"`
  f2=build_after/$f
  test -f "$f2" || continue

  [ $DBG ] && echo cmp $f1 $f2
  if ! cmp $f1 $f2 >& /dev/null; then
      [ $DBG ] && echo NOPE try adj1

      # Files differ; make sure it's not just before/after confusion e.g.
      # < source: test/design_before/common
      # > source: test/design_after/common

      fix_f1="sed s/design_before/design_after/g $f1"
      if ! diff <($fix_f1) $f2 > /dev/null; then
          [ $DBG ] && echo STILL NOPE try adj2

          # Still no good, see if it's just lists in unsorted order maybe
          diff <($fix_f1 | sort) <(sort $f2) > /dev/null || echo "--- diff $f1 $f2"
          diff <($fix_f1 | sort) <(sort $f2)
      fi
  fi
done) |& tee -a $log
echo ''

echo DONE...; echo ''

# Debug info will prevent clean final check
[ "$DBG" ] && exit

# FAIL if log file contains diffs
echo "--- FINAL ANSWER"
if grep . $log; then
    echo "FAIL (diffs found)"; exit 13
else
    echo "SUCCESS (no diffs)"; exit
fi
