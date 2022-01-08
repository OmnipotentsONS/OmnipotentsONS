class RoboShieldEffect3rd extends Actor;

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
	if (Excalibur_Robot(Owner) != None)
        Excalibur_Robot(Owner).NotifyShieldHit(Dam, instigatedBy);
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

        if (ShockShieldHitEffect != None && Owner != None && Excalibur_Robot(Owner) != None)
            ShockShieldHitEffect.SetLocation(location);
            ShockShieldHitEffect.SetRotation(Rotation);
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
                ShockShieldEffect = spawn(class'RoboShockShieldEffectBlue', self);
            else
                ShockShieldEffect = spawn(class'RoboShockShieldEffectRed', self);

            PlaySound(sound'ONSBPSounds.ShockTank.ShieldActivate', SLOT_None, 2.0);
        }
        ShockShieldEffect.SetLocation(location);
            ShockShieldEffect.SetRotation(Rotation);

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
simulated function Tick (float DeltaTime)
{
  if (ShockShieldEffect != None && Owner != None && Excalibur_Robot(Owner) != None)
      {
       ShockShieldEffect.SetLocation(location);
       ShockShieldEffect.SetRotation(Rotation);
      }

}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield'
     bHidden=True
     DrawScale3D=(X=2.000000,Y=0.500000,Z=2.000000)
     CollisionRadius=650.000000
     CollisionHeight=350.000000
     bBlockProjectiles=True
     bProjTarget=True
}
