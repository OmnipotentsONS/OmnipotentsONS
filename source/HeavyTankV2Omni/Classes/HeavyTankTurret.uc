class HeavyTankTurret extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<HeavyTankTurretBeamEffect> BeamEffectClass;
var ONSSkyMine ComboTarget;
var float MinAim;
var float MaxLockRange, LockAim;

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

function byte BestMode()
{
		return 0;
}


function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local HeavyTankTurretBeamEffect Beam;

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
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, False);

	        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

}


defaultproperties
{
     //BeamEffectClass=Class'XWeapons.ShockBeamEffect'
     BeamEffectClass =Class'HeavyTankTurretBeamEffect'
     MinAim=0.925000
     MaxLockRange=30000.000000
     LockAim=0.975000
     //YawBone="SIDEgunBASE"
     //PitchBone="SIDEgunBARREL"
     
     PitchUpLimit=-625000
     PitchDownLimit=-8000
     //WeaponFireAttachmentBone="Firepoint"
     
              
     //GunnerAttachmentBone="SideGunnerLocation"
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     RedSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVredSHAD'
     BlueSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVshad'
     FireInterval=0.67  //SR is .7
     //AltFireInterval=2.000000
     FlashEmitterClass=Class'Onslaught.ONSPRVSideGunMuzzleFlash'
     FireSoundClass=Sound'ONSVehicleSounds-S.PRV.PRVFire02'
     //AltFireSoundClass=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     //AltFireSoundVolume=512.000000
     FireForce="PRVSideFire"
     //AltFireForce="Explosion05"
     DamageType=Class'HeavyTankV2Omni.DamTypeHeavyShockCannon'
     DamageMin=50 // SR is 45
     DamageMax=50
     Momentum=40000.000000  //SR is 60000
    // AltFireProjectileClass=Class'HeavyTankV2Omni.HeavyTankMissle'
     ShakeRotMag=(X=60.000000,Y=20.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000)
     ShakeRotTime=2.000000
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.200000,RefireRate=1.000000)
     AIInfo(1)=(bInstantHit=True,RefireRate=0.000000)
     CullDistance=8000.000000
     TraceRange=17000.000000
     
          
     // Find a better mesh
     //Mesh=SkeletalMesh'ONSWeapons-A.TankMachineGun'
     
     YawBone="rvGUNTurret"
     PitchBone="rvGUNbody"
     WeaponFireAttachmentBone="RVfirePoint"
     Mesh=SkeletalMesh'ONSWeapons-A.RVnewGun'  
     // These have to reference animations in Mesh or it won't rotate.
 
 		 //YawBone="Object01"
     //PitchBone="Object02"
     //WeaponFireAttachmentBone="Object02"
     //Mesh=SkeletalMesh'AS_VehiclesFull_M.IONTankMachineGun'
     DrawScale=1.2000
}
