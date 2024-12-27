class MutVehicleExitFix extends Mutator;

var config bool bEnabled;
var config float CrushSpawnProtection;
var config bool bAlwaysGiveSpawnProtection;

var localized string lblEnabled, descEnabled;
var localized string lblCrushSpawnProtection, descCrushSpawnProtection;
var localized string lblAlwaysGiveSpawnProtection, descAlwaysGiveSpawnProtection;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientSetSpawnTime;
}

function bool CanLeaveVehicle(Vehicle V, Pawn P)
{
    // this is only to fix flyers and manta types
    if(bEnabled && (V.IsA('ONSHoverCraft') || V.IsA('ONSChopperCraft')))
    {
        DoKDriverLeave(true, V, P);
        return false;
    }

    return super.CanLeaveVehicle(V, P);
}

simulated function ClientSetSpawnTime(Pawn P, float spawnTime)
{
    P.SpawnTime = spawnTime;
}

function KDriverLeaveONS(ONSVehicle V, Controller C)
{
    local int x;
    if (C != None)
    {
        if (xPawn(C.Pawn) != None && C.Pawn.HasUDamage())
            for (x = 0; x < V.Weapons.length; x++)
                V.Weapons[x].SetOverlayMaterial(xPawn(C.Pawn).UDamageWeaponMaterial, 0, false);
        C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;
        V.Instigator = C.Pawn; //so if vehicle continues on and runs someone over, the appropriate credit is given
    }
    for (x = 0; x < V.Weapons.length; x++)
    {
        V.Weapons[x].FlashCount = 0;
        V.Weapons[x].NetUpdateFrequency = V.Weapons[x].default.NetUpdateFrequency;
    }
}

function GiveSpawnProtection(Pawn P)
{
    local float spawnTime;
    spawnTime = Level.TimeSeconds - DeathMatch(Level.Game).SpawnProtectionTime + CrushSpawnProtection;
    P.SpawnTime = spawnTime;
    ClientSetSpawnTime(P, spawnTime);
}

function bool DoKDriverLeave(bool bForceLeave, Vehicle V, Pawn P)
{
   	local Controller C;
	local PlayerController	PC;
	local bool havePlaced;
    local float spawnTime;

    // first check if we could leave, if we can then we are done
    if(V.KDriverLeave(bForceLeave))
        return true;    

    // the rest of this function is duplicating most of default KDriverLeave 
    if ((V.PlayerReplicationInfo != None) && (V.PlayerReplicationInfo.HasFlag != None) )
		V.Driver.HoldFlag(V.PlayerReplicationInfo.HasFlag);

	// Do nothing if we're not being driven
	if (V.Controller == None )
		return false;

    // ONSVehicle specific leave stuff
    if(ONSVehicle(V) != None)
    {
        KDriverLeaveONS(ONSVehicle(V), V.Controller);
    }

    // stop run over
    V.Instigator = P;

	// Before we can exit, we need to find a place to put the driver.
	// Iterate over array of possible exit locations.

	if ( (V.Driver != None) && (!V.bRemoteControlled || V.bHideRemoteDriver) )
    {
	    V.Driver.bHardAttach = false;
	    V.Driver.bCollideWorld = true;
	    V.Driver.SetCollision(true, true);
        if(ClassIsChildOf(V.Class, class'ONSAttackCraft'))
        {
            havePlaced = ONSAttackCraft(V).PlaceExitingDriver();
        }
        else if(ClassIsChildOf(V.Class, class'ONSWeaponPawn'))
        {
            havePlaced = ONSWeaponPawn(V).PlaceExitingDriver();
        }
        else
        {
            havePlaced = V.PlaceExitingDriver();
        }

	    // If we could not find a place to put the driver, leave driver inside as before.
	    if (!havePlaced && !bForceLeave )
	    {
	        V.Driver.bHardAttach = true;
	        V.Driver.bCollideWorld = false;
	        V.Driver.SetCollision(false, false);
	        return false;
	    }
	}

    //since we are forcing exit, give some spawn protection
    if(!havePlaced || bAlwaysGiveSpawnProtection)
    {
        spawnTime = Level.TimeSeconds - DeathMatch(Level.Game).SpawnProtectionTime + CrushSpawnProtection;
        P.SpawnTime = spawnTime;
        ClientSetSpawnTime(P, spawnTime);
    }

	V.bDriving = False;

	// Reconnect Controller to Driver.
	C = V.Controller;
	if (C.RouteGoal == self)
		C.RouteGoal = None;
	if (C.MoveTarget == self)
		C.MoveTarget = None;
	C.bVehicleTransition = true;
	V.Controller.UnPossess();

	if ( (V.Driver != None) && (V.Driver.Health > 0) )
	{
		V.Driver.SetOwner( C );
		C.Possess( V.Driver );

		PC = PlayerController(C);
		if ( PC != None )
			PC.ClientSetViewTarget( V.Driver ); // Set playercontroller to view the person that got out

		V.Driver.StopDriving( V );
	}
	C.bVehicleTransition = false;

	if ( C == V.Controller )	// If controller didn't change, clear it...
		V.Controller = None;

	Level.Game.DriverLeftVehicle(V, V.Driver);

	// Car now has no driver
	V.Driver = None;

	V.DriverLeft();

	// Put brakes on before you get out :)
    V.Throttle	= 0;
    V.Steering	= 0;
	V.Rise		= 0;

    return true;
}

function PostBeginPlay()
{
	local NoDamageFromForceExitRules G;

	Super.PostBeginPlay();
	G = spawn(class'NoDamageFromForceExitRules');

	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else
		Level.Game.GameRulesModifiers.AddGameRules(G);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    local int weight;
	Super.FillPlayInfo(PlayInfo);

    weight=1;
    PlayInfo.AddClass(default.Class);
	PlayInfo.AddSetting(default.FriendlyName, "bEnabled", default.lblEnabled, 0, weight++, "Check");
	PlayInfo.AddSetting(default.FriendlyName, "CrushSpawnProtection", default.lblCrushSpawnProtection, 0, weight++, "Text", "4;0.0:10");
	PlayInfo.AddSetting(default.FriendlyName, "bAlwaysGiveSpawnProtection", default.lblAlwaysGiveSpawnProtection, 0, weight++, "Check");
    PlayInfo.PopClass();
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bEnabled":	            return default.descEnabled;
		case "CrushSpawnProtection":	return default.descCrushSpawnProtection;
		case "bAlwaysGiveSpawnProtection":	return default.descAlwaysGiveSpawnProtection;
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
    bAddToServerPackages=true
    FriendlyName="Vehicle Exit Fix (1.3)"
    Description="Force vehicle exit"
    bEnabled=true
    bAlwaysGiveSpawnProtection=true
    CrushSpawnProtection=0.75

    lblCrushSpawnProtection="Crush Spawn Protection"
    descCrushSpawnProtection="Spawn protection when self crushed"
    lblEnabled="Enabled"
    descEnabled="Enabled"
    lblAlwaysGiveSpawnProtection="Always give spawn protection on exit"
    descAlwaysGiveSpawnProtection="Give spawn protection on exit"
}