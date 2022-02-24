
class CSDarkRailSecondaryTurret extends ONSWeapon;

var class<ShockBeamEffect> BeamEffectClass[2];


function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass[Team],,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}

defaultproperties
{

    bInstantFire=true
    BeamEffectClass(0)=class'SuperShockBeamEffect'
    BeamEffectClass(1)=class'BlueSuperShockBeam'
    DamageType=class'DamTypeSuperShockBeam'

    WeaponFireAttachmentBone=Object02
	WeaponFireOffset=60.0
	Mesh=Mesh'AS_VehiclesFull_M.IonTankMachineGun'


    YawBone=Object01
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchBone=Object02
    PitchUpLimit=12500
    PitchDownLimit=59500
    FireInterval=1.1
    FireSoundClass=Sound'WeaponSounds.instagib_rifleshot'

    SoundVolume=255
    AmbientSoundScaling=1.3

    ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=2
    ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
    ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
    ShakeRotTime=2

    FireForce="minifireb"
    DualFireOffset=5.0
    bAimable=True
    DamageMin=1000
    DamageMax=1000
    Momentum=100000
    Spread=0.0001
    RotationsPerSecond=2.0
    bInstantRotation=true
    RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
    BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
    bDoOffsetTrace=true
    TraceRange=17000

    AIInfo(0)=(bInstantHit=true,AimError=750)
}