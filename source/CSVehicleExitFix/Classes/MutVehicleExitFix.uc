class MutVehicleExitFix extends Mutator;

var config bool bEnabled;
var config float CrushSpawnProtection;

function bool CanLeaveVehicle(Vehicle V, Pawn P)
{
    if(bEnabled)
    {
        DoKDriverLeave(true, V, P);
        return false;
    }

    return true;
}

function bool DoKDriverLeave(bool bForceLeave, Vehicle V, Pawn P)
{
   	local Controller C;
	local PlayerController	PC;
	local bool havePlaced;

    if ((V.PlayerReplicationInfo != None) && (V.PlayerReplicationInfo.HasFlag != None) )
		V.Driver.HoldFlag(V.PlayerReplicationInfo.HasFlag);

	// Do nothing if we're not being driven
	if (V.Controller == None )
		return false;

	// Before we can exit, we need to find a place to put the driver.
	// Iterate over array of possible exit locations.

	if ( (V.Driver != None) && (!V.bRemoteControlled || V.bHideRemoteDriver) )
    {
	    V.Driver.bHardAttach = false;
	    V.Driver.bCollideWorld = true;
	    V.Driver.SetCollision(true, true);
	    havePlaced = V.PlaceExitingDriver();

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
    if(!havePlaced)
        P.SpawnTime = Level.TimeSeconds - DeathMatch(Level.Game).SpawnProtectionTime + CrushSpawnProtection;

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
	PlayInfo.AddSetting("VehicleExitFix", "bEnabled", "Enabled", 0, weight++, "Checkbox");
	PlayInfo.AddSetting("VehicleExitFix", "CrushSpawnProtection", "Spawn protection when self crushed", 0, weight++, "Text", "4;0.0:10");

    PlayInfo.PopClass();
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bEnabled":	            return "Exit Fix enabled";
		case "CrushSpawnProtection":	return "Spawn protection when self crushed";
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
    bAddToServerPackages=true
    FriendlyName="Vehicle Exit Fix (1.1)"
    Description="Force vehicle exit"
    bEnabled=true
    CrushSpawnProtection=0.50
}