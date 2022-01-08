class RoboShieldEffect extends Actor;

var Emitter ShockShieldEffect, ShockShieldHitEffect;

/*
function TakeDamage(int Dam, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	//if (RoboRifleAttachment(Owner) != None)
        RoboRifleAttachment(Owner).NotifyShieldHit();
}

simulated function SpawnHitEffect(byte TeamNum)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect != None)
        {
            if (TeamNum == 1)
                ShockShieldHitEffect = spawn(class'RoboShockShieldHitEffectBlue', self);
            else
                ShockShieldHitEffect = spawn(class'RoboShockShieldHitEffectRed', self);
        }

        if (ShockShieldHitEffect != None && Owner != None && RoboRifleAttachment(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'Bone_Flash');
    }
}

simulated function ActivateShield(byte TeamNum)
{

    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect == None)
        {
            if (TeamNum == 1)
                ShockShieldEffect = spawn(class'RoboShockShieldEffectBlue', self);
            else
                ShockShieldEffect = spawn(class'RoboShockShieldEffectRed', self);

            PlaySound(sound'ONSBPSounds.ShockTank.ShieldActivate', SLOT_None, 2.0);
        }

        if (ShockShieldEffect != None && Owner != None && RoboRifleAttachment(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'Bone_Flash');
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
*/

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield'
     bHidden=True
     bReplicateInstigator=True
     RemoteRole=ROLE_None
     DrawScale3D=(X=2.000000,Y=0.500000,Z=0.500000)
     CollisionRadius=650.000000
     CollisionHeight=350.000000
}
