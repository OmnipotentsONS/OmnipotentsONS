//=============================================================================
// NapalmBadgerFire.
//=============================================================================
class NapalmBadgerFire extends NapalmTankFire;

state OnGround
{
    simulated function BeginState()
    {
    local vector start;
    local rotator rot;
    local int i;
    local NapalmTankSmallBlob NTF;

    PlaySound (Sound'WeaponSounds.BExplosion1',,3*TransientSoundVolume);
	start = Location;

    if ( Role == ROLE_Authority )
	{
		for (i=0; i<3; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			NTF = Spawn( class 'NapalmBadgerSmallBlob',, '', Start, rot);
		}
	}
}
}

defaultproperties
{
     MyDamageType=Class'CSBadgerFix.FlameBadgerKill'
     bSelected=True
}
