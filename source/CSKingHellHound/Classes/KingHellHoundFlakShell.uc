class KingHellHoundflakshell extends FlakShell;

var	xemitter trail;
var vector initialDir;
var actor Glow;


simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;
    local rotator rot;
    local int i;
    local KingHellHoundFlakChunk NewChunk;

	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{
		HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);	
		for (i=0; i<6; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			NewChunk = Spawn( class 'KingHellHoundFlakChunk',, '', Start, rot);
		}
	}
    Destroy();
}

defaultproperties
{
     Speed=3700.000000
     TossZ=1.000000
     Damage=110.000000
     MyDamageType=Class'CSKingHellHound.KingHellHoundFlakBall'
     Physics=PHYS_Flying
     DrawScale=1.5
}
