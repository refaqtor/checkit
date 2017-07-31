/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.reporter;

import checkit.block;
import std.stdio;
import std.string;
import std.conv;

interface ReporterInterface
{
  public:
    void success(TestBlock block);
    void fail(TestBlock block);
    void fail(string message);
    void printResults(TestBlock[] successBlocks, TestBlock[] failBlocks);
}

class ConsoleReporter: ReporterInterface
{
  public:
    void success(TestBlock block)
    {
      if(auto scenario = cast(ScenarioBlock) block)
      { 
        writeln();
        writeln(
          getColor(ConsoleColor.LIGHT_BLUE) ~
          to!string(scenario.getTags()) ~
          getColor(ConsoleColor.INITIAL)
        );
        printKeyValue("SCENARIO: ", block.getName(), ConsoleColor.LIGHT_YELLOW, ConsoleColor.LIGHT_GREEN);
      }
      else if(auto given = cast(GivenBlock) block)
      { 
        printKeyValue("   GIVEN: ", block.getName(), ConsoleColor.LIGHT_YELLOW, ConsoleColor.LIGHT_GREEN);
      }
      else if(auto when = cast(WhenBlock) block)
      { 
        printKeyValue("    WHEN: ", block.getName(), ConsoleColor.LIGHT_YELLOW, ConsoleColor.LIGHT_GREEN);
      }
      else if(auto then = cast(ThenBlock) block)
      { 
        printKeyValue("    THEN: ", block.getName(), ConsoleColor.LIGHT_YELLOW, ConsoleColor.LIGHT_GREEN);
      }
    }

    void fail(TestBlock block)
    {
      if(auto scenario = cast(ScenarioBlock) block)
      { 
        writeln();
        printKeyValue("SCENARIO: ", block.getName(), ConsoleColor.LIGHT_RED, ConsoleColor.LIGHT_RED);
      }
      else if(auto given = cast(GivenBlock) block)
      { 
        printKeyValue("   GIVEN: ", block.getName(), ConsoleColor.LIGHT_RED, ConsoleColor.LIGHT_RED);
      }
      else if(auto when = cast(WhenBlock) block)
      { 
        printKeyValue("    WHEN: ", block.getName(), ConsoleColor.LIGHT_RED, ConsoleColor.LIGHT_RED);
      }
      else if(auto then = cast(ThenBlock) block)
      { 
        printKeyValue("    THEN: ", block.getName(), ConsoleColor.LIGHT_RED, ConsoleColor.LIGHT_RED);
      }
    }

    void fail(string message)
    {
      writeln(
          getColor(ConsoleColor.LIGHT_RED) ~
          "   THROW: " ~
          message ~
          getColor(ConsoleColor.INITIAL)
          );
    }

    void printResults(TestBlock[] successBlocks, TestBlock[] failBlocks)
    {
      writeln();
      writeln("%sTotal %d, success %d, fail %d%s".format(
            getColor(ConsoleColor.LIGHT_GREEN), 
            successBlocks.length + failBlocks.length,
            successBlocks.length,
            failBlocks.length,
            getColor(ConsoleColor.INITIAL)));
    }

  private:
    void printKeyValue(string key, string value, ConsoleColor keyColor, ConsoleColor valueColor)
    {
      writeln(
          getColor(keyColor) ~ key ~ 
          getColor(valueColor) ~ value ~ 
          getColor(ConsoleColor.INITIAL)
      );
    }

    version(Posix)
    {
      enum ConsoleColor: ushort
      {
        LIGHT_RED = 95,
        LIGHT_GREEN = 96,
        LIGHT_YELLOW = 97,
        LIGHT_BLUE = 98,
        BRIGHT = 64,
        INITIAL = 256
      }

      string getColor(ConsoleColor color)
      {
        return "\033[%d;%d;%d;%d;%d;%dm".format(
          color & ConsoleColor.BRIGHT ? 1: 0,
          color & ~ConsoleColor.BRIGHT,
          (256 & !ConsoleColor.BRIGHT) + 10,
          24,
          29,
          21
          );
      }
    }
}
