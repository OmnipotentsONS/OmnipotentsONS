//=============================================================================
// FighterPlayerStart
//  Spawns Player and Chosen Fighter class, and can set Health on vehicle class
//  puts Player in Vehicle spawned automaticly
//=============================================================================
class VehiclePlayerStart extends PlayerStart;

var()	class<Vehicle>		VehicleClass;
var VehiclePlayerStartTrigger Trigger;
replication
{
	reliable if( Role==ROLE_Authority )
            Trigger;
}

function PostBeginPlay()
{
	Trigger = Spawn(class'VehiclePlayerStartTrigger',self,,location,Rotation);
    Trigger.VehicleClass= VehicleClass;
    Trigger.TeamNumber=TeamNumber;
    Super.PostBeginPlay();

}

simulated event Touch(Actor Other)
{
  if( Role==ROLE_Authority )
   {
    if ( !bEnabled || (Other == None) )
		return;
   }
}

simulated function PostTouch( actor Other )
{
}

defaultproperties
{
     bNoAutoConnect=True
     bFlyingPreferred=True
     bIgnoreEncroachers=True
     bIgnoreVehicles=True
     RemoteRole=ROLE_SimulatedProxy
     DrawScale=6.000000
}
