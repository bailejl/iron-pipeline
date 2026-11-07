using FsCheck;
using FsCheck.Xunit;
using IronPipeline.Sim.Hex;

namespace IronPipeline.Sim.Tests.Hex;

/// <summary>
/// Invariants that must hold for all coordinates. These are implementation-level
/// checks written by the coding agent; they are not scenarios from the spec.
/// </summary>
public class HexCoordPropertyTests
{
    private static HexCoord Hex(int q, int r) => new(q % 1000, r % 1000);

    [Property]
    public bool CubeCoordinatesSumToZero(int q, int r)
    {
        HexCoord h = Hex(q, r);
        return h.Q + h.R + h.S == 0;
    }

    [Property]
    public bool DistanceIsSymmetric(int q1, int r1, int q2, int r2)
        => Hex(q1, r1).DistanceTo(Hex(q2, r2)) == Hex(q2, r2).DistanceTo(Hex(q1, r1));

    [Property]
    public bool DistanceToSelfIsZero(int q, int r) => Hex(q, r).DistanceTo(Hex(q, r)) == 0;

    [Property]
    public bool DistanceSatisfiesTriangleInequality(int q1, int r1, int q2, int r2, int q3, int r3)
    {
        HexCoord a = Hex(q1, r1);
        HexCoord b = Hex(q2, r2);
        HexCoord c = Hex(q3, r3);
        return a.DistanceTo(c) <= a.DistanceTo(b) + b.DistanceTo(c);
    }

    [Property]
    public Property RingHasSixTimesRadiusHexes(int q, int r, PositiveInt radius)
    {
        int rad = radius.Get % 20 + 1;
        HexCoord[] ring = Hex(q, r).Ring(rad).ToArray();
        return (ring.Length == 6 * rad && ring.Distinct().Count() == ring.Length)
            .Label($"radius {rad} produced {ring.Length} hexes");
    }

    [Property]
    public bool LineLengthEqualsDistancePlusOne(int q1, int r1, int q2, int r2)
    {
        HexCoord a = Hex(q1, r1);
        HexCoord b = Hex(q2, r2);
        return a.LineTo(b).Count() == a.DistanceTo(b) + 1;
    }

    [Property]
    public bool LineIsDeterministic(int q1, int r1, int q2, int r2)
    {
        HexCoord a = Hex(q1, r1);
        HexCoord b = Hex(q2, r2);
        return a.LineTo(b).SequenceEqual(a.LineTo(b));
    }
}
