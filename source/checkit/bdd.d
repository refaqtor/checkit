/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.bdd;

import checkit.block;
import checkit.blockmanager;

void scenario(string name, string[] tags, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  TestCallback callback = delegate void(){expression()();};
  auto block = new ScenarioBlock(callback, name, tags);
  V.addBlock(block);
}

void given(string name, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  TestCallback callback = delegate void(){expression()();};
  auto block = new GivenBlock(callback, name);
  V.addBlock(block);
}

void when(string name, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  TestCallback callback = delegate void(){expression()();};
  auto block = new WhenBlock(callback, name);
  V.addBlock(block);
}

void then(string name, T, V: BlockManagerInterface = BlockManager)(lazy T expression)
{
  TestCallback callback = delegate void(){expression()();};
  auto block = new ThenBlock(callback, name);
  V.addBlock(block);
}
