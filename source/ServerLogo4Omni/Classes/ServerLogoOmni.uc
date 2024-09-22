//=============================================================================
// ServerLogo
// Copyright 2003 by Wormbo <wormbo@onlinehome.de>
//
// Replicated the information for a logo displayed for players connecting.
//=============================================================================


class ServerLogoOmni extends ReplicationInfo
    config
    placeable
    hidecategories(Display,Advanced,Sound,Events);


//=============================================================================
// Enums
//=============================================================================

enum EFadeTransition {
  FT_None,
  FT_Linear,
  FT_Square,
  FT_Sqrt,
  FT_ReverseSquare,
  FT_ReverseSqrt,
  FT_Sin,
  FT_Smooth,
  FT_SquareSmooth,
  FT_SqrtSmooth,
  FT_ReverseSquareSmooth,
  FT_ReverseSqrtSmooth,
  FT_SinSmooth
};


//=============================================================================
// Structs
//=============================================================================

struct TScreenCoords {
  var() config float X;
  var() config float Y;
};

struct TTexRegion {
  var() config int X;
  var() config int Y;
  var() config int W;
  var() config int H;
};

// replicated as a struct to make sure everything arrives at the same time
struct TRepResources {
  var string Logo;
  var string FadeInSound;
  var string DisplaySound;
  var string FadeOutSound;
};


//=============================================================================
// Configuration
//=============================================================================

var(Logo)           config string          Logo;
var(Logo)           config color           LogoColor;
var(Logo)           config TTexRegion      LogoTexCoords;
var(Logo)           config int             StartLogoRotationRate;
var(Logo)           config int             LogoRotationRate;
var(Logo)           config int             EndLogoRotationRate;
var(LogoPosition)   config TScreenCoords   StartPos;
var(LogoPosition)   config TScreenCoords   Pos;
var(LogoPosition)   config TScreenCoords   EndPos;
var(LogoPosition)   config EDrawPivot      DrawPivot;
var(LogoScale)      config TScreenCoords   StartScale;
var(LogoScale)      config TScreenCoords   Scale;
var(LogoScale)      config TScreenCoords   EndScale;
var(LogoSound)      config array<string>   FadeInSound;
var(LogoSound)      config array<string>   DisplaySound;
var(LogoSound)      config array<string>   FadeOutSound;
var(LogoSound)      config bool            RandomFadeInSound;
var(LogoSound)      config bool            RandomDisplaySound;
var(LogoSound)      config bool            RandomFadeOutSound;
var(LogoSound)      config bool            AnnouncerSounds;
var(LogoTransition) config float           FadeInDuration;
var(LogoTransition) config float           DisplayDuration;
var(LogoTransition) config float           FadeOutDuration;
var(LogoTransition) config float           InitialDelay;
var(LogoTransition) config EFadeTransition FadeInRotationTransition;
var(LogoTransition) config EFadeTransition FadeOutRotationTransition;
var(LogoTransition) config EFadeTransition FadeInAlphaTransition;
var(LogoTransition) config EFadeTransition FadeOutAlphaTransition;
var(LogoTransition) config EFadeTransition FadeInScaleTransition;
var(LogoTransition) config EFadeTransition FadeOutScaleTransition;
var(LogoTransition) config EFadeTransition FadeInPosXTransition;
var(LogoTransition) config EFadeTransition FadeInPosYTransition;
var(LogoTransition) config EFadeTransition FadeOutPosXTransition;
var(LogoTransition) config EFadeTransition FadeOutPosYTransition;


//=============================================================================
// Variables
//=============================================================================

var() const editconst string Build;

var TRepResources   RLogoResources;
var color           RLogoColor;
var TTexRegion      RLogoTexCoords;
var int             RStartLogoRotationRate;
var int             RLogoRotationRate;
var int             REndLogoRotationRate;
var TScreenCoords   RStartPos;
var TScreenCoords   RPos;
var TScreenCoords   REndPos;
var TScreenCoords   RStartScale;
var TScreenCoords   RScale;
var TScreenCoords   REndScale;
var EDrawPivot      RDrawPivot;
var float           RFadeInDuration;
var float           RDisplayDuration;
var float           RFadeOutDuration;
var float           RInitialDelay;
var bool            RRandomFadeInSound;
var bool            RRandomDisplaySound;
var bool            RRandomFadeOutSound;
var string          RFadeInSound;
var string          RDisplaySound;
var string          RFadeOutSound;
var bool            RAnnouncerSounds;
var EFadeTransition RFadeInRotationTransition;
var EFadeTransition RFadeOutRotationTransition;
var EFadeTransition RFadeInScaleTransition;
var EFadeTransition RFadeOutScaleTransition;
var EFadeTransition RFadeInPosXTransition;
var EFadeTransition RFadeInPosYTransition;
var EFadeTransition RFadeOutPosXTransition;
var EFadeTransition RFadeOutPosYTransition;
var EFadeTransition RFadeInAlphaTransition;
var EFadeTransition RFadeOutAlphaTransition;

