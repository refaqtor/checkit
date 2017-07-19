import checkit.assertion;

import core.exception;

/// shouldBeNull - should succeed when object is null
unittest
{
  string value = null;
  value.shouldBeNull();
}

/// shouldBeNull - should fail when object is not null
unittest
{
  string value = "test";
  try
  {
    value.shouldBeNull();
    assert(false);
  }
  catch(AssertError e)
  { 
    assert(true);
  }
}
