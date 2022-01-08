//=============================================================================
// FighterPlayerStartTrigger
//  Spawns Player and Chosen Fighter class, and can set Health on vehicle class
//  puts Player in Vehicle spawned automaticly
//=============================================================================

class VehiclePlayerStartTrigger extends Trigger;


var()	class<Vehicle>		VehicleClass;
var Vehicle CreatedVehicle,LastCreatedVehicle;
var float Range;
var float Closest,NewClosest;
var xpawn Closestpawn,P,OldPawn;
var() byte TeamNumber;
replication
{
	reliable if( Role==ROLE_Authority )
            CreatedVehicle,Range;
}

function PostBeginPlay()
{
	SetTimer(0.15, True);
    Super.PostBeginPlay();
    SetTimer(0.15, True);
}

simulated function Timer()
{
  //log("!!!!!!!!!!!!!!!!!!!!!!!!!!Timer function Working!!!!!!!!!!!!!!!!!!!!!");
  Closest = Range;
  foreach AllActors(class'xpawn', P)
	      {
            NewClosest = VSize(P.Location - Location);

             if (NewClosest < Closest)//Range
		        {
                 if(P.Controller!= none && P.DrivenVehicle==none && P.Health > 1)
                    {
                     //log("!!!!!!!!!!!!!!!!!!!!!!!!!!Have a Pawn!!!!!!!!!!!!!!!!!!!!!");
                     Closestpawn=P;
                     Closest = NewClosest;
                     PilotVehicle(Closestpawn);
                    }
                }
           }
}

simulated event PilotVehicle(XPawn P)
{
  if ( VehicleClass != none )
	 {
	  CreatedVehicle = spawn(VehicleClass, , , Location+vect(2000,0,0), Rotation);
      CreatedVehicle.SetTeamNum(TeamNumber);
      CreatedVehicle.bTeamLocked=false;
      CreatedVehicle.TryToDrive(P);
      LastCreatedVehicle=CreatedVehicle;
      CreatedVehicle=none;
      OldPawn=Closestpawn;
      Closestpawn=none;
    }
}

defaultproperties
{
     Range=512.000000
     bHidden=False
     bDirectional=True
}
