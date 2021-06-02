# EASYSTEPS - Simpler mflowgen step creation

| Status                       |
|------------------------------|
| [![linux build status][1]][2]|

[1]: https://travis-ci.org/steveri/easysteps.svg?branch=master
[2]: https://travis-ci.org/steveri/easysteps


## What It Is

This `easysteps` package is designed to simplify `construct.py` scripts for new [mflowgen](https://github.com/mflowgen/mflowgen) flows; it aims to reduce duplicated/unnecessary extra effort involved for various simple tasks. See https://github.com/mflowgen/mflowgen for a description of what `mflowgen` is and how to use it.

Without easysteps, adding a node/step involves modifying your `construct.py` script in three separate places, once to define the node, once to add the node to the graph, and once to connect it to the other nodes in the graph, as in the "original syntax" examples below. (Note all "original syntax" examples are taken from [test/design_before/Tile_PE/construct.py](https://github.com/steveri/easysteps/blob/master/test/design_before/Tile_PE/construct.py), (copied from Stanford's `garnet` project https://github.com/StanfordAHA/garnet).

The main benefit of easysteps is the ability to define, add, and connect a new custom or default step all in the same place within the construct.py script, as in the "new syntax" examples below. (Also see [design_after/Tile_PE/construct.py](https://github.com/steveri/easysteps/blob/master/test/design_after/Tile_PE/construct.py)

```
ORIGINAL SYNTAX:

  custom_genus_scripts = Step( this_dir + '/custom-genus-scripts' )
  synth = Step( 'cadence-genus-synthesis', default=True )

  # Later in the script
  synth.extend_inputs( custom_genus_scripts.all_outputs() )

  # Later still
  g.add_step( synth                    )
  g.add_step( custom_genus_scripts     )

  # Later yet again
  g.connect_by_name( custom_genus_scripts, synth )
  g.connect_by_name( synth,       iflow                )
  g.connect_by_name( synth,       init                 )
  g.connect_by_name( synth,       power                )
  g.connect_by_name( synth,       place                )
  g.connect_by_name( synth,       cts                  )
  g.connect_by_name( synth,       custom_flowgen_setup )

NEW SYNTAX:
  custom_genus_scripts = EStep( g, 'custom-genus-scripts', 'synth' )
  synth = DStep( g, 'cadence-genus-synthesis', 'iflow, init, power, place, cts, custom_flowgen_setup')


```

This new version also introduces a convenience method `reorder()` for adding/removing tcl scripts sourced by an existing step:

```
ORIGINAL SYNTAX:
      order = place.get_param('order')
      read_idx = order.index( 'main.tcl' ) # find main.tcl
      order.insert(read_idx + 1, 'add-aon-tie-cells.tcl')
      order.insert(read_idx - 1, 'place-dont-use-constraints.tcl')
      order.append('check-clamp-logic-structure.tcl')
      place.update_params( { 'order': order } ) 

NEW SYNTAX:
      reorder(place,
              'after  main.tcl: add-aon-tie-cells.tcl',
              'before main.tcl: place-dont-use-constraints.tcl',
              'last           : check-clamp-logic-structure.tcl')
```

For a more complete comparison see
* original syntax example `easysteps/test/design_before/Tile_PE/construct.py`
* vs. easysteps version `easysteps/test/design_after/Tile_PE/construct.py``

## How To Use It: Example

See complete working example `test/test.sh` for how to use easysteps. Briefly, it's something like this:

1. Download mflowgen and install mflowgen
```
    % git clone https://github.com/mflowgen/mflowgen.git
    % cd mflowgen; pip install -e .
```

2. Download easysteps and set env var EASYSTEPS_TOP
```
    % cd mflowgen
    % git clone https://github.com/steveri/easysteps.git
    % export EASYSTEPS_TOP=$PWD/easysteps

```
3. In each construct.py script, import easysteps packages
```
from mflowgen.components import Graph, Step

# easysteps-alt packages
sys.path.append(os.environ.get('EASYSTEPS_TOP')
from easysteps import extend_steps
from easysteps import add_custom_steps
from easysteps import add_default_steps
from easysteps import connect_outstanding_nodes
```

For complete working example see 


------------------------------------------------------------------------------
OLD/DELETE

Alternate, more pythonic, version of easysteps. See before-and-after file compare of 
`construct.py` for changes vs. original syntax. 


