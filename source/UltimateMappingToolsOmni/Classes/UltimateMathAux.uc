//=============================================================================
// UltimateMathAux
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 16.08.2011 19:17:04 in Package: UltimateMappingTools$
//
// A very basic class that holds some static auxiliary math functions.
//=============================================================================
class UltimateMathAux extends Object;

// Modulo for integers. Courtesy of a Worm.
static final operator(18) int % (int A, int B)
{
  return A - (A / B) * B;
}

// The one-parameter version. Another Worm.
static final function float ArcTan(float A)
{
  return ATan(1, A);
}

// Returns the squared length of a vector. Cheaper than VSize().
static final function float  VSizeSq  ( vector A )
{
    return A dot A;
}

defaultproperties
{
}
