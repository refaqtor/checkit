/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.block;

import std.uuid: randomUUID, UUID;

alias void delegate() TestCallback;

class TestBlock
{
  public:
    this(TestCallback callback, string name)
    {
      _callback = callback;
      _name = name;
      _uuid = randomUUID();
    }

    final UUID getUUID()
    {
      return _uuid;
    }

    final string getName()
    {
      return _name;
    }

    final TestCallback getCallback()
    {
      return _callback;
    }

  private:
    TestCallback _callback;
    UUID _uuid;
    string _name;
}

class ScenarioBlock: TestBlock
{
  public:
    this(TestCallback callback, string name, string[] tags)
    {
      super(callback, name);
      _tags = tags;
    }

    final string[] getTags()
    {
      return _tags;
    }

  private:
    string[] _tags;
}

final class GivenBlock: TestBlock
{
  public:
    this(TestCallback callback, string name)
    {
      super(callback, name);
    }
}

final class WhenBlock: TestBlock
{
  public:
    this(TestCallback callback, string name)
    {
      super(callback, name);
    }
}

final class ThenBlock: TestBlock
{
  public:
    this(TestCallback callback, string name)
    {
      super(callback, name);
    }
}
