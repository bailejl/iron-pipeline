using IronPipeline.Sim.Hex;
using IronPipeline.Sim.Map;
using IronPipeline.Sim.Tests.Fixtures;

namespace IronPipeline.Sim.Tests.Map;

/// <summary>Independent literals for the odd-r layout (spec 0002 decision 7); axial q = col - (row - (row &amp; 1)) / 2.</summary>
public class MapLayoutTests
{
    [Fact]
    public void OddRowsShearHalfAHexPerRow()
    {
        IReadOnlyList<TerrainType> types = TestContent.LoadTerrain();
        HexMap map = HexMap.Filled(5, 3, types, types[0]);

        Assert.Equal(new HexCoord(3, 2), HexMap.HexAt(4, 2));
        Assert.Equal(new HexCoord(0, 1), HexMap.HexAt(0, 1));
        Assert.Equal(new HexCoord(-1, 2), HexMap.HexAt(0, 2));
        Assert.True(map.InBounds(new HexCoord(-1, 2)));
        Assert.False(map.InBounds(new HexCoord(4, 2)));
        Assert.Equal(10, map.IndexOf(new HexCoord(-1, 2)));
    }

    [Fact]
    public void MapIsNotAffectedByLaterChangesToTheCallersTerrainList()
    {
        List<TerrainType> types = [.. TestContent.LoadTerrain()];
        HexMap map = HexMap.Filled(2, 2, types, types[0]);
        string before = map.TerrainAt(new HexCoord(0, 0)).Id;

        types.Reverse();

        Assert.Equal(before, map.TerrainAt(new HexCoord(0, 0)).Id);
    }
}
