//=============================================================================
// ServerLogoInteraction
// Copyright 2003 by Wormbo <wormbo@onlinehome.de>
//
// Displays a logo for players connecting.
//=============================================================================


class ServerLogoOmniInteraction extends Interaction
    dependson(ServerLogoOmni);


//=============================================================================
// Imports
//=============================================================================

#exec obj load file=..\Textures\UT2003Fonts.utx package=UT2003Fonts


//=============================================================================
// Constants
//=============================================================================

const STY_Alpha = 5;


//=============================================================================
// Variables
//=============================================================================

var ServerLogoOmni ServerLogoOmni;
var Material   LogoMaterial;
var TexRotator RotatingLogoMaterial;
var Sound      FadeInSound;
var Sound      DisplaySound;
var Sound      FadeOutSound;
var float      StartupTime;
var bool       RandomFadeInSound;
var bool            RandomDisplaySound;
var bool            RandomFadeOutSound;
var bool bDisplayingLogo;
var bool bFadingIn, bDisplaying, bFadingOut;
var config ServerLogoOmni.EFadeTransition TestTransition;


//=============================================================================
// Remove
//
// Unregisters the interaction.
//=============================================================================

function Remove()
{
  if ( RotatingLogoMaterial != None ) {
    RotatingLogoMaterial.Material = None;
    RotatingLogoMaterial.FallbackMaterial = None;
    ViewportOwner.Actor.Level.ObjectPool.FreeObject(RotatingLogoMaterial);
    RotatingLogoMaterial = None;
  }
  LogoMaterial = None;
  ServerLogoOmni = None;
  Master.RemoveInteraction(Self);
}


//=============================================================================
// NotifyLevelChange
//
// Removes the interaction on level change.
//=============================================================================

event NotifyLevelChange()
{
  Remove();
}


//=============================================================================
// PostRender
//
// Draws the logo.
//=============================================================================

