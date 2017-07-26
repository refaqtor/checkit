/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.assertion;

import core.exception;
import std.traits;
import std.range;
import checkit.exception;
import std.algorithm.comparison: max, min;
import std.string;

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
void shouldBeNull(T)(in auto ref T value, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(value !is null)
  {
    fail(message !is null ? message : "Expected <null>, got <%s>".format(value), file, line);
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
void shouldNotBeNull(T)(in auto ref T value, string message = null, string file = __FILE__, size_t line = __LINE__)
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
void shouldEqual(T, U)(auto ref T value, auto ref U expected, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(!isEqual(value, expected))
  {
    fail(message !is null ? message : "Expected <%s>, got <%s>".format(expected, value), file, line);
	}
}

/** Used to assert that one value is not equal to another value.

  Params:
    a = The value to test.
    b = The value it should not be equal to.
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
void shouldNotEqual(T, U)(T value, U expected, string message = null, string file = __FILE__, size_t line = __LINE__)
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
void shouldBeTrue(T)(lazy T condition, string message = null, string file = __FILE__, size_t line = __LINE__)
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
void shouldBeFalse(T)(lazy T condition, string message = null, string file = __FILE__, size_t line = __LINE__)
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

  import std.stdio;
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
void shouldThrow(T: Throwable = Exception, E)(lazy E condition, string file = __FILE__, size_t line = __LINE__)
{
  import std.conv: text;
  import std.stdio;

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
    message = The message of exception.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If expression does throw, will throw an UnitTestException.

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
void shouldNotThrow(T: Throwable = Exception, E)(lazy E condition, string file = __FILE__, size_t line = __LINE__)
{
  if(threw!T(expr))
  {
    fail("Expression threw", file, line);
  }
}

void shouldThrowWithMessage(T: Throwable = Exception, E)(lazy E expr, string message, string file = __FILE__, size_t line = __LINE__)
{
  auto threw = threw!T(expr);
  if(!threw)
    fail("Expression did not throw", file, line);

  threw.throwable.msg.shouldEqual(message, file, line);
}

/** Used to assert that object is instance of class.

  Params:
    T = Excepted instance class.
    object = The object it should be instance of specific class.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If object is not instance of class, will throw an AssertError.

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
void shouldBeInstanceOf(T, U)(U object, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(cast(T)object is null)
  {
    if(!message)
    {
			message = "<%s> expected to be instance of <%s>.".format(object, T.classinfo.name);
		}

		throw new AssertError(message, file, line);
  }
}

/** Used to assert that one value is greater than another value.

  Params:
    a = The value to test.
    b = The value it should be greater than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not greater, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <5> expected to be greater than <10>."
    5.shouldBeGreater(10);
    ---
*/
void shouldBeGreater(T, U)(T a, U b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(a <= b)
  {
		if(!message)
    {
			message = "<%s> expected to be greater than <%s>.".format(a, b);
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that one value is greater or equal than another value.

  Params:
    a = The value to test.
    b = The value it should be greater or equal than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not greater or equal, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <5> expected to be greater or equal to <10>."
    5.shouldBeGreater(10);
    ---
*/
void shouldBeGreaterOrEqual(T, U)(T a, U b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(a < b)
  {
		if(!message)
    {
			message = "<%s> expected to be greater or equal to <%s>.".format(a, b);
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that one value is less than another value.

  Params:
    a = The value to test.
    b = The value it should be less than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not less, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <5> expected to be less than <10>."
    10.shouldBeLess(5);
    ---
*/
void shouldBeLess(T, U)(T a, U b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(a >= b)
  {
		if(!message)
    {
			message = "<%s> expected to be less than <%s>.".format(a, b);
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that one value is less or equal than another value.

  Params:
    a = The value to test.
    b = The value it should be less or equal than.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not less or equal, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <5> expected to be less or equal to <10>."
    10.shouldBeLessOrEqual(5);
    ---
*/
void shouldBeLessOrEqual(T, U)(T a, U b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(a > b)
  {
		if(!message)
    {
			message = "<%s> expected to be less or equal to <%s>.".format(a, b);
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that value is between two values.

  Params:
    value = The expected value
    a = The expected left value of range.
    b = The expected right value of range.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not between, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <5> expected to be between <15> and <20>."
    10.shouldBeBetween(15, 20);
    ---
*/
void shouldBeBetween(T, U, C)(T value, U a, C b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(value >= max(a,b) || value <= min(a,b))
  {
		if(!message)
    {
			message = "<%s> expected to be between <%s> and <%s>.".format(value, min(a, b), max(a, b));
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that value is between or equal two values.

  Params:
    value = The expected value
    a = The expected left value of range.
    b = The expected right value of range.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not between or equal, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <5> expected to be between <15> and <20>."
    10.shouldBeBetweenOrEqual(15, 20);
    ---
*/
void shouldBeBetweenOrEqual(T, U, C)(T value, U a, C b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(value > max(a,b) || value < min(a,b))
  {
		if(!message)
    {
			message = "<%s> expected to be between or equal <%s> and <%s>.".format(value, min(a, b), max(a, b));
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that one value is in an array of specified values.

  Params:
    value = The value to test.
    validValues = An array of valid values.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If the value is not in the array, will throw an AssertError with the value and array values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <Peter> is not in <[Andrew, Anatoly]>."
    "Peter".shouldBeIn(["Andrew", "Anatoly"]);
    ---
*/
void shouldBeIn(T, U)(T value, U[] validValues, string message = null, string file = __FILE__, size_t line = __LINE__)
{
	foreach (valid; validValues)
  {
		if(value == valid)
    {
      return;
		}
	}

  if(!message)
  {
	  message = "<%s> is not in <[%s]>.".format(value, validValues.join(", "));
  }

	throw new AssertError(message, file, line);
}

/** Used to assert that array is contain of specified value.

  Params:
    array = An array of values.
    validValue = The valid value.
    message = Exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.

  Throws:
    If an array is not contain the value, will throw an AssertError with the value and array values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <[Peter, Anatoliy]> is not contain <Andrew>."
    ["Peter", "Anatoly"].shouldBeContain("Andrew");
    ---
*/
void shouldBeContain(T, U)(T[] array, U validValue, string message = null, string file = __FILE__, size_t line = __LINE__)
{
	foreach (element; array)
  {
		if(validValue == element)
    {
      return;
		}
	}

  if(!message)
  {
	  message = "<[%s]> is not contain <%s>.".format(array.join(", "), validValue);
  }

	throw new AssertError(message, file, line);
}
