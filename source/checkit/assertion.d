/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.assertion;

import core.exception;

/** Used to assert that one value is equal to null.

  Params:
    object = The value that should equal null.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If value is NOT null, will throw an AssertError.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): expected to be <null>."
    string test = "blah";
    test.shouldBeNull();
    ---
*/
void shouldBeNull(T)(T object, string message=null, string file=__FILE__, size_t line=__LINE__)
{
  if(object !is null)
  {
    if(!message)
    {
      message = "Expected to be null!";
    }

    throw new AssertError(message, file, line);
  }
}