var float SpawnTime;
var bool bReceivedVars;


//=============================================================================
// Replication
//=============================================================================

replication
{
  reliable if ( Role == ROLE_Authority )
    RLogoResources, RLogoTexCoords, RDrawPivot, RLogoColor, RAnnouncerSounds,
    RStartLogoRotationRate, RLogoRotationRate, REndLogoRotationRate,
    RStartPos, RPos, REndPos, RStartScale, RScale, REndScale,
    RFadeInRotationTransition, RFadeOutRotationTransition,
    RFadeInAlphaTransition, RFadeOutAlphaTransition,
    RFadeInScaleTransition, RFadeOutScaleTransition,
    RFadeInPosXTransition, RFadeOutPosXTransition,
    RFadeInPosYTransition, RFadeOutPosYTransition,
    RFadeInDuration, RDisplayDuration, RFadeOutDuration, RInitialDelay;
}


//=============================================================================
// PostBeginPlay
//
// Replicate all config variables.
//=============================================================================

simulated function PostBeginPlay()
{
  local int i;
  Super.PostBeginPlay();
  
  
  if ( Role == ROLE_Authority ) {
    log(" ");
    log("ServerLogoOmni build"@Build);
    log("Original ServerLogo4 Code by Wormbo, extended for )o( by pooty");
    log(" ");
    SaveConfig();

    RLogoResources.Logo = Logo;
    // Add random code here, pooty 09/2024.
    i = FadeInSound.Length;
    if (i != 0) {
    		if (!RandomFadeInSound) RLogoResources.FadeInSound = FadeInSound[0];
        else RLogoResources.FadeInSound=FadeInSound[Rand(i)];
    }

   	i = DisplaySound.Length;    
    if (i != 0) {
        if (!RandomDisplaySound) RLogoResources.DisplaySound = DisplaySound[0];
        else RLogoResources.DisplaySound=DisplaySound[Rand(i)];
    }
    
    i = FadeOutSound.Length;
    if (i != 0) {
    if (!RandomFadeOutSound) RLogoResources.FadeOutSound = FadeOutSound[0];
    else RLogoResources.FadeOutSound=FadeOutSound[Rand(i)];
    }
    
    RAnnouncerSounds = AnnouncerSounds;
    
    if ( int(Level.EngineVersion) > 3186 )  UpdatePackageMap();
    
    RLogoColor = LogoColor;
    RLogoTexCoords = LogoTexCoords;
    RStartLogoRotationRate = StartLogoRotationRate;
    RLogoRotationRate = LogoRotationRate;
    REndLogoRotationRate = EndLogoRotationRate;
    RDrawPivot = DrawPivot;
    RFadeInRotationTransition = FadeInRotationTransition;
    RFadeOutRotationTransition = FadeOutRotationTransition;
    RFadeInScaleTransition = FadeInScaleTransition;
    RFadeOutScaleTransition = FadeOutScaleTransition;
    RFadeInPosXTransition = FadeInPosXTransition;
    RFadeInPosYTransition = FadeInPosYTransition;
    RFadeOutPosXTransition = FadeOutPosXTransition;
    RFadeOutPosYTransition = FadeOutPosYTransition;
    RFadeInAlphaTransition = FadeInAlphaTransition;
    RFadeOutAlphaTransition = FadeOutAlphaTransition;
    if ( FadeInAlphaTransition > FT_None || FadeInScaleTransition > FT_None
        || FadeInPosXTransition > FT_None || FadeInPosYTransition > FT_None
        || FadeInRotationTransition > FT_None )
      RFadeInDuration = FadeInDuration;
    RDisplayDuration = DisplayDuration;
    if ( FadeOutAlphaTransition > FT_None || FadeOutScaleTransition > FT_None
        || FadeOutPosXTransition > FT_None || FadeOutPosYTransition > FT_None
        || FadeOutRotationTransition > FT_None )
      RFadeOutDuration = FadeOutDuration;
    RInitialDelay = InitialDelay;
    RStartPos = StartPos;
    RPos = Pos;
    REndPos = EndPos;
    RStartScale = StartScale;
    RScale = Scale;
    REndScale = EndScale;
  }
}


