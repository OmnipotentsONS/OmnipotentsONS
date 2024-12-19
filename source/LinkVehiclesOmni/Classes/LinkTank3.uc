//  Link Tank 3.0 updated by pOOty
// ============================================================================
// Link Tank 2.0
// Complete recode of original Link Tank
// By [OMNI]Kamek
// ============================================================================

class LinkTank3 extends ONSHoverTank;

// Green -- Combiner'UT2004Weapons.Shaders.Combiner12'
// Blue -- Combiner'UT2004Weapons.Shaders.Combiner15'
// Red -- Combiner'UT2004Weapons.RedLink.Combiner12'
// Gold -- Combiner'UT2004Weapons.Shaders.Combiner17'

#exec OBJ LOAD FILE=AS_Vehicles_TX.utx
#exec OBJ LOAD FILE=LinkTank3Tex.utx

// ============================================================================
// Structs
// ============================================================================
struct LinkerStruct {
	var Controller LinkingController;
	var int NumLinks;
	var float LastLinkTime;
};

// ============================================================================
// Consts
// ============================================================================
const LINK_DECAY_TIME = 0.250000;			// Time to remove a linker from the linker list
const AI_HEAL_SEARCH = 4096.000000;			// Radius for bots to search for damaged actors while driving

// ============================================================================
// Properties
// ============================================================================

// 0 = Red, 1 = Blue
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;

// ============================================================================
// Internal vars
// ============================================================================

var array<LinkerStruct> Linkers;			// For keeping track of links
var int Links;
var bool bLinking;							// True if we're linking a vehicle/node/player
var bool bBotHealing;
var bool bBeaming;							// True if utilizing alt-fire

var LinkAttachment.ELinkColor OldLinkColor;

var LinkBeamEffect Beam;

replication
{
    unreliable if (Role == ROLE_Authority && bNetDirty)
        Links, bLinking, Beam, bBeaming;
}

// ============================================================================
// ============================================================================
simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	local int i;

	// Don't waste cycles continually switching out for the same skin
	if (Color != OldLinkColor)
	{
		switch ( Color )
		{
			case LC_Gold	:	Skins[0] = LinkSkin_Gold[Team];		break;
			case LC_Green	:	Skins[0] = LinkSkin_Green[Team];	break;
			case LC_Red		: 	Skins[0] = LinkSkin_Red[Team];		break;
			case LC_Blue	: 	Skins[0] = LinkSkin_Blue[Team];		break;
		}
		OldLinkColor = Color;
	}

	// Update weapon colors too
	for (i = 0; i < Weapons.Length; i++)
		if (LinkTank3Gun(Weapons[i]) != None)
			LinkTank3Gun(Weapons[i]).UpdateLinkColor(Color);
}

// ============================================================================
// HealDamage
// When someone links the tank, record it and add it to the Linkers
// After a certain time period passes, remove that linker if they aren't linking anymore
// ============================================================================
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int i;
	local bool bFound;
	
	if (Healer == None || Healer.bDeleteMe)
		return false;

	// If allied teammate, possibly add them to a link list
	if (TeamLink(Healer.GetTeamNum()))
	{
		for (i = 0; i < Linkers.Length; i++)
		{
			if (Linkers[i].LinkingController != None && Linkers[i].LinkingController == Healer)
			{
				bFound = true;
				Linkers[i].LastLinkTime = Level.TimeSeconds;
				// If other players are linking that pawn, record it
				if ( (Linkers[i].LinkingController.Pawn != None) && (Linkers[i].LinkingController.Pawn.Weapon != None) && (LinkGun(Linkers[i].LinkingController.Pawn.Weapon) != None) )
					Linkers[i].NumLinks = LinkGun(Linkers[i].LinkingController.Pawn.Weapon).Links;
				else
					Linkers[i].NumLinks = 0;
			}
		}
		if (!bFound)
		{
			Linkers.Insert(0,1);
			Linkers[0].LinkingController = Healer;
			Linkers[0].LastLinkTime = Level.TimeSeconds;
			// If other players are linking that pawn, record it
			if ( (Linkers[i].LinkingController.Pawn != None) && (Linkers[i].LinkingController.Pawn.Weapon != None) && (LinkGun(Linkers[i].LinkingController.Pawn.Weapon) != None) )
				Linkers[0].NumLinks = LinkGun(Linkers[0].LinkingController.Pawn.Weapon).Links;
			else
				Linkers[0].NumLinks = 0;
		}
	}

	return super.HealDamage(Amount, Healer, DamageType);
}

