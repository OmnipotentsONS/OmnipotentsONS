class CSBioMechWeapon extends ONSWeapon;

var float MinAim;
var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
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

state ProjectileFireMode
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

		Super.AltFire(C);
    }
}

defaultproperties
{
    //Mesh=mesh'NewWeapons2004.NewShockRifle_3rd'
    Mesh=mesh'Weapons.BioRifle_3rd'

    YawBone='Bone_weapon'
    PitchBone='Bone_weapon'
    //DrawScale=2.5
    DrawScale3D=(X=4.5,Y=3.5,Z=3.5)
    MuzFlashClass=class'CSLinkMechMuzFlash'
    
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153


    ProjectileClass=class'CSBioMechBioGlob'
    FireSoundClass=Sound'WeaponSounds.BioRifle.BioRifleFire'

    FireSoundVolume=255
    FireSoundRadius=1500
    FireSoundPitch=0.8
    FireInterval=0.33

    AltFireProjectileClass=class'CSBioMechBioGlobBomb'
    AltFireSoundClass=Sound'WeaponSounds.BioRifle.BioRifleFire'
    AltFireSoundRadius=1500
    AltFireInterval=1.4

    RotateSound=sound'CSMech.turretturn'
    RotateSoundThreshold=50.0

    WeaponFireAttachmentBone=Bone_Flash
    WeaponFireOffset=0.0
    bAimable=True
    bInstantRotation=true
    bDoOffsetTrace=true
    DualFireOffset=0
    AIInfo(0)=(bLeadTarget=true,RefireRate=0.95)
    AIInfo(1)=(bLeadTarget=true,AimError=400,RefireRate=0.50)
    MinAim=0.900
    TraceRange=20000
}