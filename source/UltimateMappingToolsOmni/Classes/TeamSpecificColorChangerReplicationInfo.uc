//=============================================================================
// TeamSpecificColorChangerReplicationInfo, v2.0 @ 31-7-2005 13:33:37
// Made by Robin 'Jrubzjeknf' van Olst <rrvanolst@hotmail.com>
//
// Contains the ColorModifier or Emitter that needs a color modification.
//
// Full documentation on TeamSpecificActors_v2.u can be downloaded from:
// http://unrealized-potential.com/forum/index.php?act=Attach&type=post&id=5135
//=============================================================================
class TeamSpecificColorChangerReplicationInfo extends ReplicationInfo;


//=============================================================================
// Variables
//=============================================================================
var string ObjectName; //looks like <Mapname>.<Object><index>, ie. ONS-TeamSpecificActors_v2.Emitter3
var string ObjectType; //ColorModifier or Emitter
var int ClientTriggerCount;
var int TriggerCount;


//=============================================================================
// Replication
//=============================================================================
replication
{
  reliable if ( Role == ROLE_Authority )
    TriggerCount, ObjectName, ObjectType;
}


//=============================================================================
// SetObjectToModify
//
// Saves Object and what it is, so it can be modified in the future.
//=============================================================================
function SetObjectToModify(string newObject, string newType)
{
  ObjectName = newObject;
  ObjectType = newType;
}


//=============================================================================
// ModifyObject
//
// Used to let the server call PostNetReceive() on the client.
//=============================================================================
function ModifyObject()
{
  TriggerCount++;
  
  if ( Level.NetMode == NM_Standalone ||
       Level.NetMode == NM_ListenServer )
     PostNetReceive();
}


//=============================================================================
// PostNetReceive
//
// Modifies the color of ColorModifier and Emitter clientsidely.
//=============================================================================
simulated function PostNetReceive()
{
   local ColorModifier ModifyColorModifier;
   local Emitter       ModifyEmitter;
   local int           ParticleEmitterCount; //needed for emitter
   local int           ColorScaleCount; //needed for emitter
   local Color         C;
   local int           i; //needed for loop
   local int           j; //needed for secundary loop
   
   if ( ClientTriggerCount == TriggerCount ||
        ObjectName == "" ||
        ObjectName == "None" ||
        ObjectType == "" )
      return;
   
   ClientTriggerCount = TriggerCount;

   if ( ObjectType == "ColorModifier" )
   {
      ModifyColorModifier = ColorModifier(DynamicLoadObject(ObjectName, class'ColorModifier'));
      
      if ( ModifyColorModifier == None )
        return;
      
      C = ModifyColorModifier.Color;
      C = class'Canvas'.static.MakeColor(C.B, C.G, C.R);
      ModifyColorModifier.Color = C;
   }


   if ( ObjectType == "Emitter" )
   {
      ModifyEmitter = Emitter(DynamicLoadObject(ObjectName, class'Emitter'));
      
      if ( ModifyEmitter == None )
        return;
      
      ParticleEmitterCount = ModifyEmitter.Emitters.Length;

      for ( i = 0; i < ParticleEmitterCount; i++ ) //an emitter can have multiple particleemitters...
      {
         ColorScaleCount = ModifyEmitter.Emitters[i].ColorScale.Length;

         for ( j = 0; j < ColorScaleCount; j++ ) //...with multiple colorscales
         {
            C = ModifyEmitter.Emitters[i].ColorScale[j].Color;
            C = class'Canvas'.static.MakeColor(C.B, C.G, C.R); //switches red and blue around
            ModifyEmitter.Emitters[i].ColorScale[j].Color = C;
         }
      }
   }
}

// ============================================================================
// Default properties
// ============================================================================

defaultproperties
{
     bNetNotify=True
}
