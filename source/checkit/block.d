/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.block;

import std.uuid: randomUUID, UUID;

alias TestCallback = void delegate();

/// Block of code as expression
class TestBlock
{
  public:
    /** Constructor
      Params:
        callback = Lazy expression for run block.
        name = Name of block.

      Examples:
        ---
        auto block = new TestBlock({}, "Test");
        ---
    */
    this(TestCallback callback, string name)
    {
      _callback = callback;
      _name = name;
      _uuid = randomUUID();
    }

    /** Get UUID of block

      Returns:
        return $(D UUID) of test code block

      Examples:
        ---
        auto block = new TestBlock({}, "Test");
        block.getUUID();
        ---
    */
    final UUID getUUID()
    {
      return _uuid;
    }

    /** Get name of block

      Returns:
        return name $(D string) of test code block

      Examples:
        ---
        auto block = new TestBlock({}, "Test");
        assert(block.getName() == "Test");
        ---
    */
    final string getName()
    {
      return _name;
    }

    /** Get callback of block for run expression

      Returns:
        return callback delegate $(D TestCallback) of test code block

      Examples:
        ---
        auto block = new TestBlock({}, "Test");
        block.getCallback()();
        ---
    */
    final TestCallback getCallback()
    {
      return _callback;
    }

  private:
    /// Callback for run expression
    TestCallback _callback;
    /// UUID of block
    UUID _uuid;
    /// Name of block
    string _name;
}

/// Scenario code Block
class ScenarioBlock: TestBlock
{
  public:
    /** Constructor
      Params:
        callback = Lazy expression for run block.
        name = Name of block.
        tags = string array of tags scenario.

      Examples:
        ---
        auto block = new ScenarioBlock({}, "Test", ["test"]);
        ---
    */
    this(TestCallback callback, string name, string[] tags)
    {
      super(callback, name);
      _tags = tags;
    }

    /** Get tags of scenario block

      Returns:
        return tags $(D string[]) of scenario block

      Examples:
        ---
        auto block = new ScenarioBlock({}, "Test", ["test"]);
        assert(block.getTags() == ["test"]);
        ---
    */
    final string[] getTags()
    {
      return _tags;
    }

  private:
    string[] _tags;
}

/// Given code Block
final class GivenBlock: TestBlock
{
  public:
    /** Constructor
      Params:
        callback = Lazy expression for run block.
        name = Name of block.

      Examples:
        ---
        auto block = new GivenBlock({}, "Test");
        ---
    */
    this(TestCallback callback, string name)
    {
      super(callback, name);
    }
}

/// When code Block
final class WhenBlock: TestBlock
{
  public:
    this(TestCallback callback, string name)
    {
      super(callback, name);
    }
}

/// Then code Block
final class ThenBlock: TestBlock
{
  public:
    this(TestCallback callback, string name)
    {
      super(callback, name);
    }
}
