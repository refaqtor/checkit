/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.exception;

/// Exception fot unit tests
class UnitTestException: Exception
{
  public:
    /** Constructor with string

      Params:
        message = Exception message.
        file = The file name that the assert failed in. Should be left as default.
        line = The file line that the assert failed in. Should be left as default.
        next = Next Throwable object.
    */
    this(in string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @safe pure nothrow
    {
      this([message], file, line, next);
    }

    /** Constructor with list strings

      Params:
        messageLines = Exception message list.
        file = The file name that the assert failed in. Should be left as default.
        line = The file line that the assert failed in. Should be left as default.
        next = Next Throwable object. Should be left as default.
    */
    this(in string[] messageLines, string file = __FILE__, size_t line = __LINE__, Throwable next = null) @safe pure nothrow
    {
      import std.string: join;
      super(messageLines.join("\n"), next, file, line);
      _messageLines = messageLines;
    }

  private:
    const string[] _messageLines;
}
