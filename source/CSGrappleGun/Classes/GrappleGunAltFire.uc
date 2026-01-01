class GrappleGunAltFire extends WeaponFire;

var() Sound TransFailedSound;
var() float grappleDistToStop;
var() float grappleFscale;
var() float grappleMaxForceFactor;
var() float grappleMaxLength;

simulated function PlayFiring()
{
    if ( GrappleGun(Weapon).bBeaconDeployed )
    {
        Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    }
}

simulated function bool AllowFire()
{
    /*
    local bool success;
    
    success = ( GrappleGun(Weapon).AmmoChargeF >= 1.0 );
    if (!success && (Weapon.Role == ROLE_Authority) && (GrappleGun(Weapon).GrappleGunBeacon != None) )
    {
        if( PlayerController(Instigator.Controller) != None )
            PlayerController(Instigator.Controller).ClientPlaySound(TransFailedSound);
    }

    return success;
    */
    return true;
}

function DoFireEffect()
{
    if (GrappleGun(Weapon).GrappleGunBeacon != None)
    {
        // bounce is toggled on hitwall event
        if(!GrappleGun(Weapon).GrappleGunBeacon.bBounce)
            GrapplePull();
    }
}

simulated function GrapplePull() 
{
    local Pawn P;
    local Controller C;

    if (Weapon.Owner.Physics == PHYS_Walking)
        SetPlayerPhysics(Weapon.Owner);

    P = Pawn(Weapon.Owner);
    if(P != None)
    {
        C = P.Controller;
        if(C != None && C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.HasFlag != None)
            P.DropFlag();
    }

    GotoState('Swinging');
}

state Swinging
{
    simulated function BeginState()
    {
        Pawn(Weapon.Owner).bCanFly=True;
    }

    simulated function ModeTick(float DeltaTime)
    {
        local vector PawnDir;
        local vector dist;
        local vector TargetPos, TargetDir;
        local GrappleGunBeacon Beacon;
        local Actor.EPhysics OldPhysics;

        Beacon = GrappleGun(Weapon).GrappleGunBeacon;

        if(Beacon != None)
        {
            if(bIsFiring && VSize(Beacon.Location - Weapon.Owner.Location) < grappleMaxLength)
            {
                OldPhysics = Weapon.Owner.Physics;
                SetPlayerPhysics(Weapon.Owner);        
                PawnDir = Normal(Beacon.Velocity - Owner.Velocity);
                TargetPos = Beacon.Location - PawnDir * grappleDistToStop;

                dist = Owner.Location - TargetPos;
                TargetDir = Normal(Owner.Location - TargetPos);

                if(VSize(Beacon.Location - Owner.Location) > grappleDistToStop)
                    Weapon.Owner.Velocity += TargetDir * FClamp(VSize(dist)*VSize(dist)*grappleFScale, 0, grappleMaxForceFactor) * DeltaTime * -1;
                else
                    Weapon.Owner.Velocity += Beacon.Velocity;

                if(xPawn(Beacon.Base) != none)
                {
                    SetPlayerPhysics(xPawn(Beacon.Base));
                    xPawn(Beacon.Base).Velocity += -TargetDir * FClamp(VSize(dist)*VSize(dist)*grappleFScale, 0, grappleMaxForceFactor) * DeltaTime * -1;
                }
            }
            else
            {
                Beacon.Destroy();
                Beacon = None;
                GotoState('');
            }
        }
        else
            GotoState('');
    }

    simulated function EndState()
    {
        Pawn(Weapon.Owner).bCanFly=False;
        SetPlayerPhysics(Weapon.Owner);
    }
}

simulated function SetPlayerPhysics(Actor player)
{
   if (player.PhysicsVolume.bWaterVolume)
      player.SetPhysics(PHYS_Swimming);
   else
      player.SetPhysics(PHYS_Falling);
}

defaultproperties
{
    TransFailedSound=Sound'WeaponSounds.BaseGunTech.BSeekLost1'
    bModeExclusive=False
    bWaitForRelease=True
    FireAnim="Recall"
    FireRate=0.250000
    BotRefireRate=0.300000
    grappleDistToStop=320
    grappleMaxForceFactor=40000
    grappleFscale=0.1
    grappleMaxLength=20000
}