// ============================================================================
// GetLinks
// Returns number of linkers
// ============================================================================
function int GetLinks()
{
	return Links;
}

// ============================================================================
// ResetLinks
// Reset our linkers, called if Links < 0 or during tick
// ============================================================================
function ResetLinks()
{
	local int i;
	local int NewLinks;

	i = 0;
	NewLinks = 0;
	while (i < Linkers.Length)
	{
		// Remove linkers when their controllers are deleted
		// Or remove if LINK_DECAY_TIME seconds pass since they last linked the tank
		if (Linkers[i].LinkingController == None || Level.TimeSeconds - Linkers[i].LastLinkTime > LINK_DECAY_TIME)
			Linkers.Remove(i,1);
		else
		{
			NewLinks += 1 + Linkers[i].NumLinks;
			i++;
		}
	}

	if (Links != NewLinks)
		Links = NewLinks;
}


// ============================================================================
// Tick
// Remove linkers from the linker list after they stop linking
// ============================================================================
simulated event Tick(float DT)
{
    local float EnginePitch;
	local float LinTurnSpeed;
    local KRigidBodyState BodyState;
    local KarmaParams KP;
    local bool bOnGround;
    local int i;

//	Super.Tick(DT);


	// c/p from HoverTank -- all we care about is not wildly varying the ambientsound of the beam
    KGetRigidBodyState(BodyState);

	KP = KarmaParams(KParams);

	// Increase max karma speed if falling
	bOnGround = false;
	for(i=0; i<KP.Repulsors.Length; i++)
	{
        //log("Checking Repulsor "$i);
		if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
			bOnGround = true;
		//log("bOnGround: "$bOnGround);
	}

	if (bOnGround)
	   KP.kMaxSpeed = MaxGroundSpeed;
	else
	   KP.kMaxSpeed = MaxAirSpeed;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		LinTurnSpeed = 0.5 * BodyState.AngVel.Z;
		if (!bBeaming)
		{
			EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
			SoundPitch = FClamp(EnginePitch, 64, 128);
		}
		else
			SoundPitch = 64.0;

		if ( LeftTreadPanner != None )
		{
			LeftTreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
			if (Velocity Dot Vector(Rotation) > 0)
				LeftTreadPanner.PanRate = -1 * LeftTreadPanner.PanRate;
			LeftTreadPanner.PanRate += LinTurnSpeed;
		}

		if ( RightTreadPanner != None )
		{
			RightTreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
			if (Velocity Dot Vector(Rotation) > 0)
				RightTreadPanner.PanRate = -1 * RightTreadPanner.PanRate;
			RightTreadPanner.PanRate -= LinTurnSpeed;
		}
	}

    Super(ONSTreadCraft).Tick( DT );

	if (bBotHealing)
		AltFire();

	if (Role == ROLE_Authority)
		ResetLinks();
	//else
	//	log(Level.TimeSeconds@Self@"Beam Effect:"@Beam,'KDebug');

	//log(self@"tick links"@links,'KDebug');

	//log(Level.TimeSeconds@Self@"TICK -- Linking"@bLinking,'KDebug');
	// When linked, always show gold link panels
	if (Links > 0)
		UpdateLinkColor(LC_Gold);
	// If linking a vehicle/player/node, show team-colored link panels
	else if (bLinking && Team == 0)
		UpdateLinkColor(LC_Red);
	else if (bLinking && Team == 1)
		UpdateLinkColor(LC_Blue);
	// Show regular green link panels
	else
		UpdateLinkColor(LC_Green);
}

