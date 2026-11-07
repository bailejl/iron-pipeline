using IronPipeline.Sim.Hex;

namespace IronPipeline.Sim.Tests.Hex;

/// <summary>
/// One test per scenario in docs/specs/0001-hex-coordinates.feature.
/// Test names start with the scenario ID so the spec-compliance reviewer can map them.
/// </summary>
public class HexCoordAcceptanceTests
{
    [Fact]
    public void S01_OriginHasSixDistinctNeighborsAtDistanceOne()
    {
        HexCoord[] neighbors = HexCoord.Origin.Neighbors().ToArray();

        Assert.Equal(6, neighbors.Length);
        Assert.Equal(6, neighbors.Distinct().Count());
        Assert.All(neighbors, n => Assert.Equal(1, HexCoord.Origin.DistanceTo(n)));
    }

    [Fact]
    public void S02_DistanceBetweenKnownHexesMatchesCubeMetric()
    {
        Assert.Equal(0, new HexCoord(2, -1).DistanceTo(new HexCoord(2, -1)));
        Assert.Equal(3, HexCoord.Origin.DistanceTo(new HexCoord(3, 0)));
        Assert.Equal(3, HexCoord.Origin.DistanceTo(new HexCoord(0, 3)));
        Assert.Equal(3, HexCoord.Origin.DistanceTo(new HexCoord(3, -3)));
        Assert.Equal(4, HexCoord.Origin.DistanceTo(new HexCoord(2, 2)));
    }

    [Fact]
    public void S03_RingOfRadiusTwoHasTwelveHexesAllAtDistanceTwo()
    {
        HexCoord center = new(1, -2);
        HexCoord[] ring = center.Ring(2).ToArray();

        Assert.Equal(12, ring.Length);
        Assert.Equal(12, ring.Distinct().Count());
        Assert.All(ring, h => Assert.Equal(2, center.DistanceTo(h)));
    }

    [Fact]
    public void S04_RingOfRadiusZeroIsJustTheCenter()
    {
        HexCoord[] ring = new HexCoord(4, 4).Ring(0).ToArray();
        Assert.Single(ring);
        Assert.Equal(new HexCoord(4, 4), ring[0]);
    }

    [Fact]
    public void S05_LineFromAToBStartsAtAEndsAtBAndStepsByOne()
    {
        HexCoord a = new(0, 0);
        HexCoord b = new(3, -2);
        HexCoord[] line = a.LineTo(b).ToArray();

        Assert.Equal(a.DistanceTo(b) + 1, line.Length);
        Assert.Equal(a, line[0]);
        Assert.Equal(b, line[^1]);
        for (int i = 1; i < line.Length; i++)
        {
            Assert.Equal(1, line[i - 1].DistanceTo(line[i]));
        }
    }

    [Fact]
    public void S06_NeighborDirectionsWrapAround()
    {
        HexCoord h = new(5, -3);
        Assert.Equal(h.Neighbor(0), h.Neighbor(6));
        Assert.Equal(h.Neighbor(5), h.Neighbor(-1));
    }
}
