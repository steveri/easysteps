# EASYSTEPS-ALT - Simpler mflowgen step creation (alternative version)

## What It Is

The main, more pythonic easysteps package is one level up from here. This alternative package uses an even simpler syntax, but it requires a parser to decode the new syntax.

This easysteps package is designed to simplify `construct.py` scripts for new mflowgen flows...it aims to reduce duplicated/unnecessary extra effort involved for various simple tasks. See https://github.com/mflowgen/mflowgen for a description of what mflowgen is and how to use it.

Without easysteps, adding a node/step involves modifying your `construct.py` script in three separate places, once to define the node, once to add the node to the graph, and once to connect it to the other nodes in the graph. For example, adding a couple of default nodes `iflow` and `init` currently looks like the code below (all "before" examples are taken from [test/design_before/Tile_PE/construct.py](https://github.com/steveri/easysteps/blob/master/easysteps-alt/test/design_before/Tile_PE/construct.py), (copied from Stanford's `garnet` project https://github.com/StanfordAHA/garnet).

```
    # Adding default nodes BEFORE:

    init   = Step( 'cadence-innovus-init',      default=True )
    power  = Step( 'cadence-innovus-power',     default=True )
    iflow  = Step( 'cadence-innovus-flowsetup', default=True )
    ...
    g.add_step( init  )
    g.add_step( power )
    g.add_step( iflow )
    ...
    g.connect_by_name( init,     power        )
    g.connect_by_name( power,    place        )
    g.connect_by_name( iflow,    init         )
    g.connect_by_name( iflow,    power        )
    g.connect_by_name( iflow,    place        )
    g.connect_by_name( iflow,    cts          )
    g.connect_by_name( iflow,    postcts_hold )
    g.connect_by_name( iflow,    route        )
    g.connect_by_name( iflow,    postroute    )
    g.connect_by_name( iflow,    signoff      )
    ...
```

Easysteps-alt combines all these steps in a single place in the script, e.g.
```
    # Adding default nodes AFTER:
 
    add_default_steps(g, '''
      init  - cadence-innovus-init  -> power
      power - cadence-innovus-power -> place
      iflow - cadence-innovus-flowsetup -> init power place cts postcts_hold
              route postroute signoff debugcalibre
    ''')
```
The string passed to this new method, yaml-like in simplicity, would be parsed and expanded, invisibly to the user, into the full `Step()/add_step()/connect_by_name()` sequence.

An identical `add_custom_steps()` method is provided for custom steps; and for convenience, I included an `extend_steps()` method for the common case where a custom step's sole purpose is to provide new inputs for an existing default step.
```
    add_custom_steps(g, '''
              rtl         - ../common/rtl -> synth
              constraints - constraints   -> synth iflow
    ''')
    extend_steps(g, '''
              custom_init  - custom-init                 -> init
              custom_power - ../common/custom-power-leaf -> power
    ''')
---
    # Can optionally be done as separate per-line calls e.g.
 
    extend_steps(g, 'custom-init                 - custom_init  -> init')
    extend_steps(g, '../common/custom-power-leaf - custom_power -> power')
```

After all `easysteps` have been added, there *must* be at least one final connect-everything call to put it all together
```
  # Complete all easysteps connections
  connect_outstanding_nodes(g, DBG=1)
```

For a more complete comparison see
* original syntax example `easysteps-alt/test/design_before/Tile_PE/construct.py`
* vs. easysteps version `easysteps-alt/test/design_after/Tile_PE/construct.py``


## How To Use It: Example

1. Download mflowgen and install mflowgen
```
    % git clone https://github.com/mflowgen/mflowgen.git
    % cd mflowgen; pip install -e .
```

2. Download easysteps and set env var EASYSTEPS_TOP
```
    % cd mflowgen
    % git clone https://github.com/steveri/easysteps.git
    % export EASYSTEPS_TOP=$PWD/easysteps/easysteps-alt
```
3. In each construct.py script, import easysteps packages
```
# mflowgen packages
from mflowgen.components import Graph, Step

# easysteps-alt packages
sys.path.append(os.environ.get('EASYSTEPS_TOP')
from easysteps import extend_steps
from easysteps import add_custom_steps
from easysteps import add_default_steps
from easysteps import connect_outstanding_nodes
```

For complete working example see `test/test.sh`
