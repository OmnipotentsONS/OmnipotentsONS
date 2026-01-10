//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DropShipKarma extends ONSChopperCraft
    placeable;

#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var()   float							MaxPitchSpeed;

var()   array<vector>					TrailEffectPositions;
var     class<ONSAttackCraftExhaust>	TrailEffectClass;
var     array<ONSAttackCraftExhaust>	TrailEffects;
var bool bDoorOpen;
var()	vector					DustOffset;
var()	float					DustTraceDistance;
var pawn PassA,
         PassB,
         PassC,
         PassD,
         PassE,
         PassF,
         PassG,
         PassH;

var FX_DropShipEngine  RightEngine,RightEngineB,LeftEngine,LeftEngineB;
var FX_DropShipEngine  RREngineA,RREngineB,LREngineA,LREngineB;
var FX_DropShipEngine  LSideEngineA,LSideEngineB,LSideEngineC,RSideEngineA,RSideEngineB,RSideEngineC;
var bool bHoverThrustersOn;
var Proj_FighterChaff Decoy;
var() config int NumChaff;
var() config bool bVehicleCarry; //Dropship spawns a Vehicle to carry
var     class<Emitter>  RedBuildEffectClass, BlueBuildEffectClass;
var     Emitter         MagEffect;
var Vector VehicleAttachOffset;
var()float VehicleAttachTraceDistance;
var bool bAttached, bOldAttached;
var ONSVehicle NewAttachVehicle;
var bool bNewAttachVehicleNeverReset;
var bool bNewAttachVehicleKeyVehicle;
//var ONSVehicle ClientVehicle;
var array<FX_RunningLight> RunningLights;
var()array<vector>				RunningLightOffsets;
var ONSVehicle spawnVehicle;
var bool bEnhancedHud;
var float EnhancedHudRange;
var array<Pawn> passengers;

replication
{
    reliable if( Role==ROLE_Authority )
       bAttached,NewAttachVehicle,ClientAttachVehicle,ClientEjectVehicle,bEnhancedHud,EnhancedHudRange;
        
    reliable if(Role==ROLE_Authority)
        NumChaff,PassA,PassB,PassC,PassD,PassE,PassF,PassG,PassH;

    reliable if( Role<ROLE_Authority )
        MagEffect;

}

simulated function PostNetBeginPlay()
{
    PlayAnim('DoorOpen');
    bDoorOpen=true;
    Super.PostNetBeginPlay();
}
// AI hint
function bool FastVehicle()
{
	return true;
}

function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);
    if(Driver != None)
        Driver.CreateInventory("CSAPVerIV.edo_ChuteInv");
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if ( FRand() < 0.7 )
	{
		VehicleMovingTime = Level.TimeSeconds + 1;
		Rise = 1;
	}
	return false;
}

simulated function DrawHUD(Canvas Canvas)
{
   local PlayerController	PC;
   super.DrawHUD(Canvas);
	// Don't draw if player is dead...
	if ( Health < 1 || Controller == None || PlayerController(Controller) == None )
		return;

	PC = PlayerController(Controller);
    if(bEnhancedHud)
        DrawVehicleHUD( Canvas, PC );
}

simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
    local vehicle	V;
    local XPawn	P;
	local vector	ScreenPos;
	local string	VehicleInfoString;
	local string	FriendInfoString;
    C.Style		= ERenderStyle.STY_Alpha;

    // Draw Weird cam
    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 255;
    C.DrawColor.A = 64;
    C.SetPos(0,0);
    C.DrawColor	= class'HUD_Assault'.static.GetTeamColor( Team );

    // Draw Reticle around visible vehicles
    foreach DynamicActors(class'Vehicle', V )
    {
        if ((V==Self) || (V.Health < 1) || V.bDeleteMe || V.GetTeamNum() == Team || V.bDriving==false || !V.IndependentVehicle())
                continue;
        if (V.IsA('Reaper') && Reaper(V).bStealth==True)
                continue;

        if ( !class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, V, ScreenPos, Location, Rotation ) )
            continue;

        if ( !FastTrace( V.Location, Location ) )
            continue;
        
        if(VSize(Location-V.Location) > EnhancedHudRange)
            continue;

        C.SetDrawColor(255, 0, 0, 192);

        C.Font = class'HudBase'.static.GetConsoleFont( C );
        VehicleInfoString = V.VehicleNameString $ ":" @ int(VSize(Location-V.Location)*0.01875.f) $ class'HUD_Assault'.default.MetersString;
        class'HUD_Assault'.static.Draw_2DCollisionBox( C, V, ScreenPos, VehicleInfoString, 1.5f, true );
    }

    // Draw Reticle around visible friends
    foreach DynamicActors(class'XPawn', P )
    {
        if ((P==Self) || (P.Health < 1) || P.bDeleteMe || P.GetTeamNum() != Team || P.bCanTeleport==false)
                continue;

        if ( !class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, P, ScreenPos, Location, Rotation ) )
            continue;

        if ( !FastTrace( P.Location, Location ) )
            continue;
        C.SetDrawColor(0, 255, 100, 192);

        C.Font = class'HudBase'.static.GetConsoleFont( C );
        FriendInfoString = P.PlayerReplicationInfo.PlayerName @ int(VSize(Location-P.Location)*0.01875.f) $ class'HUD_Assault'.default.MetersString;
        class'HUD_Assault'.static.Draw_2DCollisionBox( C, P, ScreenPos, FriendInfoString, 1.5f, true );
    }
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	Super.Died(Killer, damageType, HitLocation);
}

simulated event Destroyed()
{
    local int i;

    if(LeftEngine!=None)
        LeftEngine.Destroy();
    if(LeftEngineB!=None)
        LeftEngineB.Destroy();
    if(RightEngine!=None)
        RightEngine.Destroy();
    if(RightEngineB!=None)
        RightEngineB.Destroy();
    if(LREngineA!=None)
        LREngineA.Destroy();
    if(LREngineB!=None)
        LREngineB.Destroy();
    if(RREngineA!=None)
        RREngineA.Destroy();
    if(RREngineB!=None)
        RREngineB.Destroy();
    if(LSideEngineA!=None)
        LSideEngineA.Destroy();
    if(LSideEngineB!=None)
        LSideEngineB.Destroy();
    if(LSideEngineC!=None)
        LSideEngineC.Destroy();
    if(RSideEngineA!=None)
        RSideEngineA.Destroy();
    if(RSideEngineB!=None)
        RSideEngineB.Destroy();
    if(RSideEngineC!=None)
        RSideEngineC.Destroy();

/*
    if(LeftEngine!=none)
    {
        LeftEngine.Destroy();
        LeftEngineB.Destroy();
        RightEngine.Destroy();
        RightEngineB.Destroy();

        LREngineA.Destroy();
        LREngineB.Destroy();
        RREngineA.Destroy();
        RREngineB.Destroy();

        LSideEngineA.Destroy();
        LSideEngineB.Destroy();
        LSideEngineC.Destroy();

        RSideEngineA.Destroy();
        RSideEngineB.Destroy();
        RSideEngineC.Destroy();
    }
    */

    if (NewAttachVehicle != None )
        EjectVehicle();

    if (MagEffect!=none)
        MagEffect.Destroy();


    for(i=0; i<RunningLights.Length; i++)
        RunningLights[i].Destroy();

    RunningLights.Length = 0;

    Super.Destroyed();
}

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
	local int i;
	if (bDriving)
	{
        GetAxes(Rotation,RotX,RotY,RotZ);
        SetTrailFX();
        if (RunningLights.Length == 0)
        {
    		RunningLights.Length = RunningLightOffsets.Length;

    		for(i=0; i<RunningLights.Length; i++)
            {
        		if (RunningLights[i] == None)
        		{
        			RunningLights[i] = spawn(Class'FX_RunningLight', self,, Location + (RunningLightOffsets[i] >> Rotation) );
        			RunningLights[i].SetBase(self);
        			if(Team==0)
        		       RunningLights[i].SetRedColor();
        		    else
        		       RunningLights[i].SetBlueColor();
                }
            }
    	}
    }
    else
    {
        for(i=0; i<RunningLights.Length; i++)
        {
            RunningLights[i].Destroy();
        }

        RunningLights.Length = 0;
        UnSetTrailFX();
    }

	Super.DrivingStatusChanged();

}

