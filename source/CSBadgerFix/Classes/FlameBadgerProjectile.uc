/**
Badgers_V2.FlameBadgerProjectile

Creation date: 2014-01-26 12:57
Last change: $Id$
Copyright (c) 2014, Wormbo
*/

class FlameBadgerProjectile extends BadgerProjectile;


var() class<Projectile> SubmunitionType;
var() int SubmunitionCount;


simulated function Explode(vector HitLocation, vector HitNormal)
{
	local int i;
	local Projectile P;
	
	PlaySound(sound'BExplosion3',, 5.5 * TransientSoundVolume);
    if (EffectIsRelevant(Location, false))
    {
    	Spawn(class'BadgerHitRockEffect',,, HitLocation + HitNormal * 16, rotator(HitNormal));
		if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)
			Spawn(ExplosionDecal, self,, Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	if (SubmunitionType != None && SubmunitionCount > 0 && Role == ROLE_Authority)
	{
		SetCollision(false, false, false);

		for (i = 0; i < SubmunitionCount; i++)
		{
			P = Spawn(SubmunitionType, Owner, '', HitLocation + 10 * HitNormal, rotator(VRand() + 0.75 * HitNormal));
			if (P != None)
			{
				P.InstigatorController = InstigatorController;
			}
		}
	}
	Destroy();
}



//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     SubmunitionType=Class'Badgers_V2beta3.FlameBadgerNapalmGlob'
     SubmunitionCount=15
     Damage=150.000000
     DamageRadius=400.000000
     MyDamageType=Class'Badgers_V2beta3.DamTypeFlameBadgerCannon'
}
