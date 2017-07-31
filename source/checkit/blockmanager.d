/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.blockmanager;

import checkit.block;
import std.uuid: UUID;
import std.variant;
import std.string;
import std.algorithm: canFind;

interface BlockManagerInterface
{
  public:
    static void addBlock(T)(T block);
    static void removeBlockByUUID(UUID uuid);
    static TestBlock!T[] getByType(T, alias U)();
}

final class BlockManager: BlockManagerInterface
{
  public:
    static void addBlock(T)(T block)
    {
      _blocksMap[block.getUUID()] = block;
    }

    static void removeBlockByUUID(UUID uuid)
    {
      _blocksMap.remove(uuid);
    }

    static T[] getByType(T)()
    {
      T[] blocks;

      foreach(block; _blocksMap)
      {
        if(auto temp = cast(T) block)
        {
          blocks ~= temp;
        }
      }

      return blocks;
    }

  private:
    static TestBlock[UUID] _blocksMap;
}
