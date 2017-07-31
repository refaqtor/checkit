/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.assertion;

import checkit.exception;
import core.exception;
import std.algorithm.comparison: max, min;
import std.range;
import std.string;
import std.traits;
import std.conv;

private void fail(in string output, in string file, in size_t line) @safe pure
{
  throw new UnitTestException([output], file, line);
}

/** Used to assert that one value is equal to null.

  Params:
    value = The value that should equal null.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If value is NOT null, will throw an UnitTestException.

  Examples:
    ---
    // Will throw an exception like "checkit.exception.UnitTestException@example.d(6): Expected <null>, got <blah>."
    string test = "blah";
    test.shouldBeNull();
    ---
*/
void shouldBeNull(T)( in auto ref T value, 
                      in string message = null,
                      in string file = __FILE__, 
                      in size_t line = __LINE__)
{
  if(value !is null)
  {
    fail(message !is null ? message : "Expected <null>", file, line);
  }
}

/** Used to assert that one value is not equal to null.

  Params:
    value = The value that should not equal null.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If value is null, will throw an UnitTestException.

  Examples:
    ---
    // Will throw an exception like "checkit.exception.UnitTestException@example.d(6): Expected not <null>, got <null>"
    string test = null;
    test.shouldNotBeNull();
    ---
*/
void shouldNotBeNull(T)(in auto ref T value, 
                        in string message = null, 
                        in string file = __FILE__, 
                        in size_t line = __LINE__)
{
	if(value is null)
  {
    fail(message !is null ? message : "Expected not <null>, got <null>", file, line);
	}
}

private enum isObject(T) = is(T == class) || is(T == interface);

private bool isEqual(V, E)(in auto ref V value, in auto ref E expected)
  if(!isObject!V &&
    (!isInputRange!V || !isInputRange!E) &&
    !isFloatingPoint!V && !isFloatingPoint!E &&
    is(typeof(value == expected) == bool))
{
  return value == expected;
}

private bool isEqual(V, E)(in V value, in E expected)
 if (!isObject!V && (isFloatingPoint!V || isFloatingPoint!E) && is(typeof(value == expected) == bool))
{
  return value == expected;
}

private bool isEqual(V, E)(V value, E expected)
if (!isObject!V && isInputRange!V && isInputRange!E && is(typeof(value.front == expected.front) == bool))
{
  import std.algorithm: equal;
  return equal(value, expected);
}

private bool isEqual(V, E)(V value, E expected)
if (!isObject!V &&
    isInputRange!V && isInputRange!E && !is(typeof(value.front == expected.front) == bool) &&
    isInputRange!(ElementType!V) && isInputRange!(ElementType!E))
{
  import std.algorithm: equal;

  while(!value.empty && !expected.empty)
  {
    if(!equal(value.front, expected.front))
      return false;

    value.popFront;
    expected.popFront;
  }
    
  return value.empty && expected.empty;
}

private bool isEqual(V, E)(V value, E expected)
if (isObject!V && isObject!E)
{
  static assert(is(typeof(()
  {
    string s1 = value.toString;
    string s2 = expected.toString;
  })), "Cannot compare instances of " ~ V.stringof ~ " or " ~ E.stringof ~ " unless toString is overridden for both");

  return value.tupleof == expected.tupleof;
}

/** Used to assert that one value is equal to another value.

  Params:
    value = The value.
    expected = The expected value.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If values are not equal, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "checkit.exception.UnitTestException@example.d(6): <3> expected to equal <5>."
    int z = 3;
    z.shouldEqual(5);
    ---
*/
void shouldEqual(T, U)( auto ref T value, 
                        auto ref U expected, 
                        in string message = null, 
                        in string file = __FILE__, 
                        in size_t line = __LINE__)
{
  if(!isEqual(value, expected))
  {
    fail(message !is null ? message : "Expected <%s>, got <%s>".format(expected, value), file, line);
	}
}

/** Used to assert that one value is not equal to another value.

  Params:
    value = The value to test.
    expected = The value it should not be equal to.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If values are equal, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "checkit.exception.UnitTestException@example.d(6): Expected not <abc>, got <abc>"
    "abc".shouldNotEqual("abc");
    ---
*/
void shouldNotEqual(T, U)(T value, U expected, 
                          in string message = null, 
                          in string file = __FILE__, 
                          in size_t line = __LINE__)
{
	if(isEqual(value, expected))
  {
    fail(message !is null ? message : "Expected not <%s>, got <%s>".format(expected, value), file, line);
	}
}

