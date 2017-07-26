/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.mock;

import core.exception;
import std.string;

class Mock(T)
{
  public:
    this()
    {
      _implementation = new MockAbstract;
    }

    MockAbstract _implementation;

  private:
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

mixin template MockCommon()
{
  public:
    void expectCalled(string functionName, string message = null, string file = __FILE__, size_t line = __LINE__, V...)(auto ref V values)
    {
      expectCalled!(functionName, 1, message, file, line)(values);
    }

    void expectNotCalled(string functionName, string message = null, string file = __FILE__, size_t line = __LINE__, V...)(auto ref V values)
    {
      expectCalled!(functionName, 0, message, file, line)(values);
    }

    void expectCalled(string functionName, ulong count, string message = null, string file = __FILE__, size_t line = __LINE__, V...)(auto ref V values)
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
		        throw new AssertError("<%s> expected call with <%s> <%d> count but called <%d> counts.".format(functionName, arguments.join(","), count, callCount), file, line);
          }
          else
          {
		        throw new AssertError("<%s> expected call with <%s> but called with <%s>.".format(functionName, arguments.join(","), callVariants.join(",")), file, line);
          }
		    }
        else
        {
		      throw new AssertError(message, file, line);
        }
      }
    }

  private:
    string[] _calledFuncs;
    string[] _calledValues;
}

alias Identity(alias T) = T;
private enum isPrivate(T, string member) = !__traits(compiles, __traits(getMember, T, member));

string generateDefaultImplementationMixin(T)()
{
  import std.array: join;
  import std.format: format;
  import std.stdio;
  import std.conv: text;
  import std.range: iota;
  import std.traits: functionAttributes, FunctionAttribute, Parameters, arity;
  import std.range;
  import std.algorithm;
  import std.conv;

  string[] code;

  // if(!__ctfe) return null;

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
          static if(!(functionAttributes!member & FunctionAttribute.const_) && !(functionAttributes!member & FunctionAttribute.const_))
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

            import std.string;
            if(typeof(overload).stringof.indexOf("void(") != 0)
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
  import std.traits: functionAttributes, FunctionAttribute;
  import std.array: join;

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
