class CSSniperMechWeapon extends ONSWeapon;

var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;
var class<xEmitter> BeamEffectClass;

var() float HeadShotDamageMult;
var() class<DamageType> DamageTypeHeadShot;

var() class<xEmitter> HitEmitterClass;
var() class<xEmitter> SecHitEmitterClass;
var() int NumArcs;
var() float SecDamageMult;
var() float SecTraceDist;

simulated function PostBeginPlay()
{
    local rotator r;
    super.PostBeginPlay();
    r = GetBoneRotation('Bone_weapon');
    //r.Pitch -= 32768;
    r.Yaw += 32768;
    r.Roll -= 16384;

    SetBoneRotation('Bone_weapon',r);
}


simulated function Destroyed()
{
	if ( MuzFlash != None )
		MuzFlash.Destroy();

	Super.Destroyed();
}

simulated event FlashMuzzleFlash()
{
    local rotator r;

    super.FlashMuzzleFlash();

    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
        if (MuzFlash == None)
        {
            MuzFlash = Spawn(MuzFlashClass);
            if ( MuzFlash != None )
            {
                MuzFlash.SetDrawScale(4.0);
                MuzFlash.SetDrawScale3D(vect(4.0,4.0,4.0));
				AttachToBone(MuzFlash, 'tip');
            }
        }
        if (MuzFlash != None)
        {
            MuzFlash.mStartParticles++;
            r.Roll = Rand(65536);
            SetBoneRotation('Bone_Flash', r, 0, 1.f);
        }
    }
}


simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}


function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, mainArcHitTarget;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle VehicleInstigator;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum, arcsRemaining;
    local class<Actor> tmpHitEmitClass;
    local float tmpTraceRange;
    local vector arcEnd, mainArcHit;    
    local Pawn HeadShotPawn;
    local vector EffectOffset;

    MaxRange();

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

    GetViewAxes(X,Y,Z);
    EffectOffset = WeaponFireLocation;
    arcEnd = (Instigator.Location + EffectOffset.X * X - 0.5 * EffectOffset.Z * Z);

    arcsRemaining = NumArcs;
    tmpHitEmitClass = HitEmitterClass;
    tmpTraceRange = TraceRange;

    ReflectNum = 0;
    while ( true )
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + tmpTraceRange * X;

        //skip past vehicle driver
        VehicleInstigator = Vehicle(Instigator);
        if ( ReflectNum == 0 && VehicleInstigator != None && VehicleInstigator.Driver != None )
        {
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else
        {
        	Other = Trace(HitLocation, HitNormal, End, Start, True);
        }

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = True;
                HitNormal = vect(0,0,0);
            }
            else if (!Other.bWorldGeometry)
            {
                Damage = (DamageMin + Rand(DamageMax - DamageMin));
 				if ( Vehicle(Other) != None || Pawn(Other) == None )
 				{
 					HitCount++;
 					LastHitLocation = HitLocation;
					SpawnHitEffects(Other, HitLocation, HitNormal);
				}

                if (Vehicle(Other) != None)
                    HeadShotPawn = Vehicle(Other).CheckForHeadShot(HitLocation, X, 1.0);

                if (HeadShotPawn != None)
                    HeadShotPawn.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
                else if ( (Pawn(Other) != None) && Pawn(Other).IsHeadShot(HitLocation, X, 1.0) )
                    Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
                else
                {
                    if(arcsRemaining < NumArcs)
                        Damage *= SecDamageMult;
                        
                    Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
                }

				HitNormal = vect(0,0,0);
            }
            else
            {
                HitCount++;
                LastHitLocation = HitLocation;
                SpawnHitEffects(Other, HitLocation, HitNormal);
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
            HitCount++;
            LastHitLocation = HitLocation;
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if( arcsRemaining == NumArcs )
        {
            mainArcHit = HitLocation + (HitNormal * 2.0);
            if ( Other != None && !Other.bWorldGeometry )
                mainArcHitTarget = Other;
        }

        if ( bDoReflect && ++ReflectNum < 4 )
        {
            Start	= HitLocation;
            Dir		= Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
         else if ( arcsRemaining > 0 )
        {
            arcsRemaining--;

            // done parent arc, now move trace point to arc trace hit location and try child arcs from there
            Start = mainArcHit;
            Dir = Rotator(VRand());
            tmpHitEmitClass = SecHitEmitterClass;
            tmpTraceRange = SecTraceDist;
            arcEnd = mainArcHit;
        }
        else
        {
            break;
        }
    }

    NetUpdateTime = Level.TimeSeconds - 1;
}

state InstantFireMode
{
    function Fire(Controller C)
    {
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		Super.Fire(C);
    }

    function AltFire(Controller C)
    {
    }
}


function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local xEmitter Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    if(Beam != None)
    {
        Beam.mSpawnVecA = HitLocation;
    }
}

function byte BestMode()
{
	return 0;
}

defaultproperties
{
    Mesh=mesh'Weapons.Sniper_3rd'
    YawBone='Bone_weapon'
    PitchBone='Bone_weapon'
    DrawScale=2.5
    MuzFlashClass=class'LightningCharge3rd'
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153

    BeamEffectClass=class'CSSniperMechBolt'
    //DamageType=class'DamTypeSniperShot'
    DamageType=class'CSSniperMechDamTypeSniperShot'
    //DamageTypeHeadShot=class'DamTypeSniperHeadShot'
    DamageTypeHeadShot=class'CSSniperMechDamTypeSniperHeadshot'
    DamageMin=280
    DamageMax=280

    FireSoundClass=Sound'WeaponSounds.BLightningGunFire'
    FireSoundVolume=255
    FireSoundRadius=1500
    FireInterval=1.6
    FireSoundPitch=0.8
    TraceRange=20000
    AltFireInterval=0.2

    RotateSound=sound'CSMech.turretturn'
    RotateSoundThreshold=50.0

    WeaponFireAttachmentBone=Bone_Flash
    WeaponFireOffset=0.0
    bAimable=True
    bInstantRotation=true
    bInstantFire=true
    bDoOffsetTrace=false
    DualFireOffset=0
    bShowAimCrosshair=true
    
    //HeadShotDamageMult=2.0
    HeadShotDamageMult=2.0

    NumArcs=3
    SecDamageMult=0.5
    SecTraceDist=1200.0

}