namespace IronPipeline.Sim.Hex;

/// <summary>
/// Axial hex coordinate (q, r) with the implicit cube coordinate s = -q - r.
/// Orientation-agnostic: pointy-top vs flat-top is a presentation concern and is
/// decided in the Godot layer. See https://www.redblobgames.com/grids/hexagons/.
/// </summary>
public readonly record struct HexCoord(int Q, int R)
{
    public static readonly HexCoord Origin = new(0, 0);

    /// <summary>The six neighbor directions in a fixed, deterministic order.</summary>
    public static readonly HexCoord[] Directions =
    [
        new(1, 0),
        new(1, -1),
        new(0, -1),
        new(-1, 0),
        new(-1, 1),
        new(0, 1),
    ];

    public int S => -Q - R;

    public static HexCoord operator +(HexCoord a, HexCoord b) => new(a.Q + b.Q, a.R + b.R);

    public static HexCoord operator -(HexCoord a, HexCoord b) => new(a.Q - b.Q, a.R - b.R);

    public static HexCoord Add(HexCoord a, HexCoord b) => a + b;

    public static HexCoord Subtract(HexCoord a, HexCoord b) => a - b;

    public HexCoord Neighbor(int direction) => this + Directions[((direction % 6) + 6) % 6];

    public IEnumerable<HexCoord> Neighbors()
    {
        foreach (HexCoord d in Directions)
        {
            yield return this + d;
        }
    }

    public int Length() => (Math.Abs(Q) + Math.Abs(R) + Math.Abs(S)) / 2;

    public int DistanceTo(HexCoord other) => (this - other).Length();

    /// <summary>All hexes at exactly <paramref name="radius"/> steps, in deterministic order.</summary>
    public IEnumerable<HexCoord> Ring(int radius)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(radius);
        if (radius == 0)
        {
            yield return this;
            yield break;
        }

        HexCoord hex = this + new HexCoord(Directions[4].Q * radius, Directions[4].R * radius);
        for (int side = 0; side < 6; side++)
        {
            for (int step = 0; step < radius; step++)
            {
                yield return hex;
                hex = hex.Neighbor(side);
            }
        }
    }

    /// <summary>
    /// Hexes on the straight line from this hex to <paramref name="target"/>, inclusive.
    /// Integer-only: ties are broken toward +Q/+R consistently so results are deterministic.
    /// </summary>
    public IEnumerable<HexCoord> LineTo(HexCoord target)
    {
        int n = DistanceTo(target);
        if (n == 0)
        {
            yield return this;
            yield break;
        }

        for (int i = 0; i <= n; i++)
        {
            // Lerp in cube space using integer arithmetic scaled by n, then round.
            long q = (long)Q * (n - i) + (long)target.Q * i;
            long r = (long)R * (n - i) + (long)target.R * i;
            long s = (long)S * (n - i) + (long)target.S * i;
            yield return RoundCube(q, r, s, n);
        }
    }

    private static HexCoord RoundCube(long qN, long rN, long sN, int n)
    {
        // Round each scaled coordinate to nearest, with a tiny consistent bias to break ties.
        long bias = 1; // nudge in +q, +r direction; s absorbs the correction below
        long rq = DivRound(qN * 1000 + bias, n * 1000);
        long rr = DivRound(rN * 1000 + bias, n * 1000);
        long rs = DivRound(sN * 1000 - 2 * bias, n * 1000);

        long dq = Math.Abs(rq * n * 1000 - (qN * 1000 + bias));
        long dr = Math.Abs(rr * n * 1000 - (rN * 1000 + bias));
        long ds = Math.Abs(rs * n * 1000 - (sN * 1000 - 2 * bias));

        if (dq > dr && dq > ds)
        {
            rq = -rr - rs;
        }
        else if (dr > ds)
        {
            rr = -rq - rs;
        }

        return new HexCoord((int)rq, (int)rr);
    }

    private static long DivRound(long a, long b)
    {
        // Round half away from zero, integer-only.
        long sign = (a < 0) == (b < 0) ? 1 : -1;
        long absA = Math.Abs(a);
        long absB = Math.Abs(b);
        return sign * ((2 * absA + absB) / (2 * absB));
    }

    public override string ToString() => $"({Q},{R})";
}
