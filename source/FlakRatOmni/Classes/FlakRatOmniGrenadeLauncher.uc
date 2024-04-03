class FlakRatOmniGrenadeLauncher extends ONSWeapon;



var array<ONSGrenadeProjectile> Grenades;
var int CurrentGrenades; //should be sync'ed with Grenades.length
var int MaxGrenades;
var color FadedColor;

replication
{
    reliable if (bNetOwner && bNetDirty && ROLE == ROLE_Authority)
        CurrentGrenades;
}


simulated function PostBeginPlay()
{
    super.PostBeginPlay();
}

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}

simulated function NewDrawWeaponInfo(Canvas Canvas, float YPos)
{
	    local int i, Half;
    local float ScaleFactor;

    ScaleFactor = 99 * Canvas.ClipX/3200;
    Half = (MaxGrenades + 1) / 2;
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = class'HUD'.Default.WhiteColor;
    for (i = 0; i < Half; i++)
    {
        if (i >= CurrentGrenades)
            Canvas.DrawColor = FadedColor;
        Canvas.SetPos(Canvas.ClipX - (i+1) * ScaleFactor * 1.25, YPos);
        Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 324, 325, 54, 54);
    }
    for (i = Half; i < MaxGrenades; i++)
    {
        if (i >= CurrentGrenades)
            Canvas.DrawColor = FadedColor;
        Canvas.SetPos(Canvas.ClipX - (i-Half+1) * ScaleFactor * 1.25, YPos - ScaleFactor);
        Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 324, 325, 54, 54);
    }
}


simulated function Destroyed()
{
    local int x;

    if (Role == ROLE_Authority)
    {
        for (x = 0; x < Grenades.Length; x++)
            if (Grenades[x] != None)
                Grenades[x].Explode(Grenades[x].Location, vect(0,0,1));
        Grenades.Length = 0;
    }

    Super.Destroyed();
}


function byte BestMode()
{
	local int x;

	if (CurrentGrenades >= MaxGrenades)
		return 1;

	for (x = 0; x < Grenades.length; x++)
		if (Grenades[x] != None && Pawn(Grenades[x].Base) != None)
			return 1;

	return 0;
}


event bool AttemptFire(Controller C, bool bAltFire)
{
    if(!bAltFire && CurrentGrenades >= MaxGrenades)
        return false;
    
    return super.AttemptFire(C, bAltFire);
}

/*
simulated function bool AllowFire()
{
    return (CurrentGrenades < MaxGrenades);
}
*/

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        local ONSGrenadeProjectile P;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

        P = ONSGrenadeProjectile(SpawnProjectile(ProjectileClass, false));
        if(P != None)
        {
            P.SetOwner(Self);
            Grenades[Grenades.length] = P;
            CurrentGrenades++;
        }

    }

    function AltFire(Controller C)
    {
        local int x;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

        for (x = 0; x < Grenades.Length; x++)
            if (Grenades[x] != None)
                Grenades[x].Explode(Grenades[x].Location, vect(0,0,1));

        Grenades.length = 0;
        CurrentGrenades = 0;
    }
}

defaultproperties
{
	   MaxGrenades=12
     CurrentGrenades=0
     YawBone="MortarBase"
     PitchBone="MortarElevation"
     PitchUpLimit=15000
     WeaponFireAttachmentBone="MortarFire"
     GunnerAttachmentBone="MortarGunner"
     bDoOffsetTrace=True
     FireInterval=0.60000
     
     FireSoundClass=SoundGroup'WeaponSounds.FlakCannon.FlakCannonFire'
     AltFireSoundClass=SoundGroup'WeaponSounds.FlakCannon.FlakCannonAltFire'
     FireForce="FlakCannonFire"
     //AltFireForce="FlakCannonAltFire"
     ProjectileClass=Class'Onslaught.ONSGrenadeProjectile'
          //AltFireProjectileClass=Class'FlakRatOmni.FlakRatOmniShell'
     // Altfire to detonate
     AIInfo(0)=(bLeadTarget=True,aimerror=200.000000,RefireRate=1.500000)
     AIInfo(1)=(bTrySplash=True,bLeadTarget=True,aimerror=200.000000,RefireRate=2.000000)
     Mesh=SkeletalMesh'ONSFlakRat.FlakMortar'
     FadedColor=(B=128,G=128,R=128,A=128)
}
