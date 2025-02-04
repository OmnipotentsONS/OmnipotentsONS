class CSMarvinProjectileBlue extends CSMarvinProjectile;

simulated function HitWall(vector HitNormal, Actor Wall)
{
	local CSMarvinPortalDecal pd;

	Super.HitWall(HitNormal, Wall);
	// Spawn the 'portal decal'
	//if (Role == ROLE_Authority)
	if (Level.Netmode != NM_Client && Pawn(Wall) == None)
	{
		// hack
		Class'CSMarvinPortalDecal'.default.FireMode = 0;
		Class'CSMarvinPortalDecal'.default.DefaultDrawScale = DefaultPortalSize;
		//Class'CSMarvinPortalDecal'.default.StartingDrawScale = StartingPortalSize;
		Class'CSMarvinPortalDecal'.default.StartingGrowthEnergy = StartingPortalSize;

		//pd = Spawn(Class'CSMarvinPortalDecal', InstigatorController,, Location + (HitNormal * PortalDistance), Rotator(HitNormal));
		pd = Spawn(Class'CSMarvinPortalDecal', Owner,, Location + (HitNormal * PortalDistance), Rotator(HitNormal));

		// further hacking to trick netcode
		Class'CSMarvinPortalDecal'.default.FireMode = -1;
		Class'CSMarvinPortalDecal'.default.DefaultDrawScale = -1;
		//Class'CSMarvinPortalDecal'.default.StartingDrawScale = -1;
		Class'CSMarvinPortalDecal'.default.StartingGrowthEnergy = -1;

        if(pd != None)
        {
            pd.Instigator = Instigator;
            pd.bForceMinimumGrowth = bForceMinimumGrowth;
            pd.SetBase(Wall);
        }
	}

}
defaultproperties
{
    ProjectileEffectClass=class'CSMarvinProjEmitterBlue'
    ProjectileImpactEffectClass=class'CSMarvinProjImpactEmitterBlue'
}