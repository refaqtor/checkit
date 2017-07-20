/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.assertion;

import core.exception;
import std.algorithm.comparison: max, min;
import std.string;

/** Used to assert that one value is equal to null.

  Params:
    object = The value that should equal null.
    message = The exception message.
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
void shouldBeNull(T)(T object, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  if(object !is null)
  {
    if(!message)
    {
      message = "expected to be <null>.";
    }

    throw new AssertError(message, file, line);
  }
}

/** Used to assert that one value is not equal to null.

  Params:
    object = The value that should not equal null.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If value is null, will throw an AssertError.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): expected to not be <null>."
    string test = null;
    test.shouldNotBeNull();
    ---
*/
void shouldNotBeNull(T)(T object, string message = null, string file = __FILE__, size_t line = __LINE__)
{
	if(object is null)
  {
		if(!message)
    {
			message = "expected to not be <null>.";
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that one value is equal to another value.

  Params:
    a = The value to test.
    b = The value it should be equal to.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If values are not equal, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <3> expected to equal <5>."
    int z = 3;
    z.shouldEqual(5);
    ---
*/
void shouldEqual(T, U)(T a, U b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
	if(a != b)
  {
		if(!message)
    {
			message = "<%s> expected to equal <%s>.".format(a, b);
		}

		throw new AssertError(message, file, line);
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
    If values are equal, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <3> expected to not equal <5>."
    "abc".shouldEqual("abc");
    ---
*/
void shouldNotEqual(T, U)(T a, U b, string message = null, string file = __FILE__, size_t line = __LINE__)
{
	if(a == b)
  {
		if(!message)
    {
			message = "<%s> expected to not equal <%s>.".format(a, b);
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that one value is equal to true.

  Params:
    object = The value that should equal true.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If values are not true, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <false> expected to bee <true>."
    false.shouldBeTrue();
    ---
*/
void shouldBeTrue(T)(T object, string message = null, string file = __FILE__, size_t line = __LINE__)
{
	if(object !is true)
  {
		if(!message)
    {
			message = "<%s> expected to be <true>.".format(object);
		}

		throw new AssertError(message, file, line);
	}
}

/** Used to assert that one value is equal to false.

  Params:
    object = The value that should equal false.
    message = The exception message.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If values are not false, will throw an AssertError with expected and actual values.

  Examples:
    ---
    // Will throw an exception like "AssertError@example.d(6): <true> expected to bee <false>."
    true.shouldBeFalse();
    ---
*/
void shouldBeFalse(T)(T object, string message = null, string file = __FILE__, size_t line = __LINE__)
{
	if(object !is false)
  {
		if(!message)
    {
			message = "<%s> expected to be <false>.".format(object);
		}

		throw new AssertError(message, file, line);
	}
}

/** Used for asserting that a delegate will throw an exception.

  Params:
    func = The delegate that is expected to throw the exception.
    message = The message that is expected to be in the exception. Will not be tested, if it is null.
    file = The file name that the assert failed in. Should be left as default.
    line = The file line that the assert failed in. Should be left as default.
  Throws:
    If delegate does NOT throw, will throw an AssertError.

  Examples:
    ---
    // Makes sure it throws with the message "test"
    shouldThrow(delegate()
    {
	    throw new Exception("boom!");
    }, "test");

    // Makes sure it throws, but does not check the message
    shouldThrow(delegate(){
	    throw new Exception("test");
    });

    // Will throw an exception like "AssertError@test/example.d(7): Exception was not thrown. Expected: test"
    shouldThrow(delegate(){}, "test");

    // Will throw an exception like "AssertError@test/example.d(7): Exception was not thrown. Expected one.
    shouldThrow(delegate(){});
    ---
*/
void shouldThrow(void delegate() func, string message = null, string file = __FILE__, size_t line = __LINE__)
{
  bool hasThrown = false;

	try
  {
		func();
	}
  catch(Throwable exception)
  {
		if(message && message != exception.msg)
    {
			throw new AssertError("Exception was thrown. But expected: " ~ message, file, line);
		}

		hasThrown = true;
	}

	if(!hasThrown)
  {
		if(message)
    {
			throw new AssertError("Exception was not thrown. Expected: " ~ message, file, line);
		}
    else
    {
			throw new AssertError("Exception was not thrown. Expected one.", file, line);
		}
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
