/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module catchd.assertion;

void shouldBeNull(T)(T object, string message=null, string file=__FILE__, size_t line=__LINE__)
{
  if(object !is null)
  {
    if(!message)
    {
      message = "expected to be <null>.";
    }

    message = message.replace("\r", "\\r").replace("\n", "\\n");
    throw new AssertError(message, file, line);
  }
}
