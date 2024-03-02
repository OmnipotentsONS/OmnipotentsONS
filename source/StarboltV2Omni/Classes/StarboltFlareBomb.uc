class StarBoltFlareBomb extends ONSDecoy;
#exec audio import file=Sounds\FlareBombExplosion.wav
var Sound ExplosionSound;

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
	{
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

simulated function Landed( vector HitNormal )
{
	Super(Projectile).Landed(HitNormal);
	Explode(Location,HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	Landed(HitNormal);
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	PlaySound(ExplosionSound,,5.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'StarboltFlareBombExplosion',,,HitLocation + HitNormal*16, rotator(HitNormal) + rot(-16384,0,0));
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

defaultproperties
{
     ExplosionSound=Sound'StarboltV2Omni.FlareBombExplosion'
     DecoyFlightSFXClass=Class'StarboltV2Omni.StarboltFlareDecoyFlight'
     MaxSpeed=5600.000000
     Damage=267.000000
     // was 500.  Added Vehicle Damage Scaling of 1.5
     DamageRadius=850.000000
     MomentumTransfer=90000.000000
     MyDamageType=Class'StarboltV2Omni.DamTypeStarboltFlareBomb'
     LifeSpan=15.000000
     bFullVolume=True
     SoundVolume=255
     SoundRadius=500.000000
     TransientSoundVolume=1.400000
     TransientSoundRadius=800.000000
     bSelected=True
}
