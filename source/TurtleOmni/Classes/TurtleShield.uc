class TurtleShield extends Actor;

#exec OBJ LOAD FILE=..\StaticMeshes\CuddlyShields.usx

var Emitter TurtleShieldEffect, TurtleShieldHitEffect;

function Bump( actor Other )
{
	if ( Projectile(Other) != None )
	{
		Other.HitWall(-1*Normal(Other.Velocity),self);
	}
}

function TakeDamage(int Dam, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (TurtleCannon(Owner) != None)
        TurtleCannon(Owner).NotifyShieldHit(Dam, instigatedBy);
}

simulated function SpawnHitEffect(byte TeamNum)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (TurtleShieldEffect != None)
        {
            if (TeamNum == 1)
                TurtleShieldHitEffect = spawn(class'TurtleShieldHitEffectBlue', self);
            else
                TurtleShieldHitEffect = spawn(class'TurtleShieldHitEffectRed', self);
        }

        if (TurtleShieldHitEffect != None && Owner != None && TurtleCannon(Owner) != None)
            Owner.AttachToBone(TurtleShieldEffect, 'ElectroGun');
    }
}

simulated function ActivateShield(byte TeamNum)
{
    SetCollision(True, False, False);

    if (Level.NetMode != NM_DedicatedServer)
    {
        if (TurtleShieldEffect == None)
        {
            if (TeamNum == 1)
                TurtleShieldEffect = spawn(class'TurtleShieldEffectBlue', self);
            else
                TurtleShieldEffect = spawn(class'TurtleShieldEffectRed', self);

            PlaySound(sound'ONSBPSounds.ShockTank.ShieldActivate', SLOT_None, 2.0);
        }

        if (TurtleShieldEffect != None && Owner != None && TurtleCannon(Owner) != None)
            Owner.AttachToBone(TurtleShieldEffect, 'ElectroGun');
    }
}

simulated function DeactivateShield()
{
    SetCollision(False, False, False);

    if (Level.NetMode != NM_DedicatedServer)
        PlaySound(sound'ONSBPSounds.ShockTank.ShieldOff', SLOT_None, 2.0);

    if (TurtleShieldEffect != None)
        TurtleShieldEffect.Destroy();
}

simulated function Destroyed()
{
    if (TurtleShieldEffect != None)
        TurtleShieldEffect.Destroy();

    Super.Destroyed();
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'TurtleOmniSM.Turtle.TShield'
     bHidden=True
     RemoteRole=ROLE_None
     DrawScale3D=(X=2.000000,Y=2.500000,Z=2.000000)
     CollisionRadius=650.000000
     CollisionHeight=350.000000
     bBlockProjectiles=True
     bProjTarget=True
}
