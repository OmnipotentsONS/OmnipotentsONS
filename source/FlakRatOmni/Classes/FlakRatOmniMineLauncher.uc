class FlakRatOmniMineLauncher extends ONSWeapon;



var array<ONSMineProjectile> Mines;
var int CurrentMines; //should be sync'ed with Mines.length
var int MaxMines;
var color FadedColor;
var class<Projectile> RedMineClass;
var class<Projectile> BlueMineClass;
replication
{
    reliable if (bNetOwner && bNetDirty && ROLE == ROLE_Authority)
        CurrentMines;
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
    Half = (MaxMines + 1) / 2;
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor = class'HUD'.Default.WhiteColor;
    for (i = 0; i < Half; i++)
    {
        if (i >= CurrentMines)
            Canvas.DrawColor = FadedColor;
        Canvas.SetPos(Canvas.ClipX - (i+1) * ScaleFactor * 1.25, YPos);
        Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 391, 383, 44, 49);
    }
    for (i = Half; i < MaxMines; i++)
    {
        if (i >= CurrentMines)
            Canvas.DrawColor = FadedColor;
        Canvas.SetPos(Canvas.ClipX - (i-Half+1) * ScaleFactor * 1.25, YPos - ScaleFactor);
        Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 391, 383, 44, 49);
    }
}


simulated function Destroyed()
{
    local int x;

    if (Role == ROLE_Authority)
    {
        for (x = 0; x < Mines.Length; x++)
            if (Mines[x] != None)
                Mines[x].Explode(Mines[x].Location, vect(0,0,1));
        Mines.Length = 0;
    }

    Super.Destroyed();
}


function byte BestMode()
{
	local int x;

	if (CurrentMines >= MaxMines)
		return 1;

	for (x = 0; x < Mines.length; x++)
		if (Mines[x] != None && Pawn(Mines[x].Base) != None)
			return 1;

	return 0;
}


event bool AttemptFire(Controller C, bool bAltFire)
{
    if(!bAltFire && CurrentMines >= MaxMines)
        return false;
    
    return super.AttemptFire(C, bAltFire);
}


state ProjectileFireMode
{
    function Fire(Controller C)
    {
        local ONSMineProjectile P;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

	     if (Instigator.GetTeamNum() == 0)
	        ProjectileClass = RedMineClass;

   	    if (Instigator.GetTeamNum() == 1)
	        ProjectileClass = BlueMineClass;

        P = ONSMineProjectile(SpawnProjectile(ProjectileClass, false));
        if(P != None)
        {
            P.SetOwner(Self);
            Mines[Mines.length] = P;
            CurrentMines++;
        }
        //TODO remove mine if they keep adding its in Source
    }

    function AltFire(Controller C)
    {
    	  //TODO  Make the Mines scurry.
        local int x;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

        for (x = 0; x < Mines.Length; x++)
            if (Mines[x] != None)
                Mines[x].Explode(Mines[x].Location, vect(0,0,1));

        Mines.length = 0;
        CurrentMines = 0;
    }
}

defaultproperties
{
	   MaxMines=12
     CurrentMines=0
     YawBone="MortarBase"
     PitchBone="MortarElevation"
     PitchUpLimit=15000
     WeaponFireAttachmentBone="MortarFire"
     GunnerAttachmentBone="MortarGunner"
     bDoOffsetTrace=True
     FireInterval=0.60000
     RedMineClass=Class'Onslaught.ONSMineProjectileRED'
     BlueMineClass=Class'Onslaught.ONSMineProjectileBLUE'
    // FireSoundClass=SoundGroup'ONSVehicleSounds-S.SpiderMines.SpiderMineFire01'
     FireSoundClass=SoundGroup'WeaponSounds.FlakCannon.FlakCannonFire'
     //AltFireSoundClass=SoundGroup'WeaponSounds.FlakCannon.FlakCannonAltFire'
     FireForce="FlakCannonFire"
     //AltFireForce="FlakCannonAltFire"
     ProjectileClass=Class'Onslaught.ONSMineProjectile'
     // Altfire to direct
     AIInfo(0)=(bLeadTarget=True,aimerror=200.000000,RefireRate=1.500000)
     AIInfo(1)=(bTrySplash=True,bLeadTarget=True,aimerror=200.000000,RefireRate=2.000000)
     Mesh=SkeletalMesh'ONSFlakRat.FlakMortar'
     FadedColor=(B=128,G=128,R=128,A=128)
}
