// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusLinkAltFire extends LinkAltFire;

var ONSPlusGameReplicationInfo OPGRI;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local ONSPlusLinkProjectile Proj;

	if (OPGRI == none && Pawn(Weapon.Owner).Controller != None && PlayerController(Pawn(Weapon.Owner).Controller) != None &&
		PlayerController(Pawn(Weapon.Owner).Controller).GameReplicationInfo != None)
		OPGRI = ONSPlusGameReplicationInfo(PlayerController(Pawn(Weapon.Owner).Controller).GameReplicationInfo);

	Start += Vector(Dir) * 10.0 * LinkGun(Weapon).Links;

	Proj = Weapon.Spawn(class'ONSPlusLinkProjectile',,, Start, Dir);

	if ( Proj != None )
	{
		Proj.Links = LinkGun(Weapon).Links;
		Proj.LockingPawns = ONSPlusLinkGun(Weapon).LockingPawns;

		if (OPGRI != None)
			Proj.bShareNodeDamage = OPGRI.bNodeHealScoreFix;

		Proj.LinkAdjust();
	}

	return Proj;
}

defaultproperties
{
	ProjectileClass=class'ONSPlusLinkProjectile'
}