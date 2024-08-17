//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FireBladeOmniTopTurret extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\FireBladeOmni.ukx

var class<ShockBeamEffect> BeamEffectClass;
var ONSSkyMine ComboTarget;
var float MinAim;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'XEffectMat.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flash');
    L.AddPrecacheMaterial(Material'XEffectMat.purple_line');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_a');
    L.AddPrecacheMaterial(Material'XWeapons_rc.ShockBeamTex');
    L.AddPrecacheMaterial(Material'XEffects.SaDScorcht');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core_low');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_Energy_green_faded');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.EclipseCircle');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flash');
    Level.AddPrecacheMaterial(Material'XEffectMat.purple_line');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_a');
    Level.AddPrecacheMaterial(Material'XWeapons_rc.ShockBeamTex');
    Level.AddPrecacheMaterial(Material'XEffects.SaDScorcht');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core_low');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_Energy_green_faded');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.EclipseCircle');

    Super.UpdatePrecacheMaterials();
}


function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;
    Start = WeaponFireLocation;
    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}

state InstantFireMode
{
    simulated function ClientSpawnHitEffects()
    {
    }

    function SpawnHitEffects(Actor HitActor, vector HitLocation, vector HitNormal)
    {
    }

    function Fire(Controller C)
    {

        ShakeView();
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            //PlayOwnedSound(AltFireSoundClass, SLOT_None, AltFireSoundVolume/300.0,, AltFireSoundRadius,, False);
	PlayOwnedSound(AltFireSoundClass, SLOT_Interact, 3 * TransientSoundVolume,,,, false);
//	Weapon.
	        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }


}

defaultproperties
{
     BeamEffectClass=Class'XWeapons.ShockBeamEffect'
     MinAim=0.925000
     YawBone="REARgunBASE"
     PitchBone="REARgunTURRET"
     PitchUpLimit=40000
     PitchDownLimit=-5000
     WeaponFireAttachmentBone="GunFire"
     DualFireOffset=15.000000
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     TraceRange=20000
     FireInterval=0.200000
     FireSoundClass=Sound'FireBladeAudioB001.TopCannon1'
     AltFireSoundClass=Sound'FireBladeAudioB001.TopCannon1'
     FireForce="PRVSideFire"
     AltFireForce="PRVSideAltFire"
     DamageType=Class'FireBladeOmni.DamTypeFireBladeLaser'
     DamageMin=15
     DamageMax=20
     ProjectileClass=Class'Onslaught.ONSSkyMine'
     ShakeRotMag=(X=60.000000,Y=20.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000)
     ShakeRotTime=2.000000
     AIInfo(0)=(bInstantHit=True,RefireRate=0.000000)
     AIInfo(1)=(bLeadTarget=True,WarnTargetPct=0.200000,RefireRate=1.000000)
     CullDistance=8000.000000
     RedSkin=Texture'FireBladeOmniTex.GunShipTopTurretTextureRed'
     BlueSkin=Texture'FireBladeOmniTex.GunShipTopTurretTextureBlue'
     Mesh=SkeletalMesh'FireBladeOmni.FireBladeTopTurret'
}
