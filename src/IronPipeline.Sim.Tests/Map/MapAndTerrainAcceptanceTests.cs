using IronPipeline.Sim.Map;
using IronPipeline.Sim.Tests.Fixtures;

namespace IronPipeline.Sim.Tests.Map;

/// <summary>
/// One test per scenario in features/0002-map-and-terrain.feature (spec: docs/specs/0002-map-and-terrain.md).
/// </summary>
public class MapAndTerrainAcceptanceTests
{
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
