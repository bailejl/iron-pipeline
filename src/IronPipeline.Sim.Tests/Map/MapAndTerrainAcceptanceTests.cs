using IronPipeline.Sim.Hex;
using IronPipeline.Sim.Map;
using IronPipeline.Sim.Tests.Fixtures;

namespace IronPipeline.Sim.Tests.Map;

/// <summary>
/// One test per scenario in features/0002-map-and-terrain.feature (spec: docs/specs/0002-map-and-terrain.md).
/// </summary>
public class MapAndTerrainAcceptanceTests
{
    [Fact]
    public void S01_MapHasWidthTimesHeightCells()
    {
        IReadOnlyList<TerrainType> types = TestContent.LoadTerrain();

        HexMap map = HexMap.Filled(5, 3, types, types.Single(t => t.Id == "plains"));

        Assert.Equal(5, map.Width);
        Assert.Equal(3, map.Height);
        Assert.Equal(15, map.CellCount);
    }

    [Fact]
    public void S02_ZeroOrNegativeDimensionsAreRejected()
    {
        IReadOnlyList<TerrainType> types = TestContent.LoadTerrain();
        TerrainType plains = types.Single(t => t.Id == "plains");

        Assert.Throws<ArgumentOutOfRangeException>(() => HexMap.Filled(0, 3, types, plains));
        Assert.Throws<ArgumentOutOfRangeException>(() => HexMap.Filled(4, -1, types, plains));
    }

    [Fact]
    public void S03_EveryCellOfTheMapIsInBounds()
    {
        HexMap map = PlainsMap(5, 3);

        for (int row = 0; row < 3; row++)
        {
            for (int column = 0; column < 5; column++)
            {
                Assert.True(map.InBounds(HexMap.HexAt(column, row)), $"column {column}, row {row}");
            }
        }

        Assert.True(map.InBounds(new HexCoord(0, 0)));
        Assert.True(map.InBounds(new HexCoord(3, 2)));
    }

    [Fact]
    public void S04_HexesJustOutsideTheMapAreOutOfBounds()
    {
        HexMap map = PlainsMap(5, 3);

        Assert.False(map.InBounds(new HexCoord(-1, 0)));
        Assert.False(map.InBounds(new HexCoord(5, 0)));
        Assert.False(map.InBounds(new HexCoord(0, -1)));
        Assert.False(map.InBounds(new HexCoord(0, 3)));
        Assert.False(map.InBounds(new HexCoord(100, 100)));
    }

    [Fact]
    public void S05_TerrainQueryReturnsTheTerrainStoredAtAHex()
    {
        IReadOnlyList<TerrainType> types = TestContent.LoadTerrain();
        TerrainType plains = types.Single(t => t.Id == "plains");
        TerrainType forest = types.Single(t => t.Id == "forest");
        TerrainType hills = types.Single(t => t.Id == "hills");
        HexMap map = HexMap.Filled(5, 3, types, plains)
            .WithTerrain(new HexCoord(0, 0), forest)
            .WithTerrain(new HexCoord(3, 2), hills);

        TerrainType atFirst = map.TerrainAt(new HexCoord(0, 0));
        TerrainType atLast = map.TerrainAt(new HexCoord(3, 2));
        TerrainType atCenter = map.TerrainAt(new HexCoord(2, 1));

        Assert.Equal(("forest", 2, 25), (atFirst.Id, atFirst.MovementCost, atFirst.DefenseModifierPct));
        Assert.Equal(("hills", 3, 40), (atLast.Id, atLast.MovementCost, atLast.DefenseModifierPct));
        Assert.Equal(("plains", 1, 0), (atCenter.Id, atCenter.MovementCost, atCenter.DefenseModifierPct));
    }

    [Fact]
    public void S06_TerrainQueryOutsideTheMapIsAnError()
    {
        HexMap map = PlainsMap(5, 3);

        Assert.Throws<ArgumentOutOfRangeException>(() => map.TerrainAt(new HexCoord(100, 100)));
    }

    private static HexMap PlainsMap(int width, int height)
    {
        IReadOnlyList<TerrainType> types = TestContent.LoadTerrain();
        return HexMap.Filled(width, height, types, types.Single(t => t.Id == "plains"));
    }

    [Fact]
    public void S07_TerrainTypesLoadFromContentWithCostAndDefense()
    {
        using TempDir dir = new();
        foreach (string name in new[] { "plains", "forest", "hills" })
        {
            File.Copy(Path.Combine(TestContent.TerrainDirectory, name + ".yaml"), Path.Combine(dir.Path, name + ".yaml"));
        }

        IReadOnlyList<TerrainType> types = TerrainLoader.LoadDirectory(dir.Path);

        Assert.Equal(3, types.Count);
        TerrainType forest = types.Single(t => t.Id == "forest");
        TerrainType hills = types.Single(t => t.Id == "hills");
        Assert.Equal(2, forest.MovementCost);
        Assert.Equal(25, forest.DefenseModifierPct);
        Assert.Equal(3, hills.MovementCost);
        Assert.Equal(40, hills.DefenseModifierPct);
    }

    [Fact]
    public void S08_ATerrainFileMissingARequiredFieldIsRejected()
    {
        using TempDir dir = new();
        string file = Path.Combine(dir.Path, "marsh.yaml");
        File.WriteAllText(file, "id: marsh\ndefense_modifier: 10\n");

        InvalidDataException error = Assert.Throws<InvalidDataException>(() => TerrainLoader.LoadDirectory(dir.Path));

        Assert.Contains(file, error.Message, StringComparison.Ordinal);
        Assert.Contains("movement_cost", error.Message, StringComparison.Ordinal);
    }

    [Fact]
    public void S09_ADuplicateTerrainIdAcrossFilesIsRejected()
    {
        using TempDir dir = new();
        string first = Path.Combine(dir.Path, "a.yaml");
        string second = Path.Combine(dir.Path, "b.yaml");
        File.WriteAllText(first, "id: forest\nmovement_cost: 2\ndefense_modifier: 25\n");
        File.WriteAllText(second, "id: forest\nmovement_cost: 3\ndefense_modifier: 30\n");

        InvalidDataException error = Assert.Throws<InvalidDataException>(() => TerrainLoader.LoadDirectory(dir.Path));

        Assert.Contains("'forest'", error.Message, StringComparison.Ordinal);
        Assert.Contains(first, error.Message, StringComparison.Ordinal);
        Assert.Contains(second, error.Message, StringComparison.Ordinal);
    }
}
