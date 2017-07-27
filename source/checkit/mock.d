/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.mock;

import checkit.exception;
import core.exception;
import std.string;

/// Class for create Mock object
class Mock(T)
{
  public:
    /// Default constructor
    this()
    {
      _implementation = new MockAbstract;
    }

    /** Add a value to be returned by the mock.

      Params:
        functionName = The name of function mock.
        i = The count of realization for override function.
        values = Are return values.

      Throws:
        If function not virtual, will throw an AssertError.

      Examples:
        ---
        interface Dummy
        {
          int test();
        }
        auto mock = new Mock!Dummy;
        mock.returnValue!"test"(1,2);
        assert(mock.test() == 1);
        assert(mock.test() == 2);
        ---
    */
    void returnValue(string functionName, ubyte i = 0, V...)(V values)
    {
      import std.conv: text;

      alias member = Identity!(__traits(getMember, T, functionName));
      static assert(__traits(isVirtualMethod, member), "Can't use return value for <" ~ functionName ~ ">");

      enum varName = functionName ~ text(`_`, i, `_returnValues`);
      foreach(v; values)
      {
        mixin(varName ~ ` ~=  v;`);
      }
    }

    /// Mock implementation
    MockAbstract _implementation;

  private:
    /// Abstract Mock template
    class MockAbstract: T
    {
      import std.conv: to;
      import std.traits: Parameters, ReturnType;
      import std.typecons: tuple;
      mixin(generateDefaultImplementationMixin!T);
      mixin MockCommon;
    }

    alias _implementation this;
}

/// Mixin for test behavior
mixin template MockCommon()
{
  public:
    /** Used to assert function call once

      Params:
        functionName = The name of expected function.
        message = Exception message.
        file = The file name that the assert failed in. Should be left as default.
        line = The file line that the assert failed in. Should be left as default.
        values = Are expected parameter values.

      Throws:
        If function is not call with parameters, will throw an UnitTestException.

      Examples:
        ---
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

        // Will throw an exception like "UnitTestException@example.d(6): <test> expected call with <50> but called with <Tuple!int(12)>
        mock.exceptCalled!"test"(50);
        ---
    */
    void expectCalled(string functionName, 
                      string message = null, 
                      string file = __FILE__, 
                      size_t line = __LINE__, 
                      V...)(auto ref V values)
    {
      expectCalled!(functionName, 1, message, file, line)(values);
    }

    /** Used to assert function not call

      Params:
        functionName = The name of expected function.
        message = Exception message.
        file = The file name that the assert failed in. Should be left as default.
        line = The file line that the assert failed in. Should be left as default.
        values = Are expected parameter values.

      Throws:
        If function is call with parameters, will throw an UnitTestException.

      Examples:
        ---
        interface Dummy
        {
          void test();
          void test(int a);
        }

        auto mock = new Mock!Dummy;
        mock.test(12);
        mock.expectNotCalled!"test"();
        mock.expectNotCalled!"test"(24);

        // Will throw an exception like "UnitTestException@example.d(6): <test> expected call with <12> <0> count but called <1> counts        
        mock.exceptNotCalled!"test"(12);
        ---
    */
    void expectNotCalled( string functionName, 
                          string message = null, 
                          string file = __FILE__, 
                          size_t line = __LINE__, 
                          V...)(auto ref V values)
    {
      expectCalled!(functionName, 0, message, file, line)(values);
    }

    /** Used to assert function call many counts

      Params:
        functionName = The name of expected function.
        count = Count of calls.
        message = Exception message.
        file = The file name that the assert failed in. Should be left as default.
        line = The file line that the assert failed in. Should be left as default.
        values = Are expected parameter values.

      Throws:
        If function is not call many count with parameters, will throw an UnitTestException.

      Examples:
        ---
        interface Dummy
        {
          void test();
          void test(int a);
        }

        auto mock = new Mock!Dummy;
        mock.test();
        mock.test(12);
        mock.expectCalled!("test", 1)();
        mock.expectCalled!("test", 1)(12);

        // Will throw an exception like "UnitTestException@example.d(6): <test> expected call with <12> <2> count but called <1> counts
        mock.exceptCalled!("test", 2)(12);
        ---
    */
    void expectCalled(string functionName, 
                      ulong count, 
                      string message = null, 
                      string file = __FILE__, 
                      size_t line = __LINE__, 
                      V...)(auto ref V values)
    {
      string[] callVariants;
      ulong callCount;

      foreach(i, calledFunctionName; _calledFuncs)
      {
        if(calledFunctionName == functionName)
        {
          if(tuple(values).to!string() == _calledValues[i])
          {
            callCount++;
          }
          else
          {
            callVariants ~= _calledValues[i];
          }
        }
      }

      if(callCount != count)
      {
        if(!message)
        {
          string[] arguments;
          foreach(value; values)
          {
            arguments ~= to!string(value);
          }

          if(callCount > 0)
          {
		        throw new UnitTestException(
                "<%s> expected call with <%s> <%d> count but called <%d> counts".format(functionName, 
                                                                                        arguments.join(","), 
                                                                                        count, 
                                                                                        callCount), 
                file, 
                line);
          }
          else
          {
		        throw new UnitTestException(
                "<%s> expected call with <%s> but called with <%s>".format( functionName, 
                                                                            arguments.join(","), 
                                                                            callVariants.join(",")), 
                file, 
                line);
          }
		    }
        else
        {
		      throw new UnitTestException(message, file, line);
        }
      }
    }

  private:
    string[] _calledFuncs;
    string[] _calledValues;
}

