//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSShieldMechShield extends Actor;

#exec OBJ LOAD FILE=..\StaticMeshes\ONS-BPJW1.usx
#exec OBJ LOAD FILE=StaticMeshes\CSMech_StaticMesh.usx package=CSMech

var Emitter ShockShieldEffect, ShockShieldHitEffect;
var Sound ChargingSound;                // charging soun
function Bump( actor Other )
{
	if ( Projectile(Other) != None )
	{
		Other.HitWall(-1*Normal(Other.Velocity),self);
	}
}

function TakeDamage(int Dam, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (CSShieldMechWeapon(Owner) != None)
        CSShieldMechWeapon(Owner).NotifyShieldHit(Dam, instigatedBy);
}

simulated function SpawnHitEffect(byte TeamNum)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect != None)
        {
            if (TeamNum == 1)
                ShockShieldHitEffect = spawn(class'CSShieldMechShieldHitEffectBlue', self);
            else
                ShockShieldHitEffect = spawn(class'CSShieldMechShieldHitEffectRed', self);
        }

        if (ShockShieldHitEffect != None && Owner != None && CSShieldMechWeapon(Owner) != None)
            Owner.AttachToBone(ShockShieldHitEffect, 'tip');
    }
}

simulated function ActivateShield(byte TeamNum)
{
    SetCollision(True, False, False);

    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect == None)
        {
            if (TeamNum == 1)
                ShockShieldEffect = spawn(class'CSShieldMechShieldEffectBlue', self);
            else
                ShockShieldEffect = spawn(class'CSShieldMechShieldEffectRed', self);

            //PlaySound(sound'WeaponSounds.BShield1',, 2.0);
            //SetTimer(GetSoundDuration(sound'WeaponSounds.BShield1'), false);
        }

        if (ShockShieldEffect != None && Owner != None && CSShieldMechWeapon(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'tip');
    }
}
function Timer()
{
    if(Vehicle(Owner.Owner).bWeaponIsAltFiring)
    {
        PlaySound(sound'WeaponSounds.BShield1',, 2.0);
        SetTimer(GetSoundDuration(sound'WeaponSounds.BShield1'), false);
    }
}

simulated function DeactivateShield()
{
    SetCollision(False, False, False);

    if (Level.NetMode != NM_DedicatedServer)
    {
        //PlaySound(sound'ONSBPSounds.ShockTank.ShieldOff', SLOT_None, 2.0);
        //PlaySound(Sound'WeaponSounds.Translocator.TranslocatorModuleRegeneration', SLOT_None, 2.0);
    }

    if (ShockShieldEffect != None)
        ShockShieldEffect.Destroy();
}

simulated function Destroyed()
{
    if (ShockShieldEffect != None)
        ShockShieldEffect.Destroy();

    Super.Destroyed();
}

DefaultProperties
{
	bBlockProjectiles=true
    DrawType=DT_StaticMesh
    //StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield'
    //DrawScale3D=(X=2.0,Y=3.0,Z=3.0)    
    //DrawScale3D=(X=1.0,Y=3.0,Z=3.0)    
    //CollisionHeight=350
    //CollisionRadius=650

    StaticMesh=StaticMesh'CSMech.Shield'
    //StaticMesh=StaticMesh'WeaponStaticMesh.Shield'
    //Skins(0)=XEffectMat.Shield3rdFB
    //Skins(1)=FinalBlend'XEffectMat.ShieldRip3rdFB'    
    DrawScale3D=(X=32.0,Y=40.0,Z=40.0)
    CollisionHeight=350
    CollisionRadius=650
    //CollisionHeight=1400
    //CollisionRadius=2600
    bStatic=false
    bNoDelete=false
    bCollideWorld=false
    bHidden=true
    bProjTarget=true
    RemoteRole=ROLE_None

    ChargingSound=Sound'WeaponSounds.BShield1'
}