function bool CanAttachVehicle(ONSVehicle vehicle)
{
    local bool canAttach;
    if(vehicle == None)
        return false;

    //can attach if it's not flying
    canAttach = vehicle.bCanFly==false
            && vehicle.bCannotBeBased==false
            && vehicle.bMovable==true;

		
    if(Team != vehicle.Team)
    {
        //if other team, can attach if not locked and not occupied
        canAttach = canAttach && !vehicle.bTeamLocked && !vehicle.Occupied() && vehicle.NumPassengers()==0;  //updated pooty to fix jacking vehicls with gunners only
    }
        
    return canAttach;
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch,ThrustAmount,HitDist;
	local TrailEmitter T;
	local int i;
	local vector RelVel;
	local bool  bIsBehindView;
	local PlayerController PC;
	local vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local actor HitActor,HitActorB;
    local vector TraceStartB, TraceEndB, HitLocationB, HitNormalB;

    Super.Tick(DeltaTime);

    if(Level.NetMode != NM_DedicatedServer)
	{
        EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 32.0;
        SoundPitch = FClamp(EnginePitch, 64, 96);

        RelVel = Velocity << Rotation;

        PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget == self)
			bIsBehindView = PC.bBehindView;
		else
            bIsBehindView = True;
    }

    TraceStart = Location + (DustOffset >> Rotation);
    TraceEnd = TraceStart - ( DustTraceDistance * vect(0,0,1) );
    HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, True);
    //attaching vehicle
    TraceStartB = Location + (VehicleAttachOffset >> Rotation);
    TraceEndB = TraceStart - ( VehicleAttachTraceDistance * vect(0,0,1) );
    HitActorB = Trace(HitLocationB, HitNormalB, TraceEndB, TraceStartB, True);

    if(bAttached==False)
    {
        if(HitActorB != none 
            && HitActorB.IsA('ONSVehicle') 
            && CanAttachVehicle(ONSVehicle(HitActorB)) 
            && NewAttachVehicle==none)
        {
            NewAttachVehicle=ONSVehicle(HitActorB);
            AttachVehicle();
        }
    }

    if( VSize(Velocity)< 1000)
    {
        if(bHoverThrustersOn==false)
        {
            bHoverThrustersOn=true;
            HoverThrusters();
        }
    }
    else
    {
        if(bHoverThrustersOn==True)
        {
            bHoverThrustersOn=False;
            HoverThrusters();
        }
    }
}

function VehicleFire(bool bWasAltFire)
{
    if (bWasAltFire)
    {
        EjectPassengers();
    }
    else
        bWeaponIsFiring = True;
}

function timer()
{
    NewAttachVehicle=None;
    bAttached=false;
}

//simulated function EjectPassengers()
function EjectPassengers()
{
    local int x;


    if (NewAttachVehicle != None )
        EjectVehicle();

    for (x = 0; x < WeaponPawns.length; x++)
    {
        WeaponPawns[x].KDriverLeave(true);
    }
}

function int HasPassenger(Pawn passenger)
{
    local int x;

    for(x=0;x<WeaponPawns.Length;x++)
    {
        if(WeaponPawns[x].Driver == passenger)
            return x;
    }

    return -1;
}

simulated function ClientEjectVehicle()
{
    if(MagEffect != None)
    {
        DetachFromBone(MagEffect);
        MagEffect.SetBase(none);
        MagEffect.SetOwner(none);
        MagEffect.Destroy();
        MagEffect = None;
    }
}

