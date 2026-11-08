using IronPipeline.Sim.Map;

namespace IronPipeline.Sim.Tests.Map;

/// <summary>Schema rules from content/schemas/terrain.schema.json that the loader must enforce (spec 0002 decision 12).</summary>
public class TerrainLoaderValidationTests
{
    [Theory]
    [InlineData("id: Forest\nmovement_cost: 2\ndefense_modifier: 25\n", "'id'")]
    [InlineData("id: \"forest\"\nmovement_cost: 2\ndefense_modifier: 25\n", "'id'")]
    [InlineData("id: water\npassable: false\nmovement_cost: 0\ndefense_modifier: 0\n", "'movement_cost'")]
    public void InvalidFieldIsRejectedNamingFileAndField(string yaml, string field)
    {
        InvalidDataException error = Assert.Throws<InvalidDataException>(() => TerrainLoader.Parse(yaml, "bad.yaml"));

        Assert.Contains("bad.yaml", error.Message, StringComparison.Ordinal);
        Assert.Contains(field, error.Message, StringComparison.Ordinal);
    }
}
