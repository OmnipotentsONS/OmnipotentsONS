class FlakRatOmnishell extends flakshell;

var int NumChunks;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;
    local rotator rot;
    local int i;
    local FlakRatOmniChunk NewChunk;
            // FlakRatChunk
            // FlakRatMortarBomblet

	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{

		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
		for (i=0; i<NumChunks; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			NewChunk = Spawn( class'FlakRatOmniChunk',,'', Start, rot);
      if (NewChunk != None) NewChunk.InstigatorController = InstigatorController;
		}
	}
    Destroy();
}

defaultproperties
{
	   Damage=100
	   DamageRadius=220
	   NumChunks=6
     Speed=4000.000000
     TossZ=0.000000
     MyDamageType=Class'FlakRatOmni.DamTypeFlakRatOmniShell'
     Physics=PHYS_Flying
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=5.000000
     DrawScale=10.000000
}