/** Used to assert that one value is equal to true.

  Params:
    condition = The value that should equal true.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If values are not true, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "checkit.exception.UnitTestException@example.d(6): Expected <true>, got <false>"
    false.shouldBeTrue();
    ---
*/
void shouldBeTrue(T)(lazy T condition, in string message = null, in string file = __FILE__, in size_t line = __LINE__)
{
  shouldEqual(cast(bool) condition, true, message, file, line);
}

/** Used to assert that one value is equal to false.

  Params:
    condition = The value that should equal false.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If values are not false, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "checkit.exception.UnitTestException@example.d(6): Expected <false>, got <true>"
    true.shouldBeFalse();
    ---
*/
void shouldBeFalse(T)(lazy T condition, in string message = null, in string file = __FILE__, in size_t line = __LINE__)
{
  shouldEqual(cast(bool) condition, false, message, file, line);
}

private auto threw(T: Throwable, E)(lazy E expr) @trusted
{
  struct ThrowResult
  {
    bool threw;
    TypeInfo typeInfo;
    immutable(T) throwable;

    T opCast(T)() const pure if (is(T == bool))
    {
      return threw;
    }
  }

  try
  {
    expr();
  }
  catch(T e)
  {
    return ThrowResult(true, typeid(e), cast(immutable)e);
  }

  return ThrowResult(false);
}

/** Used for asserting that a expression will throw an exception.

  Params:
    condition = The expression that is expected to throw the exception.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If expression does not throw, will throw an UnitTestException.

  Examples:
    ---
    // Makes sure it throws with the message "test"
    void noThrow(){};
    void withThrow(){throw new Exception("test");};
    
    // Will throw an exception like "checkit.exception.UnitTestException@test/example.d(7): Expression did not throw"
    noThrow.shouldThrow();
    // Will throw an exception like "checkit.exception.UnitTestException@test/example.d(7): Expression did not throw"
    noThrow.shouldThrow!Exception();

    // Will throw an exception like "checkit.exception.UnitTestException@test/example.d(7): Expected <UnitTestException>, but throw <object.Exception>"
    withThrow.shouldThrow!UnitTestException();
    ---
*/
void shouldThrow(T: Throwable = Exception, E)(lazy E condition, in string file = __FILE__, in size_t line = __LINE__)
{
  import std.conv: text;

  bool isThrow = true;

  () @trusted
  {
    try
    {
      if(!threw!T(condition))
      {
        isThrow = false;
      }
    }
    catch(Throwable t)
    {
        fail(text("Expected <", T.stringof, ">, but throw <", typeid(t), ">"), file, line);
    }
  }();

  if(!isThrow)
  {
    fail("Expression did not throw", file, line);
  }
}

/** Used for asserting that a expression will not throw an exception.

  Params:
    condition = The expression that is expected to not throw the exception.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If expression does throw, will throw an UnitTestException.

  Examples:
    ---
    // Makes sure it throws with the message "test"
    void noThrow(){};
    void withThrow(){throw new Exception("test");};
    
    // Will throw an exception like "checkit.exception.UnitTestException@test/example.d(7): Expression threw"
    noThrow.shouldNotThrow();
    ---
*/
void shouldNotThrow(T: Throwable = Exception, E)(lazy E condition, in string file = __FILE__, in size_t line = __LINE__)
{
  if(threw!T(condition))
  {
    fail("Expression threw", file, line);
  }
}

/** Used for asserting that a expression will throw an exception with message.

  Params:
    condition = The expression that is expected to throw the exception.
    message = Expected message exception.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If expression does throw and message not expected, will throw an UnitTestException.

  Examples:
    ---
    // Makes sure it throws with the message "test"
    void withThrow(){throw new Exception("test");};
    
    // Will throw an exception like "checkit.exception.UnitTestException@test/example.d(7): Expression did not throw"
    withThrow.shouldThrowWithMessage("bar");
    ---
*/
void shouldThrowWithMessage(T: Throwable = Exception, E)( lazy E condition, 
                                                          in string message, 
                                                          in string file = __FILE__, 
                                                          in size_t line = __LINE__)
{
  auto threw = threw!T(condition);

  if(!threw)
    fail("Expression did not throw", file, line);

  if(message != threw.throwable.msg)
  {
    fail("Expected exception message <%s>, but got <%s>".format(message, threw.throwable.msg), file, line);
  }
}