alias Identity(alias T) = T;
private enum isPrivate(T, string member) = !__traits(compiles, __traits(getMember, T, member));

private string generateDefaultImplementationMixin(T)()
{
  import std.array: join;
  import std.conv: text;
  import std.format: format;
  import std.traits: arity, FunctionAttribute, functionAttributes, Parameters;

  string[] code;

  if(!__ctfe) return null;

  // foreach all member in the class
  foreach(memberName; __traits(allMembers, T))
  {
    // If not private member
    static if(!isPrivate!(T, memberName))
    {
      alias member = Identity!(__traits(getMember, T, memberName));
      // If it is virtual method
      static if(__traits(isVirtualMethod, member))
      {
        foreach(i, overload; __traits(getOverloads, T, memberName))
        {
          static if(!(functionAttributes!member & FunctionAttribute.const_))
          {
            enum overloadName = text(memberName, "_", i);
            enum overloadString = `Identity!(__traits(getOverloads, T, "%s")[%s])`.format(memberName, i);
            code ~= "private alias %s_parameters = Parameters!(%s);".format(overloadName, overloadString);
            code ~= "private alias %s_returnType = ReturnType!(%s);".format(overloadName, overloadString);

            static if(functionAttributes!member & FunctionAttribute.nothrow_)
            {
              enum tryIndent = "  ";
            }
            else
            {
              enum tryIndent = "";
            }

            string[] returnDefault;

            static if(typeof(overload).stringof.indexOf("void(") != 0)
            {
              enum varName = overloadName ~ `_returnValues`;
              code ~= `private %s_returnType[] %s;`.format(overloadName, varName);
              code ~= "";
              returnDefault = [
                ` if(` ~ varName ~ `.length > 0)`,
                ` {`,
                `   auto ret = ` ~ varName ~ `[0];`,
                `   ` ~ varName ~ ` = ` ~ varName ~ `[1..$];`,
                `   return ret;`,
                ` }`,
                ` else`,
                ` {`,
                `   return %s_returnType.init;`.format(overloadName),
                ` }`];
            }

            string[] parts;
            string[] tupleParts;
            foreach(j, t; Parameters!overload)
            {
              parts ~= "%s_parameters[%s] arg%s".format(overloadName, j, j);
              tupleParts ~= "arg%s".format(j);
            }

            code ~= `override ` ~ overloadName ~ "_returnType " ~ memberName ~ "(" ~ parts.join(", ") ~ 
              ")" ~ " " ~ functionAttributesString!member;
            code ~= "{";

            static if(functionAttributes!member & FunctionAttribute.nothrow_)
            {
              code ~= "try";
              code ~= "{";
            }

            code ~= tryIndent ~ ` _calledFuncs ~= "` ~ memberName ~ `";`;
            code ~= tryIndent ~ ` _calledValues ~= tuple` ~ "(" ~ tupleParts.join(", ")  ~ ")" ~ `.to!string;`;

            static if(functionAttributes!member & FunctionAttribute.nothrow_)
            {
              code ~= "}";
              code ~= "catch(Exception) {}";
            }

            code ~= returnDefault.join("\n");
            code ~= `}`;
            code ~= "";
          }
        }
      }
    }
  }
  
  return code.join("\n");
}

private string functionAttributesString(alias F)()
{
  import std.array: join;
  import std.traits: FunctionAttribute, functionAttributes;

  string[] parts;
  const attrs = functionAttributes!F;

  if(attrs & FunctionAttribute.pure_) parts ~= "pure";
  if(attrs & FunctionAttribute.nothrow_) parts ~= "nothrow";
  if(attrs & FunctionAttribute.trusted) parts ~= "@trusted";
  if(attrs & FunctionAttribute.safe) parts ~= "@safe";
  if(attrs & FunctionAttribute.nogc) parts ~= "@nogc";
  if(attrs & FunctionAttribute.system) parts ~= "@system";
  if(attrs & FunctionAttribute.shared_) parts ~= "shared";

  return parts.join(" ");
}
