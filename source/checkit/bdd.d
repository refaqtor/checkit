/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.bdd;

import checkit.block;
import checkit.blockmanager;

/** Used for SCENARIO block BDD

  Params:
    name = Name of scenario.
    tags = Array tags for scenario.
    expression = Tested block.
    V = BlockManagerInterface for collecting blocks

  Examples:
    ---
    scenario!("Test scenario", ["test"])
    ({
      writeln("TEST");
    });
    ---
*/
void scenario(string name, string[] tags, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  immutable TestCallback callback = delegate void(){expression()();};
  auto block = new ScenarioBlock(callback, name, tags);
  V.addBlock(block);
}

/** Used for GIVEN block BDD

  Params:
    name = Name of scenario.
    expression = Tested block.
    V = BlockManagerInterface for collecting blocks

  Examples:
    ---
    given!"Test given"
    ({
      writeln("TEST");
    });
    ---
*/
void given(string name, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  immutable TestCallback callback = delegate void(){expression()();};
  auto block = new GivenBlock(callback, name);
  V.addBlock(block);
}

/** Used for WHEN block BDD

  Params:
    name = Name of scenario.
    expression = Tested block.
    V = BlockManagerInterface for collecting blocks

  Examples:
    ---
    when!"Test when"
    ({
      writeln("TEST");
    });
    ---
*/
void when(string name, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  immutable TestCallback callback = delegate void(){expression()();};
  auto block = new WhenBlock(callback, name);
  V.addBlock(block);
}

/** Used for THEN block BDD

  Params:
    name = Name of scenario.
    expression = Tested block.
    V = BlockManagerInterface for collecting blocks

  Examples:
    ---
    then!"Test then"
    ({
      writeln("TEST");
    });
    ---
*/
void then(string name, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  immutable TestCallback callback = delegate void(){expression()();};
  auto block = new ThenBlock(callback, name);
  V.addBlock(block);
}
