#!/bin/bash

if ! [ "$1" ]; then
    echo "Usage: $0 <test-dir>"
    echo "Example: $0 /tmp/easysteps_test"
    echo ""
fi
erig=$(cd $1; echo $PWD)

# testdir=$erig/mflowgen/easysteps/esteps2/test

REBUILD=
if [ "$REBUILD" ]; then
echo "+++ Build a clean test rig '$erig'"

if test -e $erig; then
    echo "ERROR test dir '$erig' already exists"
    exit 13
fi
# ls -ld ${erig}*
# mv ${erig} ${erig}.deleteme4
mkdir -p $erig; cd $erig; erig=$PWD
echo ""


echo "+++ Set up a virtual environment"
cd $erig
python -m venv venv
source ./venv/bin/activate
echo ""


echo "+++ Clone mflowgen"
cd $erig
git clone https://github.com/mflowgen/mflowgen.git
echo ""


echo "+++ Install mflowgen"
cd $erig/mflowgen
# TOP=$PWD; export MFLOWGEN_TOP=$PWD; # let's tryit w/o this shall we
which mflowgen  # should give error
pip install -e .
which mflowgen
pip list --format=columns | grep mflowgen
echo ""


echo "+++ Install easysteps"
cd $erig/mflowgen
git clone https://github.com/steveri/easysteps.git
export EASYSTEPS_TOP=$erig/mflowgen/easysteps
echo ""

########################################################################
fi
export EASYSTEPS_TOP=$erig/mflowgen/easysteps


########################################################################



echo "+++ Build before-and-after test designs: BEFORE"
testdir=$erig/mflowgen/easysteps/esteps2/test

# cd $testdir; mkdir build_before
# cd $testdir/build_before
mkdir $erig/build_before; cd $erig/build_before

which mflowgen
mflowgen run --design $testdir/design_before/Tile_PE
echo ""

echo "+++ Build before-and-after test designs: AFTER"
testdir=$erig/mflowgen/easysteps/esteps2/test
which mflowgen

# cd $testdir; mkdir build_after; cd build_after
mkdir $erig/build_after; cd $erig/build_after
EASYSTEPS_TOP=

cp \
/nobackup/steveri/github/easysteps/esteps2/test/design_after/Tile_PE/construct.py \
/tmp/etest/test1/mflowgen/easysteps/esteps2/test/design_after/Tile_PE/construct.py

mflowgen run --design $testdir/design_after/Tile_PE
echo ""

exit

########################################################################
# COMPARE before & after

echo "+++ Compare before and after designs (result should be NULL (identical))"
# diff -r $testdir/build_{before,after} --exclude='construct*' && echo SUCCESS || echo FAIL

DBG=
log=$erig/results.log
if test -e $log; then
    echo "WARNING $log exists"
    echo "mv $log $log.$$"
    echo ""
    echo "Beginning result comparisons..."; echo ""
    mv $log $log.$$
fi

echo '# Look for "only in build_before" files...'
# (cd $testdir; for f1 in `find build_before -type f`; do
(cd $erig; for f1 in `find build_before -type f`; do
  f=`echo $f1 | sed "s|build_before/||"`
  f2=build_after/$f
  test -f "$f2" || echo Only in build_before: $f
done) |& tee -a $log
echo ''

echo '# Look for "only in build_after" files...'
# (cd $testdir; for f1 in `find build_after -type f`; do
(cd $erig; for f1 in `find build_after -type f`; do
  f=`echo $f1 | sed "s|build_after/||"`
  f2=build_before/$f
  test -f "$f2" || echo Only in build_after: $f
done) |& tee -a $log
echo ''

echo '# Compare remaining files straight across...'
# (cd $testdir; for f1 in `find build_before -type f`; do
(cd $erig; for f1 in `find build_before -type f`; do
  f=`echo $f1 | sed "s|build_before/||"`
  f2=build_after/$f
  test -f "$f2" || continue

  [ $DBG ] && echo cmp $f1 $f2
  # cmp $f1 $f2
  if ! cmp $f1 $f2 >& /dev/null; then
      # Files differ; make sure it's not just e.g.
      # < source: /esteps2/test/design_before/common/custom-genlibdb-constraints
      # > source: /esteps2/test/design_after/common/custom-genlibdb-constraints
      [ $DBG ] && echo NOPE try adj1
      fix_f1="sed s/design_before/design_after/g $f1"


#       set -x
#       $fix_f1
#       exit
      # if ! diff $f1 $f2 -I design_ > /dev/null; then
#       diff <($fix_f1) $f2


      if ! diff <($fix_f1) $f2 > /dev/null; then
          # Still not good, see if it's just lists being printed in unsorted order maybe
          [ $DBG ] && echo STILL NOPE try adj2
          # diff <(sort $f1) <(sort $f2) -I design_

#           if ! diff <($fix_f1 | sort) <(sort $f2); then
#               echo BREAK;
#               break
#           fi
          
#           diff <($fix_f1 | sort) <(sort $f2) || FOUND_DIFF=1
          diff <($fix_f1 | sort) <(sort $f2)



      fi
  fi
done) |& tee -a $log
echo ''

echo DONE...


# Debug info will prevent clean final check
[ "$DBG" ] && exit

grep . $log && echo "FAIL (diffs found)" || echo "SUCCESS (no diffs)"

grep . $log && exit 13



exit
##############################################################################
##############################################################################
##############################################################################
# OLD

cmp build_before/.mflowgen/23-cadence-innovus-postroute/mflowgen-check-postconditions.py build_after/.mflowgen/23-cadence-innovus-postroute/mflowgen-check-postconditions.py

lsl build_before/.mflowgen/23-cadence-innovus-postroute/mflowgen-check-postconditions.py build_after/.mflowgen/23-cadence-innovus-postroute/mflowgen-check-postconditions.py




#       set -x
#       $fix_f1
#       exit
      # if ! diff $f1 $f2 -I design_ > /dev/null; then
#       diff <($fix_f1) $f2


          # diff <(sort $f1) <(sort $f2) -I design_

#           if ! diff <($fix_f1 | sort) <(sort $f2); then
#               echo BREAK;
#               break
#           fi
          
#           diff <($fix_f1 | sort) <(sort $f2) || FOUND_DIFF=1


