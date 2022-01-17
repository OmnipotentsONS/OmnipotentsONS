//=============================================================================
//  Link Tank
//=============================================================================
// )o(Nodrak - 13/11/05
//     Custom Tank Pack
//=============================================================================
class LinkTLinkFire extends ProjectileFire;

var sound	LinkedFireSound;
var string	LinkedFireForce;
var LinkTWeapon LinkTWeapon;  // jdf
var class<PROJ_LinkTurret_Plasma> fireproj;

function DrawMuzzleFlash(Canvas Canvas)
{
    if (FlashEmitter != None)
    {
        FlashEmitter.SetLocation( Weapon.GetEffectStart() );
        LinkTWeapon.AttachMuzzleFlash(FlashEmitter);
        Super.DrawMuzzleFlash(Canvas);
    }
}

simulated function InitEffects()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
    {
        //FlashEmitter = Weapon.Spawn(FlashEmitterClass);
    }
    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    }
}

function FlashMuzzleFlash()
{
    if (FlashEmitter != None)
    {
        if (LinkGun(Weapon).Links > 0)
            FlashEmitter.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjYellowFB';
        else
            FlashEmitter.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjGreenFB';
    }
    Super.FlashMuzzleFlash();
}

function DoFireEffect()
{
	local vector	Start;
	local rotator  rotat;

	Instigator.MakeNoise(1.0);

	LinkTWeapon = LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]);

    Start = LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).GetFireStart();
    rotat = LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).WeaponFireRotation;
	//LinkTWeapon(LinkTank(Instigator).Weapons[0]).SimulateTraceFire( start2, rota, HL, HN );

    SpawnProjectile(Start, rotat );//Rotator(HL-Start) );
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local PROJ_LinkTurret_Plasma Proj;

    Start += Vector(Dir) * 10.0 * Weapon_LinkTurret(Weapon).Links;
    Proj = Weapon.Spawn(fireproj,,, Start, Dir);
    if ( Proj != None )
    {
		Proj.Links = LinkTW(Weapon).Links;
		Proj.LinkAdjust();
	}
    return Proj;
}

function ServerPlayFiring()
{
    if ( Weapon_LinkTurret(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;

    super.ServerPlayFiring();
}

function PlayFiring()
{
    if ( Weapon_LinkTurret(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;
    super.PlayFiring();
}

simulated function bool AllowFire()
{
    return true;
}

defaultproperties
{
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     LinkedFireForce="BLinkedFire"
     fireproj=Class'HospitalerV3Omni.LinkTankPlasma'
     FireLoopAnim=
     FireEndAnim=
     FireSound=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireForce="TranslocatorFire"
     FireRate=0.350000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     BotRefireRate=0.990000
     WarnTargetPct=0.100000
}
