/**
  Copyright: 2017 © LLC CERERIS
  License: MIT
  Authors: LLC CERERIS
*/

module checkit.blockmanager;

import checkit.block;
import std.algorithm: canFind;
import std.string: format;
import std.uuid: UUID;
import std.variant;

/// Provide managing of blocks
interface BlockManagerInterface
{
  public:
    /// Add block
    static void addBlock(T)(T block);
    /// Remove block from storage by UUID
    static void removeBlockByUUID(UUID uuid);
    /// Get array of blocks by type from storage
    static TestBlock!T[] getByType(T, alias U)();
}

/// Default BlockManager for collection blocks
final class BlockManager: BlockManagerInterface
{
  public:
    /** Add block

      Params:
        block = Block that is added to the storage

      Examples:
        ---
        auto scenario = new ScenarioBlock({}, "test", []);
        BlockManager.addBlock(scenario);
        ---
    */
    static void addBlock(T)(T block)
    {
      _blocksMap[block.getUUID()] = block;
    }

    /** Remove block from storage by UUID

      Params:
        uuid = Unique block identifier

      Examples:
        ---
        auto scenario = new ScenarioBlock({}, "test", []);
        BlockManager.addBlock(scenario);
        BlockManager.removeBlockByUUID(scenario.getUUID());
        ---
    */
    static void removeBlockByUUID(UUID uuid)
    {
      _blocksMap.remove(uuid);
    }

    /** Get array of blocks by type from storage

      Params:
        T = Type of block.

      Examples:
        ---
        auto scenario = new ScenarioBlock({}, "test", []);
        BlockManager.addBlock(scenario);
        BlockManager.getByType!ScenarioBlock();
        ---
    */
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