/** Used to assert that object is instance of class.

  Params:
    T = Excepted instance class.
    object = The object it should be instance of specific class.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If object is not instance of class, will throw an UnitTestException.

  Examples:
    ---
    interface DummyInterface
    {
      public:
        void test();
    }

    class Dummy: DummyInterface
    {
      public:
        override test()
        {
        }
    }

    auto a = new Dummy;
    auto b = cast(DummyInterface) a;
    b.shouldBeInstanceOf!Dummy();
    ---
*/
void shouldBeInstanceOf(T, U)(U object, in string message = null, in string file = __FILE__, in size_t line = __LINE__)
{
  if(cast(T)object is null)
  {
    fail(message ? message : "<%s> expected to be instance of <%s>".format(object, T.classinfo.name), file, line);
  }
}

/** Used to assert that one value is greater than another value.

  Params:
    value = The value to test.
    expected = The value it should be greater than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not greater, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <5> expected to be greater than <10>."
    5.shouldBeGreater(10);
    ---
*/
void shouldBeGreater(T, U)( T value, 
                            U expected, 
                            in string message = null, 
                            in string file = __FILE__, 
                            in size_t line = __LINE__)
{
  if(value <= expected)
  {
    fail(message ? message : "<%s> expected to be greater than <%s>".format(value, expected), file, line);
	}
}

/** Used to assert that one value is greater or equal than another value.

  Params:
    value = The value to test.
    expected = The value it should be greater or equal than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not greater or equal, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <5> expected to be greater or equal to <10>."
    5.shouldBeGreater(10);
    ---
*/
void shouldBeGreaterOrEqual(T, U)(T value, 
                                  U expected, 
                                  in string message = null, 
                                  in string file = __FILE__, 
                                  in size_t line = __LINE__)
{
  if(value < expected)
  {
    fail(message ? message : "<%s> expected to be greater or equal to <%s>".format(value, expected), file, line);
	}
}

/** Used to assert that one value is less than another value.

  Params:
    value = The value to test.
    expected = The value it should be less than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not less, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <5> expected to be less than <10>."
    10.shouldBeLess(5);
    ---
*/
void shouldBeLess(T, U)(T value, 
                        U expected, 
                        in string message = null, 
                        in string file = __FILE__, 
                        in size_t line = __LINE__)
{
  if(value >= expected)
  {
    fail(message ? message : "<%s> expected to be less than <%s>".format(value, expected), file, line);
	}
}

/** Used to assert that one value is less or equal than another value.

  Params:
    value = The value to test.
    expected = The value it should be less or equal than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not less or equal, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <5> expected to be less or equal to <10>."
    10.shouldBeLessOrEqual(5);
    ---
*/
void shouldBeLessOrEqual(T, U)( T value, 
                                U expected, 
                                in string message = null, 
                                in string file = __FILE__, 
                                in size_t line = __LINE__)
{
  if(value > expected)
  {
    fail(message ? message : "<%s> expected to be less or equal to <%s>".format(value, expected), file, line);
	}
}

/** Used to assert that value is between two values.

  Params:
    value = The expected value
    left = The expected left value of range.
    right = The expected right value of range.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not between, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <5> expected to be between <15> and <20>."
    10.shouldBeBetween(15, 20);
    ---
*/
void shouldBeBetween(T, U, C)(T value, 
                              U left, 
                              C right, 
                              in string message = null, 
                              in string file = __FILE__, 
                              in size_t line = __LINE__)
{
  if(value >= max(left,right) || value <= min(left,right))
  {
    fail( message ? message : "<%s> expected to be between <%s> and <%s>".format( value, 
                                                                                  min(left, right), 
                                                                                  max(left, right)),
          file, 
          line);
	}
}

/** Used to assert that value is between or equal two values.

  Params:
    value = The expected value
    left = The expected left value of range.
    right = The expected right value of range.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not between or equal, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <5> expected to be between <15> and <20>."
    10.shouldBeBetweenOrEqual(15, 20);
    ---
*/
void shouldBeBetweenOrEqual(T, U, C)( T value, 
                                      U left, 
                                      C right, 
                                      string message = null, 
                                      string file = __FILE__, 
                                      size_t line = __LINE__)
{
  if(value > max(left,right) || value < min(left,right))
  {
    fail( message ? message : "<%s> expected to be between or equal <%s> and <%s>".format( value, 
                                                                                          min(left, right), 
                                                                                          max(left, right)), 
          file, 
          line);
	}
}

