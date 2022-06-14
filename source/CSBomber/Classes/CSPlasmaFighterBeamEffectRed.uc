class CSPlasmaFighterBeamEffectRed extends CSPlasmaFighterBeamEffect;


simulated function SpawnImpactEffects(rotator HitRot, vector EffectLoc)
{
	Spawn(class'ShockImpactFlareB',,, EffectLoc, HitRot);
	Spawn(class'ShockImpactRingB',,, EffectLoc, HitRot);
	Spawn(class'ShockImpactScorch',,, EffectLoc, Rotator(-HitNormal));
	Spawn(class'ShockExplosionCoreB',,, EffectLoc, HitRot);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     CoilClass=Class'CSPlasmaFighterBeamCoilRed'
     MuzFlashClass=Class'XEffects.ShockMuzFlashB'
     MuzFlash3Class=Class'XEffects.ShockMuzFlashB3rd'
     Skins(0)=Texture'CSBomber.RailgunBeamRedTex'
}
