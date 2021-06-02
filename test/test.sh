#!/bin/bash
set -e ; # Exit on *any* error within the script

# Usage:
#    export EASYSTEPS_TOP=<easysteps install dir>
# 
# Then:
#    test.sh install    ; # clone and install mflowgen
#    test.sh build      ; # build before-and-after designs
#    test.sh compare    ; # verify that both designs are identical
# 
#    test.sh install build compare ; # do all three

if [ "$1" == "install" ]; then

    echo "+++ Prepare a virtual environment"
    which virtualenv || pip install virtualenv
    python -m venv venv
    source ./venv/bin/activate
    echo ""

    echo "+++ Clone and install mflowgen"
    git clone https://github.com/mflowgen/mflowgen.git
    which mflowgen || echo should give error
    (cd mflowgen; pip install -e .)
    which mflowgen
    pip list --format=columns | grep mflowgen
    echo ""

    shift ; # e.g. can do "test.sh install build compare"
fi

if [ "$1" == "build" ]; then

  echo "+++ Using EASYSTEPS_TOP=$EASYSTEPS_TOP"
  echo ""
  if ! [ "$EASYSTEPS_TOP" ]; then cat << "    EOF"
    ERROR did not find env var EASYSTEPS_TOP

    It should point to easysteps packages e.g.
      export EASYSTEPS_TOP=/installdir/easysteps
    or
      export EASYSTEPS_TOP=/installdir/easysteps/easysteps-alt
    EOF
    exit 13
  fi

    ########################################################################
    # BUILD before & after designs

    echo "+++ Build before-and-after test designs: BEFORE"
    mkdir build_before; cd build_before
    mflowgen run --design $EASYSTEPS_TOP/test/design_before/Tile_PE
    echo ""; cd ..

    echo "+++ Build before-and-after test designs: AFTER"
    mkdir build_after; cd build_after
    mflowgen run --design $EASYSTEPS_TOP/test/design_after/Tile_PE
    echo ""; cd ..

    shift ; # e.g. can do "test.sh install build compare"
fi

if [ "$1" == "compare" ]; then

    ########################################################################
    # COMPARE before & after designs

    echo "+++ Compare before and after designs (result should be NULL (identical))"

    DBG=
    log=results.log
    test -e $log && mv $log $log.$$

    echo '# Look for "only in build_before" files...'
    (for f1 in `find build_before -type f`; do
      f=`echo $f1 | sed "s|build_before/||"`
      f2=build_after/$f
      test -f "$f2" || echo Only in build_before: $f
    done) |& tee -a $log

    echo '# Look for "only in build_after" files...'
    (for f1 in `find build_after -type f`; do
      f=`echo $f1 | sed "s|build_after/||"`
      f2=build_before/$f
      test -f "$f2" || echo Only in build_after: $f
    done) |& tee -a $log

    echo '# Compare remaining files straight across...'
    (for f1 in `find build_before -type f`; do
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
    echo DONE; echo ''

    # Debug info prevents clean final check, so just skip it
    [ "$DBG" ] && exit

    # FAIL if log file contains diffs
    echo "--- FINAL ANSWER"
    if grep . $log; then
        echo "FAIL (diffs found)"; exit 13
    else
        echo "SUCCESS (no diffs)"; exit
    fi
fi