//=============================================================================
// UpdatePackageMap
//
// Make sure the logo and sound packages are sent to clients.
//=============================================================================

function UpdatePackageMap()
{
  local int i;
  
  AddToPackageMap();
  if ( Logo != "" ) {
    i = InStr(Logo, ".");
    if ( i > -1 && DynamicLoadObject(Logo, class'Material', true) != None )
      AddToPackageMap(Left(Logo, i));
  }
  if ( RLogoResources.FadeInSound != "" ) {
    i = InStr(RLogoResources.DisplaySound, ".");
    if ( i > -1 && DynamicLoadObject(RLogoResources.DisplaySound, class'Sound', true) != None )
      AddToPackageMap(Left(RLogoResources.FadeInSound, i));
  }
  if ( RLogoResources.DisplaySound != "" ) {
    i = InStr(RLogoResources.DisplaySound, ".");
    if ( i > -1 && DynamicLoadObject(RLogoResources.DisplaySound, class'Sound', true) != None )
      AddToPackageMap(Left(RLogoResources.DisplaySound, i));
  }
  if ( RLogoResources.DisplaySound != "" ) {
    i = InStr(RLogoResources.DisplaySound, ".");
    if ( i > -1 && DynamicLoadObject(RLogoResources.DisplaySound, class'Sound', true) != None )
      AddToPackageMap(Left(RLogoResources.FadeOutSound, i));
  }
}


//=============================================================================
// PostNetBeginPlay
//
// Replicate all config variables.
//=============================================================================

simulated function PostNetBeginPlay()
{
  bReceivedVars = True;
  Enable('Tick');
}


//=============================================================================
// Tick
//
// Initialize the Interaction and load the logo texture.
//=============================================================================

simulated function Tick(float DeltaTime)
{
  local PlayerController LocalPlayer;
  local Interaction MyInteraction;
  
  if ( !bReceivedVars || Level.NetMode == NM_DedicatedServer ) {
    Disable('Tick');
    return;
  }
  else if ( RLogoResources.Logo == "" ) {
    return;
  }
  else if ( SpawnTime == 0.0 )
    SpawnTime = Level.TimeSeconds;
  
  //log(Level.TimeSeconds@"LevelAction:"@Level.LevelAction);
  
  if ( Level.TimeSeconds - SpawnTime < RInitialDelay )
    return;
  
  LocalPlayer = Level.GetLocalPlayerController();
  if ( LocalPlayer != None )
    MyInteraction = LocalPlayer.Player.InteractionMaster.AddInteraction(string(class'ServerLogoOmniInteraction'), LocalPlayer.Player);
  
  if ( ServerLogoOmniInteraction(MyInteraction) != None )
    ServerLogoOmniInteraction(MyInteraction).ServerLogoOmni = Self;
  
  //log(Level.TimeSeconds@"Spawned"@MyInteraction@"for"@LocalPlayer);
  Disable('Tick');
}


//=============================================================================
// Default Properties
//=============================================================================

defaultproperties
{
     Logo="MenuEffects.ScoreBoard.ScoreBoardU"
     LogoColor=(B=255,G=255,R=255,A=255)
     StartPos=(X=0.500000)
     pos=(X=0.500000,Y=0.300000)
     EndPos=(X=0.500000,Y=0.500000)
     DrawPivot=DP_LowerMiddle
     StartScale=(X=1.000000,Y=1.000000)
     Scale=(X=1.000000,Y=1.000000)
     EndScale=(X=3.000000,Y=3.000000)
     FadeInDuration=3.000000
     DisplayDuration=5.000000
     FadeOutDuration=1.500000
     InitialDelay=8.000000
     FadeOutAlphaTransition=FT_Linear
     FadeOutScaleTransition=FT_Linear
     FadeInPosYTransition=FT_Smooth
     FadeOutPosYTransition=FT_Linear
     Build="2024-09-22 16:00"
}
