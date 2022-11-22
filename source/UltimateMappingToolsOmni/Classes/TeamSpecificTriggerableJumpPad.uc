// ============================================================================
// TeamSpecificTriggerableJumppad_v2, v2.0 @ 14-11-2005 13:33:37
// Made by Robin 'Jrubzjeknf' van Olst <rrvanolst@hotmail.com>
//
// Players are treated differently based on what team they're on. While one
// player can use the jumppad like always, the other is denied from doing that.
// Being denied can be combined with getting a message (custom colors
// supported) and/or a sound.
//
// Full documentation on TeamSpecificActors_v2.u can be downloaded from:
// http://unrealized-potential.com/forum/index.php?act=Attach&type=post&id=5135
//=============================================================================
class TeamSpecificTriggerableJumppad extends UTJumpPad
   placeable;


replication
{
   reliable if ( bNetDirty )
      BelongsToTeam, CurrentMessage, DeniedMessageColor;
}

//=============================================================================
// Variables
//=============================================================================
var() bool   bInitialyActive;
var   bool   bActive;
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
   bActive = bInitialyActive;

   if (bAssignToClosestObjective)
   {
       ClosestObjective = GetClosestObjective();
   }
   else
   {
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
      }
   }

   CurrentMessage = class'TeamSpecificLocalMessage'.static.MakeDynamicString(DeniedMessage, BelongsToTeam);
   bChangeOnNextReset = true;
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
// Trigger
//=============================================================================
event Trigger(Actor Other, Pawn EventInstigator)
{
   bActive=!bActive;
}


//=============================================================================
// Touch
//
// Only sends players of a predefined team flying.
// Do stuff according to the team the player is on.
//=============================================================================
event Touch(Actor Other)
{
   local Pawn P;

   if ( !bActive ||
        (UnrealPawn(Other) == None) ||
        (Other.Physics == PHYS_None) )
      return;

   P = Pawn(Other);

   if (bAssignToClosestObjective)
   {
       BelongsToTeam = ClosestObjective.DefenderTeamIndex;
       CurrentMessage = class'TeamSpecificLocalMessage'.static.MakeDynamicString(DeniedMessage, BelongsToTeam);
   }

   if ( P.GetTeamNum() != BelongsToTeam ) //check on what team player is
   {
      if ( DeniedMessage != "" )
         P.ReceiveLocalizedMessage(class'TeamSpecificLocalMessage',,,,Self);
      if (DeniedSound != None)
         Other.PlaySound(DeniedSound);
      return;
   }

   PendingTouch = Other.PendingTouch;
   Other.PendingTouch = self;
}


//=============================================================================
// SpecialCost
//=============================================================================
event int SpecialCost(Pawn Other, ReachSpec Path)
{
   BelongsToTeam = ClosestObjective.DefenderTeamIndex;

   if ( !bActive ||
        Other.GetTeamNum() != BelongsToTeam ) //if bot is not in appropiate team, then DONT GO THERE!
      return 100000000;

   return Super.SpecialCost(Other, Path);
}


//=============================================================================
// Defaultproperties
//=============================================================================

defaultproperties
{
     bInitialyActive=True
     bIsASPractiseRound=True
     DeniedMessageColor=(A=255)
     DeniedMessageLifetime=1
     bSwitchColorOnReset=True
     bAlwaysRelevant=True
     Texture=Texture'UltimateMappingTools_Tex.Icons.TS_NavPoint'
}
