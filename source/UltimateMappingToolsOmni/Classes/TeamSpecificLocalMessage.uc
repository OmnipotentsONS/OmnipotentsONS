// ============================================================================
// TeamSpecificLocalMessage, v2.0 @ 31-7-2005 13:33:37
// Made by Robin 'Jrubzjeknf' van Olst <rrvanolst@hotmail.com>
//
// The LocalMessage sent to players when they shouldn't be using that actor.
// Has an adjustable string, Color and Lifetime. Checks for various errors too.
//
// Full documentation on TeamSpecificActors_v2.u can be downloaded from:
// http://unrealized-potential.com/forum/index.php?act=Attach&type=post&id=5135
//=============================================================================
class TeamSpecificLocalMessage extends LocalMessage;

//=============================================================================
// GetString
//
// Make a real string out of the dynamic string, set color and lifetime.
//=============================================================================
static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject )
{
   local TeamSpecificPhysicsVolume      PV;
   local TeamSpecificTeleporter         T;
   local TeamSpecificTriggerableJumpPad TJP;
   local TeamSpecificWeaponLocker       WL;
   local string                         s;
   local bool                           ValidOptionalObject;

   ValidOptionalObject = false;
   s = "ERROR";

   if ( TeamSpecificPhysicsVolume(OptionalObject) != None )
   {
      PV = TeamSpecificPhysicsVolume(OptionalObject);

      if ( RelatedPRI_1.Team.TeamIndex == 0 )
      {
         default.DrawColor = PV.MessageColor0;
         default.Lifetime =  PV.MessageLifetime0;
         s = PV.CurrentMessage0;
      }
      
      if ( RelatedPRI_1.Team.TeamIndex == 1 )
      {
         default.DrawColor = PV.MessageColor1;
         default.Lifetime =  PV.MessageLifetime1;
         s = PV.CurrentMessage1;
      }
      
      ValidOptionalObject = true;
   }

   if ( TeamSpecificTeleporter(OptionalObject) != None )
   {
      T = TeamSpecificTeleporter(OptionalObject);
      default.DrawColor = T.DeniedMessageColor;
      default.Lifetime =  T.DeniedMessageLifetime;
      s = T.CurrentMessage;
      
      ValidOptionalObject = true;
   }

   if ( TeamSpecificTriggerableJumpPad(OptionalObject) != None )
   {
      TJP = TeamSpecificTriggerableJumpPad(OptionalObject);
      default.DrawColor = TJP.DeniedMessageColor;
      default.Lifetime =  TJP.DeniedMessageLifetime;
      s = TJP.CurrentMessage;
      
      ValidOptionalObject = true;
   }

   if ( TeamSpecificWeaponLocker(OptionalObject) != None )
   {
      WL = TeamSpecificWeaponLocker(OptionalObject);
      default.DrawColor = WL.DeniedMessageColor;
      default.Lifetime =  WL.DeniedMessageLifetime;
      s = WL.CurrentMessage;
      
      ValidOptionalObject = true;
   }
   
   if ( !ValidOptionalObject )
   {   log("!!!!!!!!! Did not recognize OptionalObject " $ OptionalObject $ " !!!!!!!!!", 'TeamSpecificLocalMessage');
       return s; }

   if ( default.DrawColor.A == 0 )
      log("!!! Attempted to send a message with 0 Alpha (appears invisible). This log was caused by " $ OptionalObject  $ " !!!", 'TeamSpecificLocalMessage');

   if ( default.Lifetime <= 0 )
      log("!!! Attempted to send a message with a lifetime equal or smaller than 0. This log was caused by " $ OptionalObject  $ " !!!", 'TeamSpecificLocalMessage');

   if ( s == "" )
      log("!!! Attempted to send a message with a blank string. This log was caused by " $ OptionalObject  $ " !!!", 'TeamSpecificLocalMessage');

   return s;
}

static final function Color RGBtoBGR(Color C)
{ return class'Canvas'.static.MakeColor(C.B, C.G, C.R); }


//=============================================================================
// MakeDynamicString
//=============================================================================
static final function string MakeDynamicString(string s, int BelongsToTeam)
{
   local string Team;
   local string EnemyTeam;
   local string CTeam;
   local string CEnemyTeam;
   local string FCTeam;
   local string FCEnemyTeam;

   if ( s == "" )
      return "";

   if ( BelongsToTeam == 0 )
   {
      Team = "red";
      EnemyTeam = "blue";
      CTeam = "Red";
      CEnemyTeam = "Blue";
      FCTeam = "RED";
      FCEnemyTeam = "BLUE";
   }
   else
   {
      Team = "blue";
      EnemyTeam = "red";
      CTeam = "Blue";
      CEnemyTeam = "Red";
      FCTeam = "BLUE";
      FCEnemyTeam = "RED";
   }

   StaticReplaceText(s, "%ot", Team);
   StaticReplaceText(s, "%Ot", CTeam);
   StaticReplaceText(s, "%OT", FCTeam);
   StaticReplaceText(s, "%et", EnemyTeam);
   StaticReplaceText(s, "%Et", CEnemyTeam);
   StaticReplaceText(s, "%ET", FCEnemyTeam);
   
   return s;
}


//=============================================================================
// StaticReplaceText
//=============================================================================
static final function StaticReplaceText(out string Text, string Replace, string With)
{
  local int i;
  local string Input;
    
  Input = Text;
  Text = "";
  i = InStr(Input, Replace);
  while(i != -1) {  
    Text = Text $ Left(Input, i) $ With;
    Input = Mid(Input, i + Len(Replace));  
    i = InStr(Input, Replace);
  }
  Text = Text $ Input;
}

//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     bIsUnique=True
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=0,G=0,R=0)
     StackMode=SM_Down
     PosY=0.500000
}