event PostRender(Canvas C)
{
  local float AlphaFadeIn;
  local float AlphaFadeOut;
  local float X, Y, W, H;
  
  if ( ServerLogoOmni == None || ServerLogoOmni.RLogoResources.Logo == "" ) {
    return;
  }
  
  if ( LogoMaterial == None && ServerLogoOmni.RLogoResources.Logo != "" ) {
    LogoMaterial = Material(DynamicLoadObject(ServerLogoOmni.RLogoResources.Logo, class'Material'));
    if ( LogoMaterial == None ) {
      Remove();
      return;
    }
    if ( ServerLogoOmni.RLogoTexCoords.W == 0 ) {
      if ( Texture(LogoMaterial) != None )
        ServerLogoOmni.RLogoTexCoords.W = Texture(LogoMaterial).USize;
      else
        ServerLogoOmni.RLogoTexCoords.W = LogoMaterial.MaterialUSize();
    }
    if ( ServerLogoOmni.RLogoTexCoords.H == 0 ) {
      if ( Texture(LogoMaterial) != None )
        ServerLogoOmni.RLogoTexCoords.H = Texture(LogoMaterial).VSize;
      else
        ServerLogoOmni.RLogoTexCoords.H = LogoMaterial.MaterialVSize();
    }
    if ( ServerLogoOmni.RLogoRotationRate != 0 ) {
      RotatingLogoMaterial = TexRotator(ViewportOwner.Actor.Level.ObjectPool.AllocateObject(class'TexRotator'));
      if ( RotatingLogoMaterial != None ) {
        RotatingLogoMaterial.Material = LogoMaterial;
        RotatingLogoMaterial.FallbackMaterial = LogoMaterial;
        RotatingLogoMaterial.TexRotationType = TR_ConstantlyRotating;
        RotatingLogoMaterial.Rotation.Yaw = ServerLogoOmni.RLogoRotationRate;
        RotatingLogoMaterial.UOffset = float(ServerLogoOmni.RLogoTexCoords.W) * 0.5;
        RotatingLogoMaterial.VOffset = float(ServerLogoOmni.RLogoTexCoords.H) * 0.5;
        RotatingLogoMaterial.TexCoordCount = TCN_2DCoords;
        RotatingLogoMaterial.TexCoordProjected = False;
        LogoMaterial = RotatingLogoMaterial;
      }
    }
    
    if ( ServerLogoOmni.RLogoResources.FadeInSound != "" ) {
      FadeInSound = Sound(DynamicLoadObject(ServerLogoOmni.RLogoResources.FadeInSound, class'Sound', True));
      if ( ServerLogoOmni.RAnnouncerSounds )
        FadeInSound = ViewportOwner.Actor.CustomizeAnnouncer(FadeInSound);
    }
    if ( ServerLogoOmni.RLogoResources.DisplaySound != "" ) {
      DisplaySound = Sound(DynamicLoadObject(ServerLogoOmni.RLogoResources.DisplaySound, class'Sound', True));
      if ( ServerLogoOmni.RAnnouncerSounds )
        DisplaySound = ViewportOwner.Actor.CustomizeAnnouncer(DisplaySound);
    }
    if ( ServerLogoOmni.RLogoResources.FadeOutSound != "" ) {
      FadeOutSound = Sound(DynamicLoadObject(ServerLogoOmni.RLogoResources.FadeOutSound, class'Sound', True));
      if ( ServerLogoOmni.RAnnouncerSounds )
        FadeOutSound = ViewportOwner.Actor.CustomizeAnnouncer(FadeOutSound);
    }
    return;
  }
  
  if ( TestTransition != FT_None ) {
    TransitionsTest(C);
    return;
  }
  if ( StartupTime == 0 || !bDisplayingLogo ) {
    StartupTime = ServerLogoOmni.Level.TimeSeconds;
    //log(ServerLogoOmni.Level.TimeSeconds@"Start rendering server logo");
  }
  
  AlphaFadeIn  = FClamp(ServerLogoOmni.Level.TimeSeconds - StartupTime,
      0, ServerLogoOmni.RFadeInDuration)
      / ServerLogoOmni.RFadeInDuration;
  AlphaFadeOut = FClamp(ServerLogoOmni.Level.TimeSeconds - (StartupTime
      + ServerLogoOmni.RFadeInDuration + ServerLogoOmni.RDisplayDuration),
      0, ServerLogoOmni.RFadeOutDuration)
      / ServerLogoOmni.RFadeOutDuration;
  
  C.Reset();
  C.Style = STY_Alpha;
  C.DrawColor = ServerLogoOmni.RLogoColor;
  
  if ( AlphaFadeIn < 1.0 ) {
    bDisplayingLogo = True;
    if ( !bFadingIn ) {
      bFadingIn = True;
      if ( FadeInSound != None )
        ViewportOwner.Actor.ClientPlaySound(FadeInSound);
    }
    
    C.DrawColor.A = FadeIn(AlphaFadeIn, 0, ServerLogoOmni.RLogoColor.A, ServerLogoOmni.RFadeInAlphaTransition);
    X = FadeIn(AlphaFadeIn, ServerLogoOmni.RStartPos.X, ServerLogoOmni.RPos.X, ServerLogoOmni.RFadeInPosXTransition);
    Y = FadeIn(AlphaFadeIn, ServerLogoOmni.RStartPos.Y, ServerLogoOmni.RPos.Y, ServerLogoOmni.RFadeInPosYTransition);
    W = FadeIn(AlphaFadeIn, ServerLogoOmni.RStartScale.X, ServerLogoOmni.RScale.X, ServerLogoOmni.RFadeInScaleTransition);
    H = FadeIn(AlphaFadeIn, ServerLogoOmni.RStartScale.Y, ServerLogoOmni.RScale.Y, ServerLogoOmni.RFadeInScaleTransition);
  }
  else if ( AlphaFadeOut == 0 ) {
    bDisplayingLogo = True;
    if ( !bDisplaying ) {
      bDisplaying = True;
      if ( DisplaySound != None )
        ViewportOwner.Actor.ClientPlaySound(DisplaySound);
    }
    
    C.DrawColor.A = ServerLogoOmni.RLogoColor.A;
    X = ServerLogoOmni.RPos.X;
    Y = ServerLogoOmni.RPos.Y;
    W = ServerLogoOmni.RScale.X;
    H = ServerLogoOmni.RScale.Y;
  }
  else if ( AlphaFadeOut < 1.0 ) {
    bDisplayingLogo = True;
    if ( !bFadingOut ) {
      bFadingOut = True;
      if ( FadeOutSound != None )
        ViewportOwner.Actor.ClientPlaySound(FadeOutSound);
    }
    
    C.DrawColor.A = FadeOut(AlphaFadeOut, ServerLogoOmni.RLogoColor.A, 0, ServerLogoOmni.RFadeOutAlphaTransition);
    X = FadeOut(AlphaFadeOut, ServerLogoOmni.RPos.X, ServerLogoOmni.REndPos.X, ServerLogoOmni.RFadeOutPosXTransition);
    Y = FadeOut(AlphaFadeOut, ServerLogoOmni.RPos.Y, ServerLogoOmni.REndPos.Y, ServerLogoOmni.RFadeOutPosYTransition);
    W = FadeOut(AlphaFadeOut, ServerLogoOmni.RScale.X, ServerLogoOmni.REndScale.X, ServerLogoOmni.RFadeOutScaleTransition);
    H = FadeOut(AlphaFadeOut, ServerLogoOmni.RScale.Y, ServerLogoOmni.REndScale.Y, ServerLogoOmni.RFadeOutScaleTransition);
  }
  else {
    //log(ServerLogoOmni.Level.TimeSeconds@"Fade Out Done");
    //ViewportOwner.Actor.ClientMessage("Fade Out Done");
    Remove();
    return;
  }
  
  //log(ServerLogoOmni.Level.TimeSeconds@X@Y@W@H);
  
  DrawScreenTexture(C, LogoMaterial, X, Y,
      W * ServerLogoOmni.RLogoTexCoords.W, H * ServerLogoOmni.RLogoTexCoords.H,
      ServerLogoOmni.RLogoTexCoords, ServerLogoOmni.RDrawPivot);
}


