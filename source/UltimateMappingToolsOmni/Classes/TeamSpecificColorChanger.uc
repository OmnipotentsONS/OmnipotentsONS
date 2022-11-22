// ============================================================================
// TeamSpecificColorChanger, v2.0 @ 31-7-2005 13:33:37
// Made by Robin 'Jrubzjeknf' van Olst <rrvanolst@hotmail.com>
//
// Changes the color of Emitters/ColorModifiers on every reset.
//
// Full documentation on TeamSpecificActors_v2.u can be downloaded from:
// http://unrealized-potential.com/forum/index.php?act=Attach&type=post&id=5135
//===========================================================================
class TeamSpecificColorChanger extends Actor
   placeable;


//=============================================================================
// Variables
//=============================================================================
var() array<ColorModifier>                           ColorModifiers; //array of ColorModifiers which's color should change
var() array<Emitter>                                 Emitters; //array of Emitters which's color should change
var() edfindable Emitter                             FindYourEmitter; //dummy variable. Mappers can use it to find an Emitter
var   array<TeamSpecificColorChangerReplicationInfo> ReplicatedColorChangers; //array holding all replication infos (needed to change colors clientsidely)
var   bool                                           bChangeOnNextReset; //hack for Assault resetting the first round
var   bool                                           bIsASPractiseRound; //do nothing when the next reset is actually the start of the match
var   bool                                           bIsASorONS; //if true, change colors


//=============================================================================
// PostBeginPlay
//
// Spawns a TeamSpecificColorChangerReplicationInfo for each ColorModifier and
// Emitter listed in the arrays.
//=============================================================================
function PostBeginPlay()
{
   local int    i;
   local int    j;
   local string ObjectName;
   local string ObjectType;

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

   for (i=0; i < ColorModifiers.Length; i++)
      for (j=0; j < ColorModifiers.Length; j++)
         if ( i != j && string(ColorModifiers[i]) != "None" && string(ColorModifiers[i]) == string(ColorModifiers[j]) )
         {
            log("A ColorModifier already present in the array ColorModifiers has been found at position" $ j $ ". Remove the ColorModifier from that position", 'TeamSpecificColorChanger');
            ColorModifiers[j] = None;
         }

   for (i=0; i < Emitters.Length; i++)
      for (j=0; j < Emitters.Length; j++)
         if ( i != j && string(Emitters[i]) != "None" && string(Emitters[i]) == string(Emitters[j]) )
         {
            log("An Emitter already present in the array Emitters has been found at position " $ j $ ". Remove the Emitter from that position", 'TeamSpecificColorChanger');
            ColorModifiers[j] = None;
         }

   ReplicatedColorChangers.Length = ColorModifiers.Length + Emitters.Length;

   for ( i = 0; i < ReplicatedColorChangers.Length; i++ )
   {
      ReplicatedColorChangers[i] = Spawn(class'TeamSpecificColorChangerReplicationInfo', Self);

      if ( i < ColorModifiers.Length )
      {
         ObjectName = string(ColorModifiers[i]);
         ObjectType = "ColorModifier";
      }
      else
      {
         ObjectName = string(Emitters[i - ColorModifiers.Length]);
         ObjectType = "Emitter";
      }

      ReplicatedColorChangers[i].SetObjectToModify(ObjectName, ObjectType);
   }
}


//=============================================================================
// Reset
//
// Makes all the ReplicatedColorChangers change the color of their Object.
//=============================================================================
function Reset()
{
   local int i;

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
         for (i = 0; i < ReplicatedColorChangers.Length; i++)
            if ( ReplicatedColorChangers[i] != None )
               ReplicatedColorChangers[i].ModifyObject();
   }

   bChangeOnNextReset = true;
}

//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     ColorModifiers(0)=ColorModifier'UltimateMappingTools_Tex.LaserRed'
     ColorModifiers(1)=ColorModifier'UltimateMappingTools_Tex.LaserBlue'
     bIsASPractiseRound=True
     bHidden=True
     bNoDelete=True
     bAlwaysRelevant=True
     Texture=Texture'UltimateMappingTools_Tex.Icons.TS_ColorChanger'
}