simulated function EjectVehicle()
{
    local vector LOC;
    local ONSVehicleFactory parentFactory;
    local class<ONSVehicle> vehicleClass;
    local int oldHealth, i, passengerIndex;

    if (NewAttachVehicle != None && (Role == ROLE_Authority))
    {
        LOC=NewAttachVehicle.location;
        DetachFromBone(NewAttachVehicle);
        // this won't work on clients as bone never detaches on client
        // if it does detach, never syncs back up with server object
        // instead hack around it a bit by instead of dropping the ship, destroy it and 
        // spawn a new one.  It's a hack that causes problem with vehiclefactory that we
        // work around here
        //NewAttachVehicle.setlocation(LOC);
        //NewAttachVehicle.SetCollision(True,true,true);
        //NewAttachVehicle.SetPhysics(Phys_Karma);

        parentFactory = ONSVehicleFactory(NewAttachVehicle.ParentFactory);
        vehicleClass = NewAttachVehicle.class;
        oldHealth = NewAttachVehicle.Health;

        //need to up the vehicle count here so that the parent vehicle factory won't start it's timer
        //when it receives destroyed event
        parentFactory.VehicleCount++;
        NewAttachVehicle.Destroy();
        NewAttachVehicle=none;
        spawnVehicle = spawn(vehicleClass,,,LOC);
        spawnVehicle.SetTeamNum(Team);
        spawnVehicle.TeamChanged();
        spawnVehicle.Team = Team;
        spawnVehicle.TeamChanged();
        spawnVehicle.Health = oldhealth;
        spawnVehicle.bTeamLocked = false;
        spawnVehicle.bNeverReset = bNewAttachVehicleNeverReset;
        spawnVehicle.bKeyVehicle = bNewAttachVehicleKeyVehicle;
        spawnVehicle.ParentFactory = parentFactory;
        parentFactory.LastSpawned = spawnVehicle;
        spawnVehicle.Event = Tag;
        TriggerEvent(Event, Self, spawnVehicle);

        VehicleMass = default.VehicleMass;

        if(passengers.length > 0)
        {
            passengerIndex = HasPassenger(passengers[0]);
            if(passengerIndex >= 0)
            {
                WeaponPawns[passengerIndex].KDriverLeave(true);
                spawnVehicle.KDriverEnter(passengers[0]);
            }
            for(i=1;i<passengers.length;i++)
            {
                passengerIndex = HasPassenger(passengers[i]);
                if(passengerIndex >= 0)
                {
                    WeaponPawns[passengerIndex].KDriverLeave(true);
                    spawnVehicle.WeaponPawns[i-1].KDriverEnter(passengers[i]);
                }
            }

            passengers.length=0;
        }

        //mag effect needs to happen on client only 
        //due to same attachment issue
        ClientEjectVehicle();

        //wait 4 seconds before allowing re-attach, 
        //otherwise we would re-attach the vehicle we just dropped
        settimer(4,false);
    }
}

simulated function AttachVehicle()
{
    local vector SpawnDistance;
    local rotator YawRot;
    local int x,y;
    local Pawn passenger;
    local bool detached, found;
    //local array<Pawn> passengers;

    if(NewAttachVehicle != None && Role == ROLE_Authority)
    {
        passengers.length=0;
        //move vehicle occupiants into passenger seats
        if(NewAttachVehicle.Occupied())
        {
            passenger = NewAttachVehicle.Driver;
            if(NewAttachVehicle.KDriverLeave(true))
                passengers[passengers.length] = passenger;

            for (x = 0; x < NewAttachVehicle.WeaponPawns.length; x++)
            {
                passenger = NewAttachVehicle.WeaponPawns[x].Driver;
                if(NewAttachVehicle.WeaponPawns[x].KDriverLeave(true))
                {
                    passengers[passengers.length] = passenger;
                }
            }

            for(x=0;x<passengers.length;x++)
            {
                found = false;
                for(y=0;y < WeaponPawns.length && !found;y++)
                {
                    if(WeaponPawns[y].Driver == None)
                    {
                        WeaponPawns[y].KDriverEnter(passengers[x]);
                        found=true;
                    }
                }
            }
        }

        YawRot = Rotation;
        YawRot.Roll = 0;
        YawRot.Pitch = 0;
        SpawnDistance.z= -1;
        bNewAttachVehicleNeverReset = NewAttachVehicle.bNeverReset;
        NewAttachVehicle.bNeverReset = true; 
        bNewAttachVehicleKeyVehicle = NewAttachVehicle.bKeyVehicle;
        NewAttachVehicle.bKeyVehicle = false;
        NewAttachVehicle.SetPhysics(Phys_none);
        NewAttachVehicle.SetCollision(false,false,false);
        AttachToBone(NewAttachVehicle,'VehicleAttach_Bone');
        NewAttachVehicle.SetRelativeLocation(SpawnDistance);
        // Steal other team Vehicles
        if(NewAttachVehicle.Team != Team)
        {
            NewAttachVehicle.Team = Team;
            NewAttachVehicle.TeamChanged();
        }

        NewAttachVehicle.bTeamLocked = false;
        VehicleMass += NewAttachVehicle.VehicleMass;

        //call client to do mageffect clientside
        ClientAttachVehicle();
    }
    bAttached=true;
}

