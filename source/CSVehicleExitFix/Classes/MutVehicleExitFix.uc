class MutVehicleExitFix extends Mutator;

var config bool bEnabled;

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
	    havePlaced = PlaceExitingDriver(V);

	    // If we could not find a place to put the driver, leave driver inside as before.
	    if (!havePlaced && !bForceLeave )
	    {
	        V.Driver.bHardAttach = true;
	        V.Driver.bCollideWorld = false;
	        V.Driver.SetCollision(false, false);
	        return false;
	    }
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

	//Level.Game.DriverLeftVehicle(self, Driver);

	// Car now has no driver
	V.Driver = None;

	V.DriverLeft();

	// Put brakes on before you get out :)
    V.Throttle	= 0;
    V.Steering	= 0;
	V.Rise		= 0;

    return true;
}

function bool PlaceExitingDriver(Vehicle V)
{
	local int		i, j;
	local vector	tryPlace, Extent, HitLocation, HitNormal, ZOffset, RandomSphereLoc;
	local float BestDir, NewDir;

	if ( V.Driver == None )
		return false;
	Extent = V.Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = V.Driver.default.CollisionHeight;
	ZOffset = V.Driver.default.CollisionHeight * vect(0,0,1);

	//avoid running driver over by placing in direction perpendicular to velocity
	if ( VSize(V.Velocity) > 100 )
	{
		tryPlace = Normal(V.Velocity cross vect(0,0,1)) * (V.CollisionRadius + V.Driver.default.CollisionRadius ) * 1.25 ;
		if ( (V.Controller != None) && (V.Controller.DirectionHint != vect(0,0,0)) )
		{
			if ( (tryPlace dot V.Controller.DirectionHint) < 0 )
				tryPlace *= -1;
		}
		else if ( FRand() < 0.5 )
				tryPlace *= -1; //randomly prefer other side
		if ( (Trace(HitLocation, HitNormal, V.Location + tryPlace + ZOffset, V.Location + ZOffset, false, Extent) == None && V.Driver.SetLocation(V.Location + tryPlace + ZOffset))
		     || (Trace(HitLocation, HitNormal, V.Location - tryPlace + ZOffset, V.Location + ZOffset, false, Extent) == None && V.Driver.SetLocation(V.Location - tryPlace + ZOffset)) )
			return true;
	}

	if ( (V.Controller != None) && (V.Controller.DirectionHint != vect(0,0,0)) )
	{
		// first try best position
		tryPlace = V.Location;
		BestDir = 0;
		for( i=0; i<V.ExitPositions.Length; i++)
		{
			NewDir = Normal(V.ExitPositions[i] - V.Location) Dot V.Controller.DirectionHint;
			if ( NewDir > BestDir )
			{
				BestDir = NewDir;
				tryPlace = V.ExitPositions[i];
			}
		}
		V.Controller.DirectionHint = vect(0,0,0);
		if ( tryPlace != V.Location )
		{
			if ( V.bRelativeExitPos )
			{
				if ( V.ExitPositions[0].Z != 0 )
					ZOffset = Vect(0,0,1) * V.ExitPositions[0].Z;
				else
					ZOffset = V.Driver.default.CollisionHeight * vect(0,0,2);

				tryPlace = V.Location + ( (tryPlace-ZOffset) >> V.Rotation) + ZOffset;

				// First, do a line check (stops us passing through things on exit).
				if ( (Trace(HitLocation, HitNormal, tryPlace, V.Location + ZOffset, false, Extent) == None)
					&& V.Driver.SetLocation(tryPlace) )
					return true;
			}
			else if ( V.Driver.SetLocation(tryPlace) )
				return true;
		}
	}

	if ( !V.bRelativeExitPos )
	{
		for( i=0; i<V.ExitPositions.Length; i++)
		{
			tryPlace = V.ExitPositions[i];

			if ( V.Driver.SetLocation(tryPlace) )
				return true;
			else
			{
				for (j=0; j<10; j++) // try random positions in a sphere...
				{
					RandomSphereLoc = VRand()*200* FMax(FRand(),0.5);
					RandomSphereLoc.Z = Extent.Z * FRand();

					// First, do a line check (stops us passing through things on exit).
					if ( Trace(HitLocation, HitNormal, tryPlace+RandomSphereLoc, tryPlace, false, Extent) == None )
					{
						if ( V.Driver.SetLocation(tryPlace+RandomSphereLoc) )
							return true;
					}
					else if ( V.Driver.SetLocation(HitLocation) )
						return true;
				}
			}
		}
		return false;
	}

	for( i=0; i<V.ExitPositions.Length; i++)
	{
		if ( V.ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * V.ExitPositions[0].Z;
		else
			ZOffset = V.Driver.default.CollisionHeight * vect(0,0,2);

		tryPlace = V.Location + ( (V.ExitPositions[i]-ZOffset) >> V.Rotation) + ZOffset;

		// First, do a line check (stops us passing through things on exit).
		if ( Trace(HitLocation, HitNormal, tryPlace, V.Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !V.Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}

	return false;
}


defaultproperties
{
    bAddToServerPackages=true
    FriendlyName="Vehicle Exit Fix (1.0)"
    Description="Force vehicle exit"
    bEnabled=true
}