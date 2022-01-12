class CSMarvinPortalWeapon extends ONSWeapon;

#exec AUDIO IMPORT File=Sounds\PortalShoot.wav 

var bool bForceMinimumGrowth;
var float DefaultPortalSize;

var bool bHoldingFire, bHoldingAltFire;

simulated function Destroyed()
{
    local CSMarvinPortalDecal pd;

    foreach DynamicActors(Class'CSMarvinPortalDecal', pd)
		if (pd.Owner == Self)
			pd.Destroy();

    super.Destroyed();
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        if(!bHoldingFire)
        {
            bHoldingFire = true;
        }
    }
    function CeaseFire(Controller C)
    {
        local CSMarvinProjectile MP;

        if(bHoldingAltFire)
        {
            CeaseAltFire(C);
            return;
        }
        if(!bHoldingFire)
            return;

        bHoldingFire = false;

        DualFireOffset=default.DualFireOffset*-1;
    	CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

        MP = CSMarvinProjectile(SpawnProjectile(ProjectileClass, False));
        if(MP != None)
        {
            MP.bForceMinimumGrowth = bForceMinimumGrowth;
            MP.DefaultPortalSize = DefaultPortalSize;
            MP.StartingPortalSize = DefaultPortalSize; 
        }
    }

    function AltFire(Controller C)
    {
        if(!bHoldingAltFire)
        {
            bHoldingAltFire = true;
        }
    }

    function CeaseAltFire(Controller C)
    {
        local CSMarvinProjectile MP;

        if(!bHoldingAltFire)
            return;

        bHoldingAltFire = false;

        DualFireOffset=default.DualFireOffset;
    	CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

        if (AltFireProjectileClass == None)
        {
            Fire(C);
        }
        else
        {
            MP = CSMarvinProjectile(SpawnProjectile(AltFireProjectileClass, True));
            if(MP != None)
            {
                MP.bForceMinimumGrowth = bForceMinimumGrowth;
                MP.DefaultPortalSize = DefaultPortalSize;
                MP.StartingPortalSize = DefaultPortalSize;
            }
        }
    }
}


defaultproperties
{
    Mesh=Mesh'ONSWeapons-A.PlasmaGun'
    YawBone=PlasmaGunBarrel
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchBone=PlasmaGunBarrel
    PitchUpLimit=18000
    PitchDownLimit=49153
    FireSoundClass=sound'CSMarvin.PortalShoot'
    AltFireSoundClass=sound'CSMarvin.PortalShoot'
    FireForce="Laser01"
    AltFireForce="Laser01"
    ProjectileClass=class'CSMarvinProjectileRed'
    FireInterval=0.5
    AltFireProjectileClass=class'CSMarvinProjectileBlue'
    AltFireInterval=0.5
    WeaponFireAttachmentBone=PlasmaGunAttachment
    WeaponFireOffset=0.0
    bAimable=True
    RotationsPerSecond=1.2
    DualFireOffset=44
    //MinAim=0.900
    //bDoOffsetTrace=true
    DefaultPortalSize=3.0
}