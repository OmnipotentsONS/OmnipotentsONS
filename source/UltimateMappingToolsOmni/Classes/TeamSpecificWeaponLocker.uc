// ============================================================================
// TeamSpecificWeaponLocker_v2, v2.0 @ 14-11-2005 13:33:37
// Made by Robin 'Jrubzjeknf' van Olst <rrvanolst@hotmail.com>
//
// Players are treated differently based on what team they're on. While players
// of one team can use the WeaponLocker, players on the other team can't. The
// green light has been replaced with a red or blue light, indicating the color
// of the team to which it belongs. When players of the opposing team try to
// use this locker, it won't give the player inventory. Additionally, it can
// play a sound and/or give a message in a specific color.
//
// Full documentation on TeamSpecificActors_v2.u can be downloaded from:
// http://unrealized-potential.com/forum/index.php?act=Attach&type=post&id=5135
//=============================================================================
class TeamSpecificWeaponLocker extends WeaponLocker
   placeable;

replication
{
   reliable if ( bNetDirty )
      BelongsToTeam, CurrentMessage, DeniedMessageColor;
}

//=============================================================================
// Variables
//=============================================================================
var   bool   bChangeOnNextReset; //hack for Assault resetting the first round
var   bool   bIsASPractiseRound; //do nothing when the next reset is actually the start of the match
var   bool   bIsASorONS; //if true, change teams
var   int    ReplicationCounter;
var  GameObjective ClosestObjective; // used to assign teamnum by objective

var() int    BelongsToTeam;         //To what team this Teleporter belongs
var() string DeniedMessage;         //Dynamic Message sent to players of the wrong team
var   string CurrentMessage;        //Real Message
var() color  DeniedMessageColor;    //Color of the message for players of the wrong team
var() int    DeniedMessageLifetime; //How long the message should be on the player's screen
var() bool   bSwitchColorOnReset;   //If the color should change on reset
var() sound  DeniedSound;           //Sound for players of the wrong team
var() bool   bAssignToClosestObjective; // TeamNum of this actor depends on the closest GameObjective



//=============================================================================
// PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
   if (bAssignToClosestObjective)
   {
       ClosestObjective = GetClosestObjective();

       Enable('Tick');
   }
   else
   {
       Disable('Tick');

       if ( Level.Game.IsA('ASGameInfo') )
       {
           bIsASPractiseRound = false;
           bIsASorONS = true;
       }

       if ( Level.Game.IsA('ONSOnslaughtGame') )
       {
           bChangeOnNextReset = true;
           bIsASorONS = true;
       }

       CurrentMessage = class'TeamSpecificLocalMessage'.static.MakeDynamicString(DeniedMessage, BelongsToTeam);
   }

   Super.PostBeginPlay();
}


//=============================================================================
// Reset
//=============================================================================
function Reset()
{
   Super.Reset();

   if (bAssignToClosestObjective)
       return;

   if ( bIsASorONS )
   {
      if ( !bIsASPractiseRound &&
           Level.Game.IsA('ASGameInfo') &&
           ASGameInfo(Level.Game).PracticeTimeLimit > 0 )
      {
         bIsASPractiseRound = true;
         return;
      }

      if ( bChangeOnNextReset )
      {
         BelongsToTeam = Abs(BelongsToTeam - 1);

         if ( bSwitchColorOnReset )
            DeniedMessageColor = class'TeamSpecificLocalMessage'.static.RGBtoBGR(DeniedMessageColor);

         //to get the changing of the emitters working in standalone games and listenservers
         if ( Level.NetMode == NM_Standalone ||
              Level.NetMode == NM_ListenServer )
            PostNetReceive();
      }
   }

   CurrentMessage = class'TeamSpecificLocalMessage'.static.MakeDynamicString(DeniedMessage, BelongsToTeam);
   bChangeOnNextReset = true;
}


//=============================================================================
// PostNetBeginPlay
//=============================================================================
simulated function PostNetBeginPlay()
{
   Super.PostNetBeginPlay();

   PostNetReceive();
}


//=============================================================================
// PostNetReceive
//=============================================================================
simulated function PostNetReceive()
{
   if ( Effect != None )
   {
      if ( BelongsToTeam == 0 )
      {
         Effect.Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 64, 32);
         Effect.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 112, 64);
      }
      else
      {
         Effect.Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor(32, 64, 255);
         Effect.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(64, 112, 255);
      }
   }
}


//=============================================================================
// GetClosestObjective
//
// Returns the closest GameObjective in this actors proximity
//=============================================================================
function GameObjective GetClosestObjective()
{
    local GameObjective GO, BestGO;
    local float Distance, BestDistance;


    foreach AllActors (class'GameObjective', GO)
    {
        Distance = VSize(GO.Location - Location);
        if ( Distance < BestDistance || BestDistance ~= 0.0)
        {
            BestDistance = Distance;
            BestGO = GO;
        }
    }

    return BestGO;
}


//=============================================================================
// HasCustomer
//
// Pretends it already has the enemy as customer, thus cannot use.
//=============================================================================
function bool HasCustomer(Pawn P)
{
   if ( P.GetTeamNum() != BelongsToTeam )
      return true;

   return Super.HasCustomer(P);
}


//=============================================================================
// Tick
//
// Checks the DTI of the closest objective to find out if it needs to update the
// colour of it's light.
//=============================================================================
function Tick(float DeltaTime)
{
    BelongsToTeam = ClosestObjective.DefenderTeamIndex;

}


/*STATE*/
auto state LockerPickup
{
   //=============================================================================
   // ValidTouch
   //
   // Enemy can't touch me, so return false. Shows message/plays sound too.
   //=============================================================================
   simulated function bool ValidTouch(Actor Other)
   {
      local Pawn P;

      // make sure its a live player
      if ( ( Pawn(Other) == None ) ||
            !Pawn(Other).bCanPickupInventory ||
           ( Pawn(Other).DrivenVehicle == None &&
             Pawn(Other).Controller == None ) )
         return false;

      // make sure not touching through wall
      if ( !FastTrace(Other.Location, Location) )
         return false;

      if ( Pawn(Other) != None )
      {
         P = Pawn(Other);

         if (bAssignToClosestObjective)
         {
             CurrentMessage = class'TeamSpecificLocalMessage'.static.MakeDynamicString(DeniedMessage, BelongsToTeam);
         }

         if ( P.GetTeamNum() != BelongsToTeam )
         {
            if ( DeniedMessage != "" )
               P.ReceiveLocalizedMessage(class'TeamSpecificLocalMessage',,,,Self);

            if (DeniedSound != None)
               P.PlaySound(DeniedSound);

            return false;
         }
      }

      return true;
   }
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     bIsASPractiseRound=True
     DeniedMessageColor=(A=255)
     DeniedMessageLifetime=1
     bSwitchColorOnReset=True
     bNetNotify=True
}
