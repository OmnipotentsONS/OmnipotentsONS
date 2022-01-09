class CSShockMechWeapon extends ONSWeapon;

var float MinAim;
var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;
var class<ShockBeamEffect> BeamEffectClass;

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
				AttachToBone(MuzFlash, 'tip');
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
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		//Super.AltFire(C);
        SpawnProjectile(AltFireProjectileClass, true);
    }
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}

defaultproperties
{
    Mesh=mesh'NewWeapons2004.NewShockRifle_3rd'
    YawBone='Bone_weapon'
    PitchBone='Bone_weapon'
    DrawScale=2.5
    MuzFlashClass=class'CSShockMechMuzFlash'
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153

    BeamEffectClass=class'CSShockMechShockBeam'
    DamageType=class'DamTypeShockBeam'
    DamageMin=180
    DamageMax=180

    FireSoundClass=Sound'WeaponSounds.ShockRifle.ShockRifleFire'
    FireSoundVolume=255
    FireSoundRadius=1500
    FireInterval=0.7
    FireSoundPitch=0.8

    AltFireProjectileClass=class'CSShockMechShockProjectile'
    AltFireSoundClass=Sound'WeaponSounds.ShockRifle.ShockRifleAltFire'

    AltFireSoundRadius=1500
    AltFireInterval=0.6

    RotateSound=sound'CSMech.turretturn'
    RotateSoundThreshold=50.0

    WeaponFireAttachmentBone=Bone_Flash
    WeaponFireOffset=0.0
    bAimable=True
    bInstantRotation=true
    bInstantFire=true
    bDoOffsetTrace=true
    DualFireOffset=0
    AIInfo(0)=(bLeadTarget=true,RefireRate=0.95)
    AIInfo(1)=(bLeadTarget=true,AimError=400,RefireRate=0.50)
    MinAim=0.900
    TraceRange=20000
}