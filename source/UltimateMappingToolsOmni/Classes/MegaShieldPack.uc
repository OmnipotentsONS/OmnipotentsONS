//-----------------------------------------------------------------------------
// MegaShieldPack
//
// Provides the player with 150 armor points instead of just 100.
// Additionally it's directly placeable in a map, though a
// PickupBase is recommended to be used.
//-----------------------------------------------------------------------------
class MegaShieldPack extends SuperShieldPack;


#exec OBJ LOAD FILE=UltimateMappingTools_Tex.utx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.Udamage');
	L.AddPrecacheMaterial(FinalBlend'UltimateMappingTools_Tex.Pickups.MegaShield_FB');
}

defaultproperties
{
     ShieldAmount=150
     Skins(0)=FinalBlend'UltimateMappingTools_Tex.Pickups.MegaShield_FB'
}
