import checkit.assertion;

import core.exception;
import checkit.exception;
import std.functional;

interface DummyInterface
{
  public:
    void test();
}

class TestDummy: DummyInterface
{
  public:
    override void test(){}
}

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
  catch(UnitTestException e)
  { 
    assert(e.msg == "Expected <null>, got <test>");
  }
}

/// shouldNotBeNull - should succeed when object is not null
unittest
{
  string value = "test";
  value.shouldNotBeNull();
}

/// shouldNotBeNull - should fail when object is null
unittest
{
  string value = null;
  
  try
  {
    value.shouldNotBeNull();
    assert(false);
  }
  catch(UnitTestException e)
  { 
    assert(e.msg == "Expected not <null>, got <null>");
  }
}

/// shouldEqual - should succeed when objects is equal
unittest
{
  "test".shouldEqual("test");
}

/// shouldEqual - should when when objects is not equal
unittest
{
  try
  {
    "test".shouldEqual("some");
    assert(false);
  }
  catch(UnitTestException e)
  {
    assert(e.msg == "Expected <some>, got <test>");
  }
}

/// shouldNotEqual - should succeed when objects is not equal
unittest
{
  "test".shouldNotEqual("some");
}

/// shouldNotEqual - should fail when objects is equal
unittest
{
  try
  {
    "test".shouldNotEqual("test");
    assert(false);
  }
  catch(UnitTestException e)
  {
    assert(e.msg == "Expected not <test>, got <test>");
  }
}

/// shouldBeTrue - should succeed when objects is true
unittest
{
  true.shouldBeTrue();
}

/// shouldBeTrue - should fail when objects is not true
unittest
{
  try
  {
    false.shouldBeTrue();
    assert(false);
  }
  catch(UnitTestException e)
  {
    assert(e.msg == "Expected <true>, got <false>");
  }
}

/// shouldBeFalse - should succeed when objects is false
unittest
{
  false.shouldBeFalse();
}

/// shouldBeFalse - should fail when objects is not false
unittest
{
  try
  {
    true.shouldBeFalse();
    assert(false);
  }
  catch(UnitTestException e)
  {
    assert(e.msg == "Expected <false>, got <true>");
  }
}

/// shouldThrow - should succeed when exception is thrown
unittest
{
  void testThrow()
  {
    throw new Exception("SHOT!");
    assert(false);
  }

  testThrow().shouldThrow!Exception();
}

/// shouldThrow - should fail when an exception is not thrown 
unittest
{
  void testThrow(){}
  Throwable exception = null;

  try
  {
    testThrow.shouldThrow!UnitTestException();
  }
  catch(UnitTestException e)
  {
    exception = e;
  }

  assert(exception !is null);
  assert(exception.msg == "Expression did not throw");

  void testThrow2()
  {
    throw new Exception("SHOT!");
    assert(false);
  }

  try
  {
    testThrow2().shouldThrow!UnitTestException();
    assert(false);
  }
  catch(UnitTestException e)
  {
    assert(e.msg == "Expected <UnitTestException>, but throw <object.Exception>");
  }
}

/// shouldBeInstanceOf - should success when object instance expect
unittest
{
  auto object = new TestDummy;
  auto mock = cast(DummyInterface) object;
  mock.shouldBeInstanceOf!TestDummy();
}

/// shouldBeInstanceOf - should fail when object not instance expect
unittest
{
  auto object = new TestDummy;

  try
  {
    object.shouldBeInstanceOf!Exception();
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<assertiontest.TestDummy> expected to be instance of <object.Exception>.");
  }
}

/// shouldBeInstanceOf - should fail when object not instance expect
unittest
{
  auto object = new TestDummy;

  try
  {
    object.shouldBeInstanceOf!Exception("test!");
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "test!");
  }
}

/// shouldBeGreater - should succeed when one is greater
unittest
{
  10.shouldBeGreater(5);
  10.shouldBeGreater(5.0);
}

/// shouldBeGreater - should fail when one is not greater
unittest
{
  try
  {
    5.shouldBeGreater(10);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<5> expected to be greater than <10>.");
  }
}

/// shouldBeGreaterOrEqual - should succeed when one is greater
unittest
{
  10.shouldBeGreaterOrEqual(5);
  10.shouldBeGreaterOrEqual(5.0);
}

/// shouldBeGreaterOrEqual - should succeed when one is equal
unittest
{
  10.shouldBeGreaterOrEqual(10);
}

/// shouldBeGreaterOrEqual - should fail when one is less
unittest
{
  try
  {
    5.shouldBeGreaterOrEqual(10);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<5> expected to be greater or equal to <10>.");
  }
}

/// shouldBeLess - should succeed when one is less
unittest
{
  5.shouldBeLess(10);
  5.shouldBeLess(10.0);
}

/// shouldBeLess - should fail when one is not greater
unittest
{
  try
  {
    10.shouldBeLess(5);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<10> expected to be less than <5>.");
  }
}

/// shouldBeLessOrEqual - should succeed when one is less
unittest
{
  5.shouldBeLessOrEqual(10);
  5.shouldBeLessOrEqual(10.0);
}

/// shouldBeLessOrEqual - should succeed when one is equal
unittest
{
  10.shouldBeLessOrEqual(10);
}

/// shouldBeLessOrEqual - should fail when one is greater
unittest
{
  try
  {
    10.shouldBeLessOrEqual(5);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<10> expected to be less or equal to <5>.");
  }
}

/// shouldBeBetween - should success when between two values
unittest
{
  5.shouldBeBetween(4, 8);
  5.shouldBeBetween(4.0, 8);
}

/// shouldBeBetween - should fail when not between two values
unittest
{
  try
  {
    5.shouldBeBetween(20, 30);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<5> expected to be between <20> and <30>.");
  }
}

/// shouldBeBetweenOrEqual - should success when between two values
unittest
{
  5.shouldBeBetweenOrEqual(4, 8);
}

/// shouldBeBetweenOrEqual - should success when equal two values
unittest
{
  4.shouldBeBetweenOrEqual(4, 8);
  8.shouldBeBetweenOrEqual(4, 8);
}

/// shouldBeBetweenOrEqual - should fail when not between two values
unittest
{
  try
  {
    5.shouldBeBetweenOrEqual(20, 30);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<5> expected to be between or equal <20> and <30>.");
  }
}

/// shouldBeIn - should succeed when the string is in the array
unittest
{
  "abc".shouldBeIn(["abc", "xyz"]);
}

/// shouldBeIn - should fail when the string is NOT in the array
unittest
{
  try
  {
    "test".shouldBeIn(["abc", "xyz"]);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<test> is not in <[abc, xyz]>.");
  }
}

/// shouldBeContain - should succeed when the array is contain value
unittest
{
  ["1", "2"].shouldBeContain("2");
}

/// shouldBeContain - should fail when the array is not contain value
unittest
{
  try
  {
    ["1", "2"].shouldBeContain("3");
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<[1, 2]> is not contain <3>.");
  }
}