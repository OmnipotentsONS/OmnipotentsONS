class FM_RoboIonBeamFire extends FM_IonBeamFire;
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax
var()	class<FX_AP_IONLaserCannon_BeamFire> BeamEffectClass;
var()	class<FX_IONTurretLaserCannon_BeamFireRed> BeamEffectClassRed;

var vector IonOffset;


function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;

    Instigator.MakeNoise(1.0);

    StartTrace = Instigator.Location + Instigator.EyePosition();

    Aim = AdjustAim(StartTrace, AimError);
	R = rotator(vector(Aim) + VRand()*FRand()*Spread);
    DoTrace(StartTrace, R);
}

function InitEffects()
{
	if ( Level.DetailMode == DM_Low )
		FlashEmitterClass = None;
    Super.InitEffects();
    if ( FlashEmitter != None )
		Excalibur_Robot(instigator).Thrusters.AttachToBone(FlashEmitter, 'FirePoint');
}

// for bot combos
function Rotator AdjustAim(Vector Start, float InAimError)
{

	return Super.AdjustAim(Start, InAimError);
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local vector firelocation;
    local FX_AP_IONLaserCannon_BeamFire Beam;
    local FX_IONTurretLaserCannon_BeamFireRed RedBeam;
    firelocation=instigator.Location + (IonOffset >> instigator.Rotation);

    if ( Excalibur_Robot(instigator).Team == 1 )
      {
       Beam = Spawn(BeamEffectClass,,, firelocation, Dir);
       if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
       Beam.AimAt(HitLocation, HitNormal);
      }
    else
      {
       RedBeam = Spawn(BeamEffectClassRed,,, firelocation, Dir);
       if (ReflectNum != 0) RedBeam.Instigator = None; // prevents client side repositioning of beam start
       RedBeam.AimAt(HitLocation, HitNormal);
      }
}

defaultproperties
{
     BeamEffectClass=Class'CSAPVerIV.FX_AP_IONLaserCannon_BeamFire'
     BeamEffectClassRed=Class'CSAPVerIV.FX_IONTurretLaserCannon_BeamFireRed'
     IonOffset=(X=64.000000,Y=-64.000000,Z=164.000000)
     bFireOnRelease=True
     FireRate=4.000000
}
