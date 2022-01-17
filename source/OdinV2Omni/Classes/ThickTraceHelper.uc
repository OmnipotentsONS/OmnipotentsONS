/******************************************************************************
ThickTraceHelper

Creation date: 2013-02-17 14:44
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class ThickTraceHelper extends Actor notplaceable;


struct THitInfo
{
	var float HitDistance;
	var Actor HitActor;
	var vector HitLocation, HitNormal;
};

var array<Actor> Hits;


// Collects all actors a trace from start to end would hit, but ignores world geometry.
static function array<THitInfo> TraceHits(Actor Requester, vector Start, vector End, float TraceRadius)
{
	local ThickTraceHelper Helper;
	local vector CurrentLocation, NextLocation, TraceDir, TraceExtent;
	local float CurrentPos, NextPos, TraceLength, TraceStep;
	local array<THitInfo> HitInfos;
	local THitInfo HitInfo;
	local int i, j;

	Helper = Requester.Spawn(default.Class, None, '', Start);
	if (Helper != None)
	{
		Helper.SetCollisionSize(TraceRadius * 1.2, TraceRadius * 1.2);
		Helper.SetCollision(True, False, False);

		TraceDir = End - Start;
		TraceLength = VSize(TraceDir);
		TraceDir /= TraceLength;
		TraceExtent = vect(1,1,1) * TraceRadius;
		TraceStep = TraceLength / int(TraceLength / 1000.0 + 1) + 1;
		//log("Trace helper " $ Start @ End @ TraceDir @ TraceLength @ TraceStep);

		CurrentPos = 0;
		CurrentLocation = Start;
		do {
			NextPos = FMin(CurrentPos + TraceStep, TraceLength);
			NextLocation = Start + TraceDir * NextPos;
			//log("Trace step " $ CurrentPos @ CurrentLocation @ NextPos @ NextLocation);

			Helper.Move(NextLocation - CurrentLocation);

			for (i = 0; i < Helper.Hits.Length; i++)
			{
				if (Helper.Hits[i] != None && Helper.Hits[i] != Requester && !Helper.Hits[i].TraceThisActor(HitInfo.HitLocation, HitInfo.HitNormal, NextLocation, CurrentLocation, TraceExtent))
				{
					HitInfo.HitActor = Helper.Hits[i];
					HitInfo.HitDistance = (HitInfo.HitLocation - Start) dot TraceDir;

					//log("Trace hit " $ HitInfo.HitActor @ HitInfo.HitDistance @ HitInfo.HitLocation @ HitInfo.HitNormal);

					// ensure the hits are ordered by distance
					for (j = HitInfos.Length; j > 0 && HitInfos[j - 1].HitDistance > HitInfo.HitDistance; j--)
					{
						// move on, nothing to see here
					}
					HitInfos.Insert(j, 1);
					HitInfos[j] = HitInfo;
				}
				else
				{
					//log("Trace miss " $ Helper.Hits[i]);
				}
			}
			Helper.Hits.Length = 0;

			CurrentPos = NextPos;
			CurrentLocation = NextLocation;

		} until (NextPos >= TraceLength);

		Helper.Destroy();
	}

	return HitInfos;
}


function FellOutOfWorld(eKillZType KillType); // don't care


function Touch(Actor Other)
{
	//log("Trace candidate " $ Other);
	Hits[Hits.Length] = Other;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     bHidden=True
     bAcceptsProjectors=False
     bIgnoreEncroachers=True
     RemoteRole=ROLE_None
     bIgnoreOutOfWorld=True
}
