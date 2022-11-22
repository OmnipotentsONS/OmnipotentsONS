//=============================================================================
// ProjectileJumppad
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:21:24 in Package: UltimateMappingTools$
//
// Got inspired by Quake 4 where you can place grenades on a Jumppad and it
// bumps them up as well.
//=============================================================================
class ProjectileJumppad extends UTJumppad;

var() array< class<Projectile> > AllowedProjectiles;
var() bool bKeepOriginalPath; // If True, projectiles are influenced but not completely changed by the Jumppad.


event Touch(Actor Other)
{
    if ( ((UnrealPawn(Other) == None) || (Other.Physics == PHYS_None)) && !IsValidProjectile(Other) )
        return;

    PendingTouch = Other.PendingTouch;
    Other.PendingTouch = self;
}

event PostTouch(Actor Other)
{
    local Pawn P;
    local Projectile Proj;

    if (Projectile(Other) != None)
    {
        Proj = Projectile(Other);
        Proj.SetPhysics(PHYS_Falling);
        if (bKeepOriginalPath)
        {
            Proj.Velocity +=  JumpVelocity;
        }
        else
        {
            Proj.Velocity =  JumpVelocity;
            Proj.Acceleration = vect(0,0,0);
            Proj.SetRotation(Rotator(JumpVelocity));
        }
        if ( JumpSound != None )
            Proj.PlaySound(JumpSound);
    }
    else
    {
        P = Pawn(Other);
        if ( (P == None) || (P.Physics == PHYS_None) || (Vehicle(Other) != None) || (P.DrivenVehicle != None) )
            return;

        if ( AIController(P.Controller) != None )
        {
            P.Controller.Movetarget = JumpTarget;
            P.Controller.Focus = JumpTarget;
            if ( P.Physics != PHYS_Flying )
                P.Controller.MoveTimer = 2.0;
            P.DestinationOffset = JumpTarget.CollisionRadius;
        }
        if ( P.Physics == PHYS_Walking )
            P.SetPhysics(PHYS_Falling);
        P.Velocity =  JumpVelocity;
        P.Acceleration = vect(0,0,0);
        if ( JumpSound != None )
            P.PlaySound(JumpSound);
    }

}


function bool IsValidProjectile(Actor Other)
{
    local int i;

    for (i = 0; i < AllowedProjectiles.Length; i++)
    {
        if (ClassIsChildOf(Other.Class, AllowedProjectiles[i]))
            return True;
    }

    return False;
}

defaultproperties
{
     AllowedProjectiles(0)=Class'XWeapons.Grenade'
     AllowedProjectiles(1)=Class'Onslaught.ONSGrenadeProjectile'
     AllowedProjectiles(2)=Class'Onslaught.ONSMineProjectile'
}
