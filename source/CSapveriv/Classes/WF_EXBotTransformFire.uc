class WF_EXBotTransformFire extends RedeemerFire;

var Excalibur Fighter;
var Pawn NewDriver;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
   Excalibur_Robot(Instigator).SpawnExcalibur(Start,Dir);

	bIsFiring = false;
    StopFiring();
    return None;

}

defaultproperties
{
     ProjSpawnOffset=(X=400.000000,Z=256.000000)
}
