//=============================================================================
// RoboRifle
//=============================================================================
class RoboRifle extends Weapon
    config(user);

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax
#exec OBJ LOAD FILE=XEffectMat.utx



event bool AttemptFire(Controller C, bool bAltFire)
{

	if (bAltFire)
    {
		if ( Excalibur_Robot(instigator).ShockShield != None )
		{
			Excalibur_Robot(instigator).CurrentDelayTime = 0;

			if (!Excalibur_Robot(instigator).bShieldActive && Excalibur_Robot(instigator).CurrentShieldHealth > 0)
			{
				ActivateShield();
			}
		}
    }
	else if ( (AIController(C) != None) && Excalibur_Robot(instigator).bShieldActive && (VSize(C.Target.Location - Instigator.Location) > 900) )
	{
		DeactivateShield();
	}



	return False;
}

simulated function ActivateShield()
{
    Excalibur_Robot(instigator).ActivateShield();
}

simulated function DeactivateShield()
{
    Excalibur_Robot(instigator).DeactivateShield();
}



simulated function vector CenteredEffectStart()
{
    local Vector X,Y,Z;

    GetViewAxes(X, Y, Z);
    return (Instigator.Location +
        Instigator.CalcDrawOffset(self) +
        EffectOffset.X * X +
        EffectOffset.Z * Z);
}

simulated event RenderOverlays( Canvas Canvas )
{
    local int m;

    if ((Hand < -1.0) || (Hand > 1.0))
    {
		for (m = 0; m < NUM_FIRE_MODES; m++)
		{
			if (FireMode[m] != None)
			{
				FireMode[m].DrawMuzzleFlash(Canvas);
			}
		}
	}
    Super.RenderOverlays(Canvas);
}



function bool CanAttack(Actor Other)
{
	return true;
}





/* BestMode()
choose between regular or alt-fire
*/

function byte BestMode()
{
	local bot B;

	if ( Projectile(Instigator.Controller.Target) != None )
		return 1;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;




		// check if near friendly node, and between it and enemy
		if ( (B.Squad.SquadObjective != None) && (VSize(B.Pawn.Location - B.Squad.SquadObjective.Location) < 1000)
			&& ((Normal(B.Enemy.Location - B.Squad.SquadObjective.Location) dot Normal(B.Pawn.Location - B.Squad.SquadObjective.Location)) > 0.7) )
			return 1;

		// use shield if heavily damaged
		if ( B.Pawn.Health < 0.3 * B.Pawn.Default.Health )
			return 1;

		// use shield against heavy vehicles
		if ( (B.Enemy == B.Target) && (Vehicle(B.Enemy) != None) && Vehicle(B.Enemy).ImportantVehicle() && (B.Enemy.Controller != None)
			&& ((Vector(B.Enemy.Controller.Rotation) dot Normal(Instigator.Location - B.Enemy.Location)) > 0.9) )
			return 1;
	   return 0;

}






function float SuggestAttackStyle()
{
    return 0.8;
}

function float SuggestDefenseStyle()
{
    return -0.8;
}

simulated function float ChargeBar()
{
    return FClamp(Excalibur_Robot(instigator).CurrentShieldHealth/Excalibur_Robot(instigator).MaxShieldHealth, 0.0, 0.999);
}
// End AI interface

defaultproperties
{
     FireModeClass(0)=Class'CSAPVerIV.RoboBeamFire'
     FireModeClass(1)=Class'CSAPVerIV.RoboShieldFire'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     SelectSound=Sound'WeaponSounds.ShockRifle.SwitchToShockRifle'
     SelectForce="SwitchToShockRifle"
     AIRating=0.630000
     CurrentRating=0.630000
     bShowChargingBar=True
     EffectOffset=(X=200.000000,Y=30.000000,Z=32.000000)
     DisplayFOV=60.000000
     HudColor=(B=255,G=0,R=128)
     SmallViewOffset=(X=12.000000,Y=14.000000,Z=-6.000000)
     CenteredOffsetY=-5.000000
     CenteredYaw=-500
     InventoryGroup=4
     PickupClass=Class'XWeapons.ShockRiflePickup'
     PlayerViewOffset=(X=158.000000,Y=5.000000,Z=-45.000000)
     PlayerViewPivot=(Pitch=1000,Yaw=-800,Roll=-500)
     BobDamping=1.800000
     AttachmentClass=Class'CSAPVerIV.RoboRifleAttachment'
     IconMaterial=Texture'InterfaceContent.HUD.SkinA'
     IconCoords=(X1=322,Y1=190,X2=444,Y2=280)
     ItemName="RoboRifle"
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=200
     LightSaturation=70
     LightBrightness=150.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'Weapons.Painter_1st'
     DrawScale3D=(X=2.000000,Y=2.000000,Z=1.500000)
     UV2Texture=Shader'XGameShaders.WeaponShaders.WeaponEnvShader'
     bForceSkelUpdate=True
}
