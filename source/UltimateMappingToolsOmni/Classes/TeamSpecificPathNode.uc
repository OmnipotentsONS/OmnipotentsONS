// ============================================================================
// TeamSpecificPathNode_v2, v2.0 @ 14-11-2005 13:33:37
// Made by Robin 'Jrubzjeknf' van Olst <rrvanolst@hotmail.com>
//
// Bots are treated differently based on what team they're on. While one bot
// can use it, other bots are highly recommend that they shouldn't. In case the
// variable bBlocked is set to false, all bots will always ignore the pathnode.
//
// Full documentation on TeamSpecificActors_v2.u can be downloaded from:
// http://unrealized-potential.com/forum/index.php?act=Attach&type=post&id=5135
//=============================================================================
class TeamSpecificPathNode extends PathNode
   placeable;


//=============================================================================
// Variables
//=============================================================================
var() int  BelongsToTeam; // To which team this PathNode belongs
var   bool bChangeOnNextReset; //hack for Assault resetting the first round
var   bool bIsASPractiseRound; //do nothing when the next reset is actually the start of the match
var   bool bIsASorONS; //if true, change teams


//=============================================================================
// PostBeginPlay
//=============================================================================
function PostBeginPlay()
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

   Super.PostBeginPlay();
}


//=============================================================================
// Reset
//=============================================================================
function Reset()
{
   Super.Reset();

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
         BelongsToTeam = Abs(BelongsToTeam - 1);
   }

   bChangeOnNextReset = true;
}


//=============================================================================
// Trigger
//=============================================================================
event Trigger(Actor Other, Pawn EventInstigator)
{
   bBlocked = !bBlocked;
}


//=============================================================================
// SpecialCost
//
// Prevent bots of the other team from using this teleport.
//=============================================================================
event int SpecialCost(Pawn Other, ReachSpec Path)
{
   if ( Other.GetTeamNum() != BelongsToTeam )
      return 100000000;

   return Super.SpecialCost(Other, Path);
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     bIsASPractiseRound=True
     Texture=Texture'UltimateMappingTools_Tex.Icons.TS_Pickup'
}
