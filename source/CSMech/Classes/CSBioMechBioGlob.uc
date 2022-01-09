class CSBioMechBioGlob extends BioGlob;


simulated function PostBeginPlay()
{
    if(CSBioMechBioGlob(owner) != None)
    {
        GoopLevel=Clamp(CSBioMechBioGlob(Owner).GoopLevel-1, 0, MaxGoopLevel);
        SetDrawScale(GoopLevel+1);
        Damage=Clamp(Damage - ((MaxGoopLevel-GoopLevel)*20), 10, default.Damage);
        DamageRadius=Clamp(DamageRadius - ((MaxGoopLevel-GoopLevel)*20), 100, default.DamageRadius);
        AmbientSound=None;
    }

    super(Projectile).PostBeginPlay();


    SetOwner(None);

    LoopAnim('flying', 1.0);

    if (Role == ROLE_Authority)
    {
        Velocity = Vector(Rotation) * Speed;
        Velocity.Z += TossZ;
    }

    /*
    if(Role == ROLE_Authority)
    {
        //Velocity = Speed * Vector(Rotation); 
        if(Instigator != None)
        {
            Velocity =Instigator.Velocity * 0.9;
            Velocity.Z += -30;
        }
        RandSpin(25000);
    }
    */

    if (Role == ROLE_Authority)
         Rand3 = Rand(6);

	if ( (Level.NetMode != NM_DedicatedServer) && ((Level.DetailMode == DM_Low) || Level.bDropDetail) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
}

simulated function Destroyed()
{
    if ( !bNoFX && EffectIsRelevant(Location,false) )
    {
        Spawn(class'CSBioMechBigGoopSmoke');
        Spawn(class'CSBioMechBigGoopSparks');
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

        if ( Level.NetMode != NM_DedicatedServer )
        {
            PlaySound(ImpactSound, SLOT_Misc);
            // explosion effects
        }

        SurfaceNormal = HitNormal;

        /*
        // spawn globlings
        CoreGoopLevel = Rand3 + MaxGoopLevel - 3;
        if (GoopLevel > CoreGoopLevel)
        {
            if (Role == ROLE_Authority)
                SplashGlobs(GoopLevel - CoreGoopLevel);
            SetGoopLevel(CoreGoopLevel);
        }
        */
        if(Role == ROLE_Authority && GoopLevel > 0)
            SplashGlobs(GoopLevel);

		spawn(class'CSBioMechBioDecal',,,, rotator(-HitNormal));

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
                    //Glob.MergeWithGlob(GoopLevel); // balancing on the brink of infinite recursion
                    Glob.MergeWithGlob(Clamp(GoopLevel-1, 0, MaxGoopLevel)); // balancing on the brink of infinite recursion
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
    bMergeGlobs=true
    //AmbientSound=sound'CSBomber.BombDrop'

     //BaseDamage=100
     //BaseDamage=50
     BaseDamage=50
     GloblingSpeed=200.000000
     //RestTime=1.600000
     RestTime=0.600000
     DripTime=2.200000
     GoopLevel=2
     //MaxGoopLevel=10
     MaxGoopLevel=3
     GoopVolume=2.600000
     //Speed=1000.000000
     //MaxSpeed=1000.000000

     Speed=4000.000000
     MaxSpeed=4000.000000
     Physics=PHYS_Projectile
     Acceleration=(Z=-960)

     TossZ=120.000000
     //Damage=550.000000
     //Damage=150.000000
     Damage=150.000000
     //DamageRadius=200.000000
     DamageRadius=150.000000
     MomentumTransfer=500000.000000
    MyDamageType=class'DamTypeBioGlob'
     MaxEffectDistance=10000.000000
     LightBrightness=250.000000
     LightRadius=4.200000
     DrawScale=5.0
     SoundVolume=144
     SoundRadius=300.000000
     CollisionRadius=7.000000
     CollisionHeight=7.000000
}
