class WF_EXFighterTransformFire extends RedeemerFire;

var Excalibur_Robot Robot;
var Pawn NewDriver;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
       Excalibur(Instigator).SpawnExcalibur_Robot(Start,Dir);
       bIsFiring = false;
       StopFiring();
       return None;
}

defaultproperties
{
     ProjSpawnOffset=(X=400.000000,Z=256.000000)
}