//=============================================================================
// DrawScreenTexture
//
// Draws a material at the specified screen location.
//=============================================================================

function DrawScreenTexture(Canvas C, Material M, float X, float Y, float W, float H,
    ServerLogoOmni.TTexRegion R, EDrawPivot Pivot)
{
  X *= C.SizeX;
  Y *= C.SizeY;
  
  W *= C.SizeX  / 1024.0;
  H *= C.SizeY / 768.0;
  
  switch (Pivot) {
  case DP_UpperLeft:
    break;
  case DP_UpperMiddle:
    X -= W * 0.5;
    break;
  case DP_UpperRight:
    X -= W;
    break;
  case DP_MiddleRight:
    X -= W;
    Y -= H * 0.5;
    break;
  case DP_LowerRight:
    X -= W;
    Y -= H;
    break;
  case DP_LowerMiddle:
    X -= W * 0.5;
    Y -= H;
    break;
  case DP_LowerLeft:
    Y -= H;
    break;
  case DP_MiddleLeft:
    Y -= H * 0.5;
    break;
  case DP_MiddleMiddle:
    X -= W * 0.5;
    Y -= H * 0.5;
    break;
  }
  
  //log("Drawn"@X@Y@W@H);
  
  C.SetPos(X, Y);
  C.DrawTileClipped(M, W, H, R.X, R.Y, R.W, R.H);
}


//=============================================================================
// FadeIn
//
// Fades a value between a start value and an end value using the specified
// fading method to apply.
//=============================================================================

