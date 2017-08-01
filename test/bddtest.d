import checkit;
import std.algorithm: canFind;
import std.stdio;
import std.conv;
import std.uuid: UUID;

unittest
{
  scenario!("Test scenario", ["1", "2"])({});
  assert(BlockManager.getByType!ScenarioBlock().length == 1);
  auto block = BlockManager.getByType!ScenarioBlock()[0];
  assert(block.getName() == "Test scenario");
  assert((cast(ScenarioBlock) block).getTags() == ["1", "2"]);
  BlockManager.removeBlockByUUID(block.getUUID());
  assert(BlockManager.getByType!ScenarioBlock().length == 0);
}

unittest
{
  given!"Test given"({});
  assert(BlockManager.getByType!GivenBlock().length == 1);
  auto block = BlockManager.getByType!GivenBlock()[0];
  assert(block.getName() == "Test given");
  BlockManager.removeBlockByUUID(block.getUUID());
  assert(BlockManager.getByType!GivenBlock().length == 0);
}

unittest
{
  when!"Test when"({});
  assert(BlockManager.getByType!WhenBlock().length == 1);
  auto block = BlockManager.getByType!WhenBlock()[0];
  assert(block.getName() == "Test when");
  BlockManager.removeBlockByUUID(block.getUUID());
  assert(BlockManager.getByType!WhenBlock().length == 0);
}

unittest
{
  then!"Test then"({});
  assert(BlockManager.getByType!ThenBlock().length == 1);
  auto block = BlockManager.getByType!ThenBlock()[0];
  assert(block.getName() == "Test then");
  BlockManager.removeBlockByUUID(block.getUUID());
  assert(BlockManager.getByType!ThenBlock().length == 0);
}

unittest
{
  scenario!("Buy last coffee", ["cofee"])
  ({
    given!"There is 1 coffee left in the machine"
    ({
      when!"I press the coffee button"
      ({
        then!"I should be served a coffee"
        ({
          throw new Exception("sdsdf");
        });
      });
    });
    then!"Error block"
    ({
    });
  });

  assert(runTests(["test", "-v"]) == -1);
  assert(runTests(["test"]) == 0);
}

/// Run test quite
unittest
{

}