/** Used to assert that Range is empty.

  Params:
    rng = The expected Range.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the Range is not empty, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): Expected empty Range, but got <[1]>"
    [1].shouldBeEmpty();
    ---
*/
void shouldBeEmpty(R)(in auto ref R rng, in string message = null, in string file = __FILE__, in size_t line = __LINE__)
if (isInputRange!R)
{
  if(!rng.empty)
  {
    fail(message ? message : "Expected empty Range, but got <%s>".format(rng), file, line);
  }
}

/** Used to assert that Associative array is empty.

  Params:
    aa = The expected associative array.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the Associative array is not empty, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): Expected empty Associative Array, but got <["test":12]>"
    ["test":12].shouldBeEmpty();
    ---
*/
void shouldBeEmpty(T)(auto ref T aa, in string message = null, in string file = __FILE__, in size_t line = __LINE__)
if(isAssociativeArray!T)
{
  () @trusted
  { 
    if(!aa.keys.empty)
    {
      fail(message ? message : "Expected empty Associative Array, but got <%s>".format(aa), file, line); 
    }
  }();
}

/** Used to assert that Range is not empty.

  Params:
    rng = The expected Range.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the Range is empty, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): Expected is not empty Range"
    [1].shouldBeEmpty();
    ---
*/
void shouldBeNotEmpty(R)( in auto ref R rng, 
                          in string message = null, 
                          in string file = __FILE__, 
                          in size_t line = __LINE__)
if (isInputRange!R)
{
  if(rng.empty)
  {
    fail(message ? message : "Expected is not empty Range", file, line);
  }
}

/** Used to assert that Associative array is not empty.

  Params:
    aa = The expected associative array.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the Associative array is empty, will throw an UnitTestException with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): Expected is not empty Associative Array"
    ["test":12].shouldBeEmpty();
    ---
*/
void shouldBeNotEmpty(T)(auto ref T aa, in string message = null, in string file = __FILE__, in size_t line = __LINE__)
if(isAssociativeArray!T)
{
  () @trusted
  { 
    if(aa.keys.empty)
    {
      fail(message ? message : "Expected is not empty Associative Array", file, line); 
    }
  }();
}

/** Used to assert that one value is in an array of specified values.

  Params:
    value = The value to test.
    expected = An array of valid values.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not in the array, will throw an UnitTestException with the value and array values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <Peter> is not in <[Andrew, Anatoly]>."
    "Peter".shouldBeIn(["Andrew", "Anatoly"]);
    ---
*/
void shouldBeIn(T, U)(T value, 
                      U expected, 
                      in string message = null, 
                      in string file = __FILE__, 
                      in size_t line = __LINE__)
{
  import std.algorithm: canFind;

  if(!expected.canFind(value))
  {
    fail(message ? message : "<%s> is not in <[%s]>".format(value, expected.join(", ")), file, line); 
	}
}

/** Used to assert that array is contain of specified value.

  Params:
    array = An array of values.
    expected = The valid value.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If an array is not contain the value, will throw an UnitTestException with the value and array values.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): <[Peter, Anatoliy]> is not contain <Andrew>."
    ["Peter", "Anatoly"].shouldBeContain("Andrew");
    ---
*/
void shouldBeContain(T, U)( T[] array, 
                            U expected, 
                            in string message = null, 
                            in string file = __FILE__, 
                            in size_t line = __LINE__)
{
  import std.algorithm: canFind;

  if(!array.canFind(expected))
  {
    fail(message ? message : "<[%s]> is not contain <%s>".format(array.join(", "), expected), file, line); 
  }
}

/** Used to assert that JSON object is equal.

  Params:
    actual = The actual JSON object.
    expected = The excpected JSON.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If an JSON objects is not equal, will throw an UnitTestException.

  Examples:
    ---
    // Will throw an exception like "UnitTestException@example.d(6): Error parsing JSON: Unexpected end of data. (Line 1:10)"
    `{"test" :1`.shouldBeEqualJSON(`{"test":1}`);
 
    // Will throw an exception like "UnitTestException@example.d(6):`{"test" :1, "some" : "12"}`.shouldBeEqualJSON(`{"test":1}`);
    `{"test" :1, "some" : "12"}`.shouldBeEqualJSON(`{"test":1}`);
    ---
*/
void shouldBeEqualJSON( in string actual, 
                        in string expected, 
                        in string message = null, 
                        in string file = __FILE__, 
                        in size_t line = __LINE__)
{
  import std.json: JSONException, JSONValue, parseJSON;

  try
  {
    actual.parseJSON.toPrettyString.shouldEqual(expected.parseJSON.toPrettyString, message, file, line);
  }
  catch(JSONException e)
  {
    fail("Error parsing JSON: " ~ e.msg, file, line);
  }
}
