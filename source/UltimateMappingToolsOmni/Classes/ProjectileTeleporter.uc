//=============================================================================
// ProjectileTeleporter
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:21:40 in Package: UltimateMappingTools$
//
// Got inspired by Quake 4 where you can shoot through teleporters. This won't
// let instant hit weapons pass, but it's still nice to send rockets in to clear
// the other side or to shoot them after an enemy.
//=============================================================================
class ProjectileTeleporter extends Teleporter;

var(Teleporter) array< class<Projectile> > AllowedProjectiles;

event Touch(Actor Other)
{
    if ( !bEnabled || (Other == None) )
        return;

    if( (Other.bCanTeleport || IsValidProjectile(Other)) && Other.PreTeleport(Self)==false )
    {
        PendingTouch = Other.PendingTouch;
        Other.PendingTouch = self;
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
     AllowedProjectiles(0)=Class'Engine.Projectile'
}
