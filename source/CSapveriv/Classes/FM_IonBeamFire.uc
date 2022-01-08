class FM_IonBeamFire extends InstantFire;

var()	class<FX_Turret_IonCannon_BeamFire> BeamEffectClass;

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax


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
		Weapon.AttachToBone(FlashEmitter, 'tip');
}

// for bot combos
function Rotator AdjustAim(Vector Start, float InAimError)
{

	return Super.AdjustAim(Start, InAimError);
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local FX_Turret_IonCannon_BeamFire Beam;

    if (Weapon != None)
    {
        Beam = Weapon.Spawn(BeamEffectClass,,, Start+Vect(0,0,-64), Dir);
        if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
    }
}

defaultproperties
{
     BeamEffectClass=Class'OnslaughtFull.ONSHoverTank_IonPlasma_BeamFire'
     DamageType=Class'XWeapons.DamTypeShockBeam'
     DamageMin=1000
     DamageMax=1000
     TraceRange=17000.000000
     Momentum=200000.000000
     FireSound=Sound'WeaponSounds.BaseImpactAndExplosions.BExplosion5'
     FireForce="ShockRifleFire"
     FireRate=3.000000
     AmmoClass=Class'XWeapons.ShockAmmo'
     AmmoPerFire=1
     BotRefireRate=3.000000
     FlashEmitterClass=Class'XEffects.ShockBeamMuzFlash'
     aimerror=700.000000
}
