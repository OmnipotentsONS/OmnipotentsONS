class EXFighterTransformRifle extends Weapon
    config(user);
#exec OBJ LOAD FILE=..\StaticMeshes\AS_Vehicles_SM.usx
var Rotator PrevRotation;
var float	LastTimeSeconds;


/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	if ( Instigator.Controller.Enemy == None )
		return 0;
	if ( GameObjective(Instigator.Controller.Focus) != None )
		return 0;

	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;
	if ( FRand() < 0.65 )
		return 1;
	return 0;
}
simulated final function float	CalcInertia(float DeltaTime, float FrictionFactor, float OldValue, float NewValue)
{
	local float	Friction;

	Friction = 1.f - FClamp( (0.02*FrictionFactor) ** DeltaTime, 0.f, 1.f);
	return	OldValue*Friction + NewValue;
}

simulated function PreDrawFPWeapon()
{
	local Rotator	DeltaRot, NewRot;
	local float		myDeltaTime;

	PlayerViewOffset = default.PlayerViewOffset;
	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(Self) );

	if ( PrevRotation == rot(0,0,0) )
		PrevRotation = Instigator.Rotation;

	myDeltaTime		= Level.TimeSeconds - LastTimeSeconds;
	LastTimeSeconds	= Level.TimeSeconds;
	DeltaRot		= Normalize(Instigator.Rotation - PrevRotation);
	NewRot.Yaw		= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Yaw, PrevRotation.Yaw);
	NewRot.Pitch	= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Pitch, PrevRotation.Pitch);
	NewRot.Roll		= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Roll, PrevRotation.Roll);
	PrevRotation	= NewRot;
	SetRotation( NewRot );
}

simulated function bool HasAmmo()
{
    return true;
}

function float SuggestAttackStyle()
{
    return 1.0;
}
//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'CSAPVerIV.WF_EXFighterTransformFire'
     FireModeClass(1)=Class'CSAPVerIV.WeaponFire_DummyFire'
     AIRating=0.680000
     CurrentRating=0.680000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=7
     SmallViewOffset=(X=30.000000,Z=-40.000000)
     InventoryGroup=7
     GroupOffset=1
     PlayerViewOffset=(X=30.000000,Z=-40.000000)
     AttachmentClass=Class'CSAPVerIV.WA_EXBotTransformAttach'
     ItemName="TransForm"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.Excalibur_ST.Ex_Cockpit'
     DrawScale3D=(Z=0.700000)
     AmbientGlow=100
}