// ============================================================================
// Bot timers. Let's have the bots do something useful with this awesome vehicle
// ============================================================================
/*
function KDriverEnter(Pawn p)
{
	Super.KDriverEnter(p);
	//if (P.Controller.IsA('Bot'))
		SetTimer(1.00, true);
}
function bool KDriverLeave(bool bForceLeave)
{
	if (Super.KDriverLeave(bForceLeave))
	{
		SetTimer(0,false);
		bBotHealing = false;
		return true;
	}
	else
		return false;
}
event Timer()
{
	local Actor A;
	local Vehicle V;
	local ONSPowerCore Node;
	local Bot B;
	local bool bHealThis;

	if (Driver == None || Driver.Controller == None || Bot(Driver.Controller) == None)
	{
		SetTimer(0,false);
		bBotHealing = false;
		return;
	}

	B = Bot(Driver.Controller);
	// Don't heal if enemy is in range
	if (B.Enemy != None && B.EnemyVisible())
	{
		bBotHealing = false;
		return;
	}

	foreach VisibleCollidingActors(class'Actor',A,AI_HEAL_SEARCH)
	{
		// Look for vehicles and PowerNodes
		if ((Vehicle(A) != None || ONSPowerCore(A) != None) && FastTrace(A.Location,Location))
		{
			if (Vehicle(A) != None)
			{
				V = Vehicle(A);
				if (V.TeamLink(Team) && V.Health < V.HealthMax / 2 && V.Health > 0)
					bHealThis = true;
			}
			else if (ONSPowerCore(A) != None)
			{
				Node = ONSPowerCore(A);
				if (Node.CoreStage != 4 && Node.CoreStage != 1 && Node.Health > 0 && Node.Health < Node.DamageCapacity / 2)
					B.Focus = A;
			}
		}
		if (bHealThis)
			break;
	}

	if (bHealThis)
	{
		log(self@"healing actor"@A);
		bBotHealing = true;
		B.Focus = A;
		B.DoRangedAttackOn(A);
		AltFire();
	}
	else
		bBotHealing = false;
}
*/

// Don't allow primary fire if beaming
function Fire(optional float F)
{
	if (!bBeaming)
		Super.Fire(F);
}

// ============================================================================
// C/P'd Ion Tank stuff
// ============================================================================
function AltFire(optional float F)
{
	super(ONSVehicle).AltFire( F );
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	super(ONSVehicle).ClientVehicleCeaseFire( bWasAltFire );
}

simulated function SetupTreads()
{
    LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    LeftTreadPanner.Material = Skins[1];
 	RightTreadPanner.Material = Skins[2];
 	LeftTreadPanner.PanRate = 0;
 	RightTreadPanner.PanRate = 0;
 	//LeftTreadPanner.PanDirection = rot(0, 16384, 0);
 	//RightTreadPanner.PanDirection = rot(0, 16384, 0);
 	Skins[1] = LeftTreadPanner;
 	Skins[2] = RightTreadPanner;
}

/*
state VehicleDestroyed
{
    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
    {
    }

Begin:
    DestroyAppearance();
    VehicleExplosion(vect(0,0,1), 1.0);
    sleep(3.0);
    Destroy();
}
*/

simulated function DrawHUD(Canvas C)
{
	local PlayerController PC;
	local HudCTeamDeathMatch PlayerHud;

	//Hax. :P
    Super.DrawHUD(C);
	PC = PlayerController(Controller);
	if (Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard)
		return;
		
	PlayerHud=HudCTeamDeathMatch(PC.MyHud);
	
	if ( Links > 0 )
	{
		PlayerHud.totalLinks.value = Links;
		PlayerHud.DrawSpriteWidget (C, PlayerHud.LinkIcon);
		PlayerHud.DrawNumericWidget (C, PlayerHud.totalLinks, PlayerHud.DigitsBigPulse);
		PlayerHud.totalLinks.value = Links;
	}
}




