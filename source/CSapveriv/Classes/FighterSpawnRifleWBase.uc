//=============================================================================
// FighterSpawnRifleWeaponBase
//=============================================================================
class FighterSpawnRifleWBase extends xWeaponBase config(CSAPVerIV)
    placeable;


function SpawnPickup()
{
    if( PowerUp == None )
        return;

    myPickUp = Spawn(PowerUp,,,Location + SpawnHeight * vect(0,0,1));

    if (myPickUp != None)
    {
        myPickUp.PickUpBase = self;
        myPickup.Event = event;
    }
}

defaultproperties
{
     WeaponType=Class'CSAPVerIV.FighterSpawnRifle'
     StaticMesh=None
     bStatic=False
     bHidden=True
}
