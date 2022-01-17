//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitilarShield extends Actor;

#exec OBJ LOAD FILE=..\StaticMeshes\ONS-BPJW1.usx

var Emitter ShockShieldEffect, ShockShieldHitEffect;

function Bump( actor Other )
{
	if ( Projectile(Other) != None )
	{
		Other.HitWall(-1*Normal(Other.Velocity),self);
	}
}

function TakeDamage(int Dam, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (HospitilarShieldCannon(Owner) != None)
        HospitilarShieldCannon(Owner).NotifyShieldHit(Dam, instigatedBy);
}

simulated function SpawnHitEffect(byte TeamNum)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect != None)
        {
            if (TeamNum == 1)
                ShockShieldHitEffect = spawn(class'HospitilarShieldHitEffectBlue', self);
            else
                ShockShieldHitEffect = spawn(class'HospitilarShieldHitEffectRed', self);
        }

        if (ShockShieldHitEffect != None && Owner != None && HospitilarShieldCannon(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'SIDEgunBARREL');
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
                ShockShieldEffect = spawn(class'HospitilarShieldEffectBlue', self);
            else
                ShockShieldEffect = spawn(class'HospitilarShieldEffectRed', self);

            PlaySound(sound'ONSBPSounds.ShockTank.ShieldActivate', SLOT_None, 2.0);
        }

        if (ShockShieldEffect != None && Owner != None && HospitilarShieldCannon(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'SIDEgunBARREL');
    }
}

simulated function DeactivateShield()
{
    SetCollision(False, False, False);

    if (Level.NetMode != NM_DedicatedServer)
        PlaySound(sound'ONSBPSounds.ShockTank.ShieldOff', SLOT_None, 2.0);

    if (ShockShieldEffect != None)
        ShockShieldEffect.Destroy();
}

simulated function Destroyed()
{
    if (ShockShieldEffect != None)
        ShockShieldEffect.Destroy();

    Super.Destroyed();
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield'
     bHidden=True
     RemoteRole=ROLE_None
     DrawScale3D=(X=2.000000,Y=3.000000,Z=3.000000)
     CollisionRadius=650.000000
     CollisionHeight=350.000000
     bBlockProjectiles=True
     bProjTarget=True
}
