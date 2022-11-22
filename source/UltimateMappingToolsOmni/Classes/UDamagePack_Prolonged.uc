//-----------------------------------------------------------------------------
// Prolonged UDamagePack
//
// Lasts 45 seconds instead of just 30 and uses another shader for better
// distinguishing. Additionally it's directly placeable in a map, though a
// PickupBase is recommended to be used.
//-----------------------------------------------------------------------------
class UDamagePack_Prolonged extends UDamagePack
    placeable;


#exec OBJ LOAD FILE=UltimateMappingTools_Tex.utx

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.Udamage');
    L.AddPrecacheMaterial(FinalBlend'UltimateMappingTools_Tex.Pickups.UDamage45_FB');
}

auto state Pickup
{
    event Touch( Actor Other )
    {
        local Pawn P;

        if ( ValidTouch(Other) )
        {
            P = Pawn(Other);
            P.EnableUDamage(45);
            AnnouncePickup(P);
            SetRespawn();
        }
    }
}

defaultproperties
{
     Skins(0)=FinalBlend'UltimateMappingTools_Tex.Pickups.UDamage45_FB'
}
