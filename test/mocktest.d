import checkit.mock;

import core.exception;
import std.stdio;

/// Mock.expectCalled - should make stubs for methods
unittest
{
  interface Dummy
  {
    void test();
    void test1(int a);
    void test2(int a, int b);
    int test3();
  }

  auto mock = new Mock!Dummy;
  mock.test();
  mock.test1(1);
  mock.test2(1, 2);
  mock.test3();
}

/// Mock.expectCalled - should success expectCalled
unittest
{
  interface Dummy
  {
    void test();
    void test(int a);
  }

  auto mock = new Mock!Dummy;
  mock.test();
  mock.test(12);
  mock.expectCalled!"test"();
  mock.expectCalled!"test"(12);
}

/// Mock.expectCalled - should fail when function not called
unittest
{
  interface Dummy
  {
    void test(int a);
  }

  auto mock = new Mock!Dummy;
  mock.test(10);
  mock.test(20);
  mock.test(30);
  try
  {
    mock.expectCalled!"test"(50);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<test> expected call with <50> but called with <Tuple!int(10),Tuple!int(20),Tuple!int(30)>.");
  }
}

/// Mock.expectCalled - should success expectCalled count
unittest
{
  interface Dummy
  {
    void test(int a);
    void test();
  }

  auto mock = new Mock!Dummy;
  mock.test(10);
  mock.test(10);
  mock.test(10);
  mock.test();
  mock.test();
  mock.expectCalled!("test", 3)(10);
  mock.expectCalled!("test", 2)();
}

/// Mock.expectCalled - should fail when function called not equal count
unittest
{
  interface Dummy
  {
    void test(int a);
  }

  auto mock = new Mock!Dummy;
  mock.test(10);
  try
  {
    mock.expectCalled!("test", 10)(10);
    assert(false);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<test> expected call with <10> <10> count but called <1> counts.");
  }
}

/// Mock.expectNotCalled - should success when function not called
unittest
{
  interface Dummy
  {
    void test(int a);
  }

  auto mock = new Mock!Dummy;
  mock.test(1);
  mock.expectNotCalled!"test"(10);
}

/// Mock.expectNotCalled - should fail when function called
unittest
{
  interface Dummy
  {
    void test(int a);
  }

  auto mock = new Mock!Dummy;
  mock.test(10);

  try
  {
    mock.expectNotCalled!"test"(10);
  }
  catch(AssertError e)
  {
    assert(e.msg == "<test> expected call with <10> <0> count but called <1> counts.");
  }
}
