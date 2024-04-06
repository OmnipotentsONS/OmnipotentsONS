class BioHoundGlob extends BioGlob;

simulated function Destroyed()
{
    if ( !bNoFX && EffectIsRelevant(Location,false) )
    {
        Spawn(class'BioGoopSmoke');
        Spawn(class'BioGoopSparks');
    }
	if ( Fear != None )
		Fear.Destroy();
    if (Trail != None)
        Trail.Destroy();
    Super.Destroyed();
}

auto state Flying
{
    simulated function Landed( Vector HitNormal )
    {
        local Rotator NewRot;
        local int CoreGoopLevel;

        if ( Level.NetMode != NM_DedicatedServer )
        {
            PlaySound(ImpactSound, SLOT_Misc);
        }

        SurfaceNormal = HitNormal;

        CoreGoopLevel = Rand3 + MaxGoopLevel - 3;
        if (GoopLevel > CoreGoopLevel)
        {
            if (Role == ROLE_Authority)
                SplashGlobs(GoopLevel - CoreGoopLevel);
            SetGoopLevel(CoreGoopLevel);
        }
		spawn(class'BioChemDecal',,,, rotator(-HitNormal));

        bCollideWorld = false;
        SetCollisionSize(GoopVolume*10.0, GoopVolume*10.0);
        bProjTarget = true;

	    NewRot = Rotator(HitNormal);
	    NewRot.Roll += 32768;
        SetRotation(NewRot);
        SetPhysics(PHYS_None);
        bCheckedsurface = false;
		if ( (Level.Game != None) && (Level.Game.NumBots > 0) )
			Fear = Spawn(class'AvoidMarker');
        GotoState('OnGround');
    }

    simulated function HitWall( Vector HitNormal, Actor Wall )
    {
        Landed(HitNormal);
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
        {
            bOnMover = true;
            SetBase(Wall);
            if (Base == None)
                BlowUp(Location);
        }
    }

    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
        local BioGlob Glob;

        Glob = BioGlob(Other);

        if ( Glob != None )
        {
            if (Glob.Owner == None || (Glob.Owner != Owner && Glob.Owner != self))
            {
                if (bMergeGlobs)
                {
                    Glob.MergeWithGlob(GoopLevel);
                    bNoFX = true;
                    Destroy();
                }
                else
                {
                    BlowUp( HitLocation );
                }
            }
        }
        else if (Other != Instigator && (Other.IsA('Pawn') || Other.IsA('DestroyableObjective') || Other.bProjTarget))
            BlowUp( HitLocation );
		else if ( Other != Instigator && Other.bBlockActors )
			HitWall( Normal(HitLocation-Location), Other );
    }
}

defaultproperties
{
     BaseDamage=65
     GloblingSpeed=600.000000
     RestTime=1.250000
     DripTime=1.300000
     GoopVolume=2.000000
     Speed=3000.000000
     MaxSpeed=4000.000000
     TossZ=120.000000
     Damage=45.000000
     DamageRadius=160.000000
     MomentumTransfer=50000.000000
     //MyDamageType=Class'BioHoundOmni.BioHoundKill'
     MyDamageType=Class'BioTypes.DamTypeBioGlobVehicle'
     MaxEffectDistance=9000.000000
     LightBrightness=210.000000
     LightRadius=0.900000
     DrawScale=2.30000
     SoundVolume=94
     SoundRadius=300.000000
     CollisionRadius=5.200000
     CollisionHeight=5.200000
}
