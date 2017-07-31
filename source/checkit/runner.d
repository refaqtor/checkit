/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.runner;

import checkit.block;
import checkit.reporter;
import checkit.blockmanager;

import std.stdio;
import std.conv;

interface RunnerInterface
{
  public:
    int run();
}

class BDDTestRunner(T): RunnerInterface
{
  public:
    this(ReporterInterface reporter)
    {
      _reporter = reporter;
    }

    int run()
    {
      _returnCode = 0;
      _failBlocks = [];
      _successBlocks = [];
      checkNoBlock!GivenBlock();
      checkNoBlock!WhenBlock();
      checkNoBlock!ThenBlock();

      foreach(scenario; T.getByType!ScenarioBlock())
      {
        runBlock(scenario);
      }

      _reporter.printResults(_successBlocks, _failBlocks);

      return _returnCode;
    }

  private:

    void checkNoBlock(U)()
    {
      U[] blocks = T.getByType!U();
      if(blocks.length)
      {
        _returnCode = -1;

        foreach(block; blocks)
        {
          T.removeBlockByUUID(block.getUUID());
        }
      }
    }

    void runBlock(ScenarioBlock block)
    {
      checkNoBlock!WhenBlock();
      checkNoBlock!ThenBlock();

      executeBlock(block);
      foreach(given; T.getByType!GivenBlock())
      {
        runBlock(given);
      }
    }

    void runBlock(GivenBlock block)
    {
      checkNoBlock!ThenBlock();

      executeBlock(block);
      foreach(when; T.getByType!WhenBlock())
      {
        runBlock(when);
      }
    }

    void runBlock(WhenBlock block)
    {
      executeBlock(block);
      foreach(then; T.getByType!ThenBlock())
      {
        executeBlock(then);
      }
    }

    void executeBlock(U)(U block)
    {
      try
      {
        block.getCallback()();
        _reporter.success(block);
        _successBlocks ~= block;
      }
      catch(Exception e)
      {
        _returnCode = -1;
        _failBlocks ~= block;
        _reporter.fail(block);
        _reporter.fail(typeid(e).toString() ~ "@" ~ e.file ~ "(" ~ to!string(e.line) ~ "): " ~ e.msg);
      }

      T.removeBlockByUUID(block.getUUID());
    }

    ReporterInterface _reporter;
    int _returnCode;
    TestBlock[] _successBlocks;
    TestBlock[] _failBlocks;
}

int runTests()
{
  auto reporter = new ConsoleReporter;
  auto runner = new BDDTestRunner!BlockManager(reporter);
  return runner.run();
}
