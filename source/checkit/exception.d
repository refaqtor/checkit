/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.exception;

class UnitTestException: Exception
{
  public:
    this(in string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @safe pure nothrow
    {
      this([message], file, line, next);
    }

    this(in string[] messageLines, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @safe pure nothrow
    {
      import std.string: join;
      super(messageLines.join("\n"), next, file, line);
      _messageLines = messageLines;
    }

    override string toString() @safe const pure
    {
      import std.algorithm: map;
      import std.string: join;
      return () @trusted { return _messageLines.map!(a => getOutputPrefix(file, line) ~ a).join("\n"); }();
    }

  private:
    string getOutputPrefix(in string file, in size_t line) @safe const pure
    {
      import std.conv: to;
      return "  " ~ file ~ ":" ~ line.to!string ~ " - ";
    }

    const string[] _messageLines;
}
