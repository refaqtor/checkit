/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.runner;

import checkit.block;
import checkit.blockmanager;
import checkit.reporter;
import std.conv;
import std.getopt;
import std.stdio;

/// Interface for running test
interface RunnerInterface
{
  public:
    /// Run tests and return code
    int run();
}

/** Provide run BDD tests

  Params:
    T = BlockManagerInterface
*/
class BDDTestRunner(T): RunnerInterface
{
  public:
    /** Constructor

      Params:
        reporter = Provide reporting test.

      Examples:
        ---
        auto reporter = new ConsoleReporter();
        auto runner = new BDDTestRunner!(reporter);
        ---
    */
    this(ReporterInterface reporter)
    {
      _reporter = reporter;
    }

    /** Run tests and return code

    Returns:
        Return code $(D int) for main function

      Examples:
        ---
        auto reporter = new ConsoleReporter();
        auto runner = new BDDTestRunner!(reporter);
        runner.run();
        ---
    */
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

int runTests(string[] args)
{
  bool verbose = false;

  getopt(
    args,
    "verbose|v", &verbose
  );

  auto reporter = new ConsoleReporter;
  reporter.setVerbose(verbose);
  auto runner = new BDDTestRunner!BlockManager(reporter);
  return runner.run();
}
