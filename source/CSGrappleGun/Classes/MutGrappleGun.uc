class MutGrappleGun extends Mutator;

var WeaponLocker.WeaponEntry LockerEntry;

var config bool bInfiniteAmmo;
var config bool bEnabled;
var localized string InfiniteAmmoText, EnabledText;


static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup, "bInfiniteAmmo", default.InfiniteAmmoText, 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bEnabled", default.EnabledText, 0, 1, "Check");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bInfiniteAmmo":	return default.InfiniteAmmoText;
		case "bEnabled":		return default.EnabledText;
	}

	return Super.GetDescriptionText(PropName);
}

simulated function PreBeginPlay()
{
    super.PreBeginPlay();

    if(bInfiniteAmmo)
    {
        class'GrappleGunFire'.default.AmmoPerFire=0;
        class'GrappleGunAmmo'.default.MaxAmmo=1;
        class'GrappleGunAmmo'.default.PickupAmmo=1;
        class'GrappleGunAmmo'.default.InitialAmount=1;
        class'GrappleGunAmmo'.default.AmmoAmount=1;
    }
}

function ModifyPlayer(Pawn Other)
{
    if(bEnabled && Other!=None)
        Other.GiveWeapon("CSGrappleGun.GrappleGun");

    super.ModifyPlayer(Other);
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local WeaponLocker L;
    L = WeaponLocker(Other);
    if(L != None)
        L.Weapons[L.Weapons.Length] = LockerEntry;

    bSuperRelevant=0;
    return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Grapple Guns"
     Description="Players spawn with a Grapple gun"
     LockerEntry=(WeaponClass=class'GrappleGun',ExtraAmmo=0)

     InfiniteAmmoText="Infinite ammo for grapple gun"
     EnabledText="Give grapple guns to players"
     bInfiniteAmmo=false
     bEnabled=true     
}