function ClientAttachVehicle()
{
    if(Team == 0)
        MagEffect = spawn(RedBuildEffectClass,,, Location, Rotation);
    else
        MagEffect = spawn(BlueBuildEffectClass,,, Location, Rotation);

    if(MagEffect != None)
    {
        MagEffect.bSkipActorPropertyReplication=false;
        AttachToBone(MagEffect,'VehicleAttach_Bone');
    }
}

function float ImpactDamageModifier()
{
    local float Multiplier;
    local vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);
    if (ImpactInfo.ImpactNorm Dot Z > 0)
        Multiplier = 1-(ImpactInfo.ImpactNorm Dot Z);
    else
        Multiplier = 1.0;

    return Super.ImpactDamageModifier() * Multiplier;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

//FIXME Fix to not be specific to this class after demo
function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent *= 2;
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);
	if (Trace(HitLocation, HitNormal, Location + (ZOffset * 6), Location, false, Extent) != None)
		return false;

	//avoid running driver over by placing in direction perpendicular to velocity
	if ( VSize(Velocity) > 100 )
	{
		tryPlace = Normal(Velocity cross vect(0,0,1)) * (CollisionRadius + Driver.default.CollisionRadius ) * 1.25 ;
		if ( FRand() < 0.5 )
			tryPlace *= -1; //randomly prefer other side
		if ( (Trace(HitLocation, HitNormal, Location + tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location + tryPlace + ZOffset))
		     || (Trace(HitLocation, HitNormal, Location - tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location - tryPlace + ZOffset)) )
			return true;
	}

	for( i=0; i<ExitPositions.Length; i++)
	{
		if ( ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
		else
			ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

		if ( bRelativeExitPos )
			tryPlace = Location + ( (ExitPositions[i]-ZOffset) >> Rotation) + ZOffset;
		else
			tryPlace = ExitPositions[i];

		// First, do a line check (stops us passing through things on exit).
		if ( bRelativeExitPos && Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

simulated function SetTrailFX()
{
	// Trail FX
	if ( RightEngine==None && Health>0 && Role == ROLE_Authority)
    {
        LeftEngine = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(LeftEngine, 'LEngineA');
        LeftEngineB = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(LeftEngineB, 'LEngineB');

        RightEngine = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(RightEngine, 'REngineA');
        RightEngineB = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(RightEngineB, 'REngineB');

        LeftEngine.SetRelativeRotation( rot(0,32768,0) );
        LeftEngineB.SetRelativeRotation( rot(0,32768,0) );
        RightEngine.SetRelativeRotation( rot(0,32768,0) );
        RightEngineB.SetRelativeRotation( rot(0,32768,0) );

        // Rear Engines
        LREngineA = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(LREngineA, 'RearLEngineA');
        LREngineB = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(LREngineB, 'RearLEngineB');

        RREngineA = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(RREngineA, 'RearREngineA');
        RREngineB = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(RREngineB, 'RearREngineB');

        LREngineA.SetRelativeRotation( rot(0,32768,0) );
        LREngineB.SetRelativeRotation( rot(0,32768,0) );
        RREngineA.SetRelativeRotation( rot(0,32768,0) );
        RREngineB.SetRelativeRotation( rot(0,32768,0) );

        //SideEngines
        LSideEngineA = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(LSideEngineA, 'LEngineC');
        LSideEngineB = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(LSideEngineB, 'LEngineD');
        LSideEngineC = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(LSideEngineC, 'RearLEngineC');

        RSideEngineA = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(RSideEngineA, 'REngineC');
        RSideEngineB = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(RSideEngineB, 'REngineD');
        RSideEngineC = Spawn(class'FX_DropShipEngine',Self);
        AttachToBone(RSideEngineC, 'RearREngineC');

        LSideEngineA.SetRelativeRotation( rot(-16738,0,16738) );
        LSideEngineB.SetRelativeRotation( rot(-16738,0,16738) );
        LSideEngineC.SetRelativeRotation( rot(-16738,0,16738) );

        RSideEngineA.SetRelativeRotation( rot(-16738,0,16738) );
        RSideEngineB.SetRelativeRotation( rot(-16738,0,16738) );
        RSideEngineC.SetRelativeRotation( rot(-16738,0,16738) );
    }
    else
    {
        LeftEngine.SetVisable();
        LeftEngineB.SetVisable();
        RightEngine.SetVisable();
        RightEngineB.SetVisable();

        LREngineA.SetVisable();
        LREngineB.SetVisable();
        RREngineA.SetVisable();
        RREngineB.SetVisable();

        LSideEngineA.SetVisable();
        LSideEngineB.SetVisable();
        LSideEngineC.SetVisable();

        RSideEngineA.SetVisable();
        RSideEngineB.SetVisable();
        RSideEngineC.SetVisable();
    }
}
simulated function UnSetTrailFX()
{
    if(LeftEngine!=none)
    {
        /*
        LeftEngine.Destroy();
        LeftEngineB.Destroy();
        RightEngine.Destroy();
        RightEngineB.Destroy();

        LREngineA.Destroy();
        LREngineB.Destroy();
        RREngineA.Destroy();
        RREngineB.Destroy();

        LSideEngineA.Destroy();
        LSideEngineB.Destroy();
        LSideEngineC.Destroy();

        RSideEngineA.Destroy();
        RSideEngineB.Destroy();
        RSideEngineC.Destroy();
        */
        LeftEngine.SetInvisable();
        LeftEngineB.SetInvisable();
        RightEngine.SetInvisable();
        RightEngineB.SetInvisable();

        LREngineA.SetInvisable();
        LREngineB.SetInvisable();
        RREngineA.SetInvisable();
        RREngineB.SetInvisable();

        LSideEngineA.SetInvisable();
        LSideEngineB.SetInvisable();
        LSideEngineC.SetInvisable();

        RSideEngineA.SetInvisable();
        RSideEngineB.SetInvisable();
        RSideEngineC.SetInvisable();
    }
}

simulated event HoverThrusters()
{
    if(bHoverThrustersOn==False)
    {
        if(RSideEngineA!=none)
        {
            RSideEngineA.SetInvisable();
            RSideEngineB.SetInvisable();
            RSideEngineC.SetInvisable();
            LSideEngineA.SetInvisable();
            LSideEngineB.SetInvisable();
            LSideEngineC.SetInvisable();
        }
    }
    else
    {
        if(RSideEngineA!=none)
        {
            RSideEngineA.SetVisable();
            RSideEngineB.SetVisable();
            RSideEngineC.SetVisable();
            LSideEngineA.SetVisable();
            LSideEngineB.SetVisable();
            LSideEngineC.SetVisable();
        }
    }
}

simulated function PostNetReceive()
{
    super.PostNetReceive();
    if(bOldAttached != bAttached)
    {
        if(!bAttached)
        {
            if(NewAttachVehicle != None && NewAttachVehicle.Team != Team)
            {
                //NewAttachVehicle.Team = Team;
                //NewAttachVehicle.TeamChanged();
            }
        }

        bOldAttached = bAttached;
    }

}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    Momentum = Momentum * 0.25;
    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}


defaultproperties
{
    bEnhancedHud=false
    EnhancedHudRange=10000
    bNetNotify=true
    MaxPitchSpeed=10.000000
    DustOffset=(Z=10.000000)
    DustTraceDistance=600.000000
    NumChaff=20
    RedBuildEffectClass=Class'CSAPVerIV.ONSVehiclemagEffect'
    BlueBuildEffectClass=Class'CSAPVerIV.ONSVehiclemagEffectBlue'
    VehicleAttachOffset=(X=-586.000000,Z=86.000000)
    VehicleAttachTraceDistance=286.000000
    RunningLightOffsets(0)=(X=-116.000000,Y=-454.000000,Z=100.000000)
    RunningLightOffsets(1)=(X=-116.000000,Y=454.000000,Z=100.000000)
    RunningLightOffsets(2)=(X=-680.000000,Y=-250.000000,Z=204.000000)
    RunningLightOffsets(3)=(X=-680.000000,Y=250.000000,Z=204.000000)
    RunningLightOffsets(4)=(X=14.000000,Z=-124.000000)

    UprightStiffness=10000.000000
    UprightDamping=300.000000
    //MaxThrustForce=60.000000
    MaxThrustForce=180.000000
    LongDamping=0.050000
    //MaxStrafeForce=80.000000
    MaxStrafeForce=240.000000
    LatDamping=0.050000
    //MaxRiseForce=80.000000
    MaxRiseForce=240.000000
    UpDamping=0.050000
    TurnTorqueFactor=600.000000
    TurnTorqueMax=200.000000
    TurnDamping=50.000000
    MaxYawRate=1.500000
    PitchTorqueFactor=200.000000
    PitchTorqueMax=35.000000
    PitchDamping=20.000000
    RollTorqueTurnFactor=450.000000
    RollTorqueStrafeFactor=50.000000
    RollTorqueMax=50.000000
    RollDamping=30.000000
    StopThreshold=100.000000
    MaxRandForce=3.000000
    RandForceInterval=0.750000

    /*
    UprightStiffness=1000.000000
    LongDamping=0.040000
    MaxStrafeForce=100.000000
    LatDamping=0.040000
    MaxRiseForce=80.000000
    UpDamping=0.100000
    RollTorqueTurnFactor=750.000000
    RollTorqueStrafeFactor=100.000000
    RollTorqueMax=100.000000
    PushForce=200000.000000
    */

    DriverWeapons(0)=(WeaponClass=Class'CSAPVerIV.Weapon_DropShipWeapon',WeaponBone="RocketPanel")
    PassengerWeapons(0)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassA")
    PassengerWeapons(1)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassB")
    PassengerWeapons(2)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassC")
    PassengerWeapons(3)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassD")
    PassengerWeapons(4)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassE")
    PassengerWeapons(5)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassF")
    PassengerWeapons(6)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassG")
    PassengerWeapons(7)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_DropShipPassenger',WeaponBone="PassH")
    IdleSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftIdle'
    StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
    ShutDownSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
    StartUpForce="AttackCraftStartUp"
    ShutDownForce="AttackCraftShutDown"
    DestroyedVehicleMesh=StaticMesh'APVerIV_ST.DropShip_ST.DropshipDestroyed'
    DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
    DisintegrationEffectClass=Class'Onslaught.ONSVehDeathAttackCraft'
    DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
    DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
    DamagedEffectScale=1.500000
    DamagedEffectOffset=(X=100.000000,Y=20.000000,Z=26.000000)
    ImpactDamageMult=0.001000
    HeadlightCoronaOffset(0)=(X=-64.000000,Z=140.000000)
    HeadlightCoronaOffset(1)=(X=266.000000,Z=-120.000000)
    HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
    HeadlightCoronaMaxSize=60.000000
    //VehicleMass=4.000000
    VehicleMass=12.000000
    bTurnInPlace=True
    bDriverHoldsFlag=False
    bCanCarryFlag=False
    ExitPositions(0)=(Y=-165.000000,Z=100.000000)
    ExitPositions(1)=(Y=165.000000,Z=100.000000)
    EntryPosition=(X=-40.000000)
    EntryRadius=210.000000
    TPCamDistance=500.000000
    TPCamLookat=(X=0.000000,Z=0.000000)
    TPCamWorldOffset=(Z=200.000000)
    DriverDamageMult=0.000000
    VehiclePositionString="in a DropShip"
    VehicleNameString="DropShip 1.9"
    RanOverDamageType=Class'Onslaught.DamTypeAttackCraftRoadkill'
    CrushedDamageType=Class'Onslaught.DamTypeAttackCraftPancake'
    MaxDesireability=0.600000
    FlagBone="Main"
    FlagOffset=(Z=80.000000)
    FlagRotation=(Yaw=32768)
    HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn03'
    HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn07'
    bCanBeBaseForPawns=True
    GroundSpeed=500.000000
    HealthMax=1000
    Health=1000
    Mesh=SkeletalMesh'APVerIV_Anim.UTDropShip'
    SoundVolume=160
    CollisionRadius=150.000000
    CollisionHeight=70.000000

    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KInertiaTensor(0)=1.000000
        KInertiaTensor(3)=3.000000
        KInertiaTensor(5)=3.500000
        KCOMOffset=(X=-0.250000)
        KLinearDamping=0.000000
        KAngularDamping=0.000000
        KStartEnabled=True
        bKNonSphericalInertia=True
        KActorGravScale=0.000000
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        bKStayUpright=True
        bKAllowRotate=True
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        KFriction=0.500000
        KImpactThreshold=300.000000
    End Object
    KParams=KarmaParamsRBFull'CSAPVerIV.DropShipKarma.KParams0'
}