static function StaticPrecache(LevelInfo L)
{
    super(ONSTreadCraft).StaticPrecache(L);

	L.AddPrecacheMaterial(Material'LinkTank3Tex.LinkTankTex.LinkTankBodyBlue');
	L.AddPrecacheMaterial(Material'LinkTank3Tex.LinkTankTex.LinkTankTread');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerGreen');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerRed');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerBlue');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerYellow');
	L.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin1');
	L.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin2');

	// FX
}

simulated function UpdatePrecacheStaticMeshes()
{
//	Level.AddPrecacheStaticMesh( StaticMesh'AW-2004Particles.Weapons.PlasmaSphere' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'LinkTank3Tex.LinkTankTex.LinkTankBodyBlue');
	Level.AddPrecacheMaterial(Material'LinkTank3Tex.LinkTankTex.LinkTankTread');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerGreen');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerRed');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerBlue');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerYellow');
	Level.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin1');
	Level.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin2');

	// FX

	super(ONSTreadCraft).UpdatePrecacheMaterials();
}

function bool RecommendLongRangedAttack()
{
	return true;
}

// ============================================================================

defaultproperties
{
     LinkSkin_Gold(0)=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyRed-DoubleLink'
     LinkSkin_Gold(1)=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyBlue-DoubleLink'
     LinkSkin_Green(0)=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyRed-Idle'
     LinkSkin_Green(1)=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyBlue-Idle'
     LinkSkin_Red(0)=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyRed-Linking'
     LinkSkin_Blue(1)=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyBlue-Linking'
     MaxSteerTorque=160.000000
     DriverWeapons(0)=(WeaponClass=Class'LinkVehiclesOmni.LinkTank3Gun')
     PassengerWeapons(0)=(WeaponPawnClass=Class'LinkVehiclesOmni.LinkTank3SecondaryTurretPawn',WeaponBone="SecondaryTurretAttach")
     PassengerWeapons(1)=(WeaponPawnClass=Class'LinkVehiclesOmni.LinkTank3TertiaryTurretPawn',WeaponBone="TertiaryTurretAttach")
     bHasAltFire=True
     RedSkin=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyRed-Idle'
     BlueSkin=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyBlue-Idle'
     DestroyedVehicleMesh=None
     DestructionEffectClass=Class'UT2k4Assault.FX_SpaceFighter_Explosion_Directional'
     DisintegrationEffectClass=None
     DisintegrationHealth=0.000000
     FPCamPos=(X=-80.000000,Z=250.000000)
     FPCamViewOffset=(X=25.000000)
     //TPCamLookat=(X=-50.000000,Z=0.000000)
     //TPCamWorldOffset=(Z=250.000000)
     TPCamLookat=(X=50.000000,Z=0.000000)
     TPCamWorldOffset=(Z=300.000000)
     
     VehiclePositionString="in a Link Tank"
     VehicleNameString=" Link Tank 3.42"
     RanOverDamageType=Class'LinkVehiclesOmni.DamTypeLinkTank3Roadkill'
     CrushedDamageType=Class'LinkVehiclesOmni.DamTypeLinkTank3Pancake'
     HealthMax=1150.00000
     Health=900
     Mesh=SkeletalMesh'ONSToys1Mesh.LinkTankChassis'
     Skins(0)=Combiner'LinkTank3Tex.LinkTankTex.LinkTankBodyRed-Idle'
     Skins(1)=Texture'LinkTank3Tex.LinkTankTex.LinkTankTread'
     Skins(2)=Texture'LinkTank3Tex.LinkTankTex.LinkTankTread'
     MaxGroundSpeed=875.000000
		HoverCheckDist=67 // raise it just bit to avoid snags      
		Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         KMaxSpeed=875.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.40000
     End Object
     KParams=KarmaParamsRBFull'LinkVehiclesOmni.LinkTank3.KParams0'

}
