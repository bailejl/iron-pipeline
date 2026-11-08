using FsCheck.Xunit;
using IronPipeline.Sim.Hex;
using IronPipeline.Sim.Map;
using IronPipeline.Sim.Tests.Fixtures;

namespace IronPipeline.Sim.Tests.Map;

/// <summary>Invariants from the trailing comment of features/0002-map-and-terrain.feature.</summary>
public class MapAndTerrainPropertyTests
{
    private static readonly IReadOnlyList<TerrainType> Types = TestContent.LoadTerrain();

    private static HexMap MapOf(int w, int h) =>
        HexMap.Filled(1 + (Math.Abs(w % 64)), 1 + (Math.Abs(h % 64)), Types, Types[0]);

    [Property]
    public bool InBoundsHexCountEqualsWidthTimesHeight(int w, int h)
    {
        HexMap map = MapOf(w, h);
        int count = 0;
        for (int r = -1; r <= map.Height; r++)
        {
            for (int q = -map.Height - 1; q <= map.Width + 1; q++)
            {
                if (map.InBounds(new HexCoord(q, r)))
                {
                    count++;
                }
            }
        }

        return count == map.Width * map.Height;
    }

    [Property]
    public bool IndicesAreRowMajorUniqueAndCoverEveryCell(int w, int h)
    {
        HexMap map = MapOf(w, h);
        List<int> indices = [];
        for (int row = 0; row < map.Height; row++)
        {
            for (int column = 0; column < map.Width; column++)
            {
                int index = map.IndexOf(HexMap.HexAt(column, row));
                if (index != (row * map.Width) + column)
                {
                    return false;
                }

                indices.Add(index);
            }
        }

        return indices.Order().SequenceEqual(Enumerable.Range(0, map.CellCount));
    }

    [Property]
    public bool InBoundsIffTerrainAtDoesNotThrow(int w, int h, int q, int r)
    {
        HexMap map = MapOf(w, h);
        HexCoord hex = new(q % 100, r % 100);
        bool threw = false;
        try
        {
            _ = map.TerrainAt(hex);
        }
        catch (ArgumentOutOfRangeException)
        {
            threw = true;
        }

        return map.InBounds(hex) == !threw;
    }

    [Property]
    public bool HexToIndexToHexRoundTripsForEveryCell(int w, int h)
    {
        HexMap map = MapOf(w, h);
        for (int index = 0; index < map.CellCount; index++)
        {
            HexCoord hex = HexMap.HexAt(index % map.Width, index / map.Width);
            if (map.IndexOf(hex) != index)
            {
                return false;
            }
        }

        return true;
    }

    [Property]
    public bool TerrainAtIsDeterministic(int w, int h, int column, int row)
    {
        HexMap map = MapOf(w, h);
        HexCoord hex = HexMap.HexAt(Math.Abs(column % map.Width), Math.Abs(row % map.Height));
        return ReferenceEquals(map.TerrainAt(hex), map.TerrainAt(hex));
    }
}
