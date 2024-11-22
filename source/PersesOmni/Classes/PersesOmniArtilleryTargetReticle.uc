/**
PersesArtilleryTargetReticle

Creation date: 2013-12-17 12:48
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniArtilleryTargetReticle extends ONSMortarTargetBeam;


//=============================================================================
// Properties
//=============================================================================

var float ReachableInitScale, ReachableScale, UnreachableScale;
var StaticMesh ReachableMesh, UnreachableMesh;


// controlled directly by camera
function Tick(float DeltaTime);


function SetStatus(bool bActivated)
{
	if (bReticleActivated != bActivated)
	{
		bReticleActivated = bActivated;
		if (bReticleActivated)
		{
			SetTimer(0.3, false);
			SetStaticMesh(ReachableMesh);
			SetDrawScale(ReachableInitScale);
		}
		else
		{
			SetTimer(0.0, false);
			SetStaticMesh(UnreachableMesh);
			SetDrawScale(UnreachableScale);
		}
	}
}


function Timer()
{
	SetDrawScale(ReachableScale);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ReachableInitScale=1.250000
     ReachableScale=1.000000
     UnreachableScale=0.800000
     ReachableMesh=StaticMesh'ONS-BPJW1.Meshes.Target'
     UnreachableMesh=StaticMesh'ONS-BPJW1.Meshes.TargetNo'
     bReticleActivated=False
     DrawScale3D=(X=7.000000,Y=7.000000,Z=3.000000)
}
