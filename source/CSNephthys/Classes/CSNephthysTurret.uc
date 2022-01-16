class CSNephthysTurret extends NephthysTurret;

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile Proj;
	local int VortexLevel;

	bClientTrigger = False;
	ClientTrigger();

	VortexLevel = int(ArrayCount(NephthysGravityVortex(Proj).VortexEffectLevels) * (Level.TimeSeconds - StartHoldTime) / MaxHoldTime) - 1;

	if (VortexLevel < 0)
		Proj = Super.SpawnProjectile(ProjectileClass, False);
	else
		Proj = Super.SpawnProjectile(ProjClass, bAltFire);

	if (Proj != None)
	{
		if (CSNephthysGravityVortex(Proj) != None)
		{
			CSNephthysGravityVortex(Proj).SetVortexLevel(VortexLevel);
			CSNephthysGravityVortex(Proj).OwnerVehicle = CSNephthys(Owner);
		}

		Instigator.KAddImpulse(-Sqrt(Proj.Mass) * Proj.Velocity, Proj.Location);
	}

	return Proj;
}

defaultproperties
{
    AltFireProjectileClass=Class'CSNephthys.CSNephthysGravityVortex'
    RedSkin=Texture'CSNephthys.NephthysRed'
    BlueSkin=Texture'CSNephthys.NephthysBlue'
}