function float FadeIn(float Alpha, float Start, float End, ServerLogoOmni.EFadeTransition Method)
{
  switch (Method) {
  Case FT_None:
    return End;
  Case FT_Linear:
    return Lerp(Alpha, Start, End);
  Case FT_Square:
    return Lerp(Square(Alpha), Start, End);
  Case FT_Sqrt:
    return Lerp(Sqrt(Alpha), Start, End);
  Case FT_ReverseSquare:
    return Lerp(1-Square(1-Alpha), Start, End);
  Case FT_ReverseSqrt:
    return Lerp(1-Sqrt(1-Alpha), Start, End);
  Case FT_Sin:
    return Lerp(0.5 - 0.5 * Cos(Alpha * Pi), Start, End);
  Case FT_Smooth:
    return Smerp(Alpha, Start, End);
  Case FT_SquareSmooth:
    return Smerp(Square(Alpha), Start, End);
  Case FT_SqrtSmooth:
    return Smerp(Sqrt(Alpha), Start, End);
  Case FT_ReverseSquareSmooth:
    return Smerp(1-Square(1-Alpha), Start, End);
  Case FT_ReverseSqrtSmooth:
    return Smerp(1-Sqrt(1-Alpha), Start, End);
  Case FT_SinSmooth:
    return Smerp(0.5 - 0.5 * Cos(Alpha * Pi), Start, End);
  }
}


//=============================================================================
// FadeOut
//
// Like FadeIn, but reversed direction.
//=============================================================================

function float FadeOut(float Alpha, float Start, float End, ServerLogoOmni.EFadeTransition Method)
{
  if ( Method == FT_None )
    return Start;
  else
    return FadeIn(Alpha, Start, End, Method);
}


//=============================================================================
// TransitionsTest
//
// Draws patterns of all transitions and saves them as screenshots.
//=============================================================================

function TransitionsTest(Canvas C)
{
  local float x, y;
  
  C.Reset();
  C.Style = STY_Alpha;
  C.DrawColor.R = 255;
  C.DrawColor.G = 255;
  C.DrawColor.B = 255;
  C.DrawColor.A = 255;
  C.SetPos(0,0);
  C.DrawTile(Texture'WhiteTexture', C.SizeX, C.SizeY, 0, 0, Texture'WhiteTexture'.USize, Texture'WhiteTexture'.VSize);
  
  C.DrawColor.A = 32;
  for (x = C.OrgX; x < C.SizeX; x += 0.1) {
    y = FadeIn(x / C.SizeX, C.OrgY, C.SizeY-1, TestTransition);
    C.SetPos(x,y);
    C.DrawTile(Texture'BlackTexture', 1, 1, 0, 0, Texture'BlackTexture'.USize, Texture'BlackTexture'.VSize);
  }
  
  C.DrawColor.R = 0;
  C.DrawColor.G = 0;
  C.DrawColor.B = 0;
  C.DrawColor.A = 255;
  C.Font = Font'FontNeuzeit14';
  C.DrawScreenText(string(GetEnum(enum'EFadeTransition', TestTransition)), 0.02, 0.98, DP_LowerLeft);
  
  ConsoleCommand("shot");
  switch (TestTransition) {
  case FT_Linear:
    TestTransition = FT_Square;
    break;
  case FT_Square:
    TestTransition = FT_Sqrt;
    break;
  case FT_Sqrt:
    TestTransition = FT_ReverseSquare;
    break;
  case FT_ReverseSquare:
    TestTransition = FT_ReverseSqrt;
    break;
  case FT_ReverseSqrt:
    TestTransition = FT_Sin;
    break;
  case FT_Sin:
    TestTransition = FT_Smooth;
    break;
  case FT_Smooth:
    TestTransition = FT_SquareSmooth;
    break;
  case FT_SquareSmooth:
    TestTransition = FT_SqrtSmooth;
    break;
  case FT_SqrtSmooth:
    TestTransition = FT_ReverseSquareSmooth;
    break;
  case FT_ReverseSquareSmooth:
    TestTransition = FT_ReverseSqrtSmooth;
    break;
  case FT_ReverseSqrtSmooth:
    TestTransition = FT_SinSmooth;
    break;
  case FT_SinSmooth:
    TestTransition = FT_None;
  }
}


//=============================================================================
// Default Properties
//=============================================================================

defaultproperties
{
     RotatingLogoMaterial=TexRotator'ServerLogo4.ServerLogoInteraction.LogoRotator'
     bVisible=True
}
