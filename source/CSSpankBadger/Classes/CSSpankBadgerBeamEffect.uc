class CSSpankBadgerBeamEffect extends ShockBeamEffect;

simulated function SpawnImpactEffects(rotator HitRot, vector EffectLoc)
{
    Spawn(class'CSSpankBadger.CSSpankBadgerProjectileExplosionSmall',,,EffectLoc,HitRot);
}

simulated function SpawnEffects()
{
    local ShockBeamCoil Coil;
    local xWeaponAttachment Attachment;
	
    if (Instigator != None)
    {
        if ( Instigator.IsFirstPerson() )
        {
			if ( (Instigator.Weapon != None) && (Instigator.Weapon.Instigator == Instigator) )
				SetLocation(Instigator.Weapon.GetEffectStart());
			else
				SetLocation(Instigator.Location);
            Spawn(MuzFlashClass,,, Location);
        }
        else
        {
            Attachment = xPawn(Instigator).WeaponAttachment;
            if (Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1)
                SetLocation(Attachment.GetTipLocation());
            else
                SetLocation(Instigator.Location + Instigator.EyeHeight*Vect(0,0,1) + Normal(mSpawnVecA - Instigator.Location) * 25.0); 
            Spawn(MuzFlash3Class);
        }
    }

    //if ( EffectIsRelevant(mSpawnVecA + HitNormal*2,false) && (HitNormal != Vect(0,0,0)) )
    //if ( EffectIsRelevant(mSpawnVecA + HitNormal*2,false))
		SpawnImpactEffects(Rotator(HitNormal),mSpawnVecA + HitNormal*2);
	
    if ( (!Level.bDropDetail && (Level.DetailMode != DM_Low) && (VSize(Location - mSpawnVecA) > 40) && !Level.GetLocalPlayerController().BeyondViewDistance(Location,0))
		|| ((Instigator != None) && Instigator.IsFirstPerson()) )
    {
	    Coil = Spawn(CoilClass,,, Location, Rotation);
	    if (Coil != None)
		    Coil.mSpawnVecA = mSpawnVecA;
    }
}


defaultproperties
{
    mParticleType=PT_Beam
    mStartParticles=1
    mAttenKa=0.1
    //mSizeRange(0)=24.0
    //mSizeRange(1)=48.0
    mSizeRange(0)=12.0
    mSizeRange(1)=18.0
    mRegenDist=150.0
    //mLifeRange(0)=0.75
    mLifeRange(0)=0.95
    //mMaxParticles=3
    mMaxParticles=5

	CoilClass=class'CSSpankBadgerShockBeamCoil'
	MuzFlashClass=class'CSSpankBadgerMuzzleFlash'
	MuzFlash3Class=class'CSSpankBadgerMuzzleFlash'
    //Texture=Texture'ShockBeamTex'
    //Skins(0)=Texture'ShockBeamTex'

    Texture=Texture'CSSpankBadger.Badger.ShockBeamTex'
    Skins(0)=Texture'CSSpankBadger.Badger.ShockBeamTex'

}