// pgPortalDecal - Implementation of warping code and visual portal effects
/*
	Credits:
		- Code by John "Shambler" Barrett (Shambler@OldUnreal.com, Shambler__@Hotmail.com, ICQ: 108730864)
		- Portal and projectile effects by Fuegerstef
		- Weapon model artwork by Myles Lambert (Myles@lambert.demon.co.uk)
		- Custom crosshair by Kel "Kyllian" Siros (Kyllian@gmail.com)
		- Vehicle teleportation code adapted and improved from code done by VitalOverdose (obtained from the Wiki: http://wiki.beyondunreal.com)
*/

// TODO: This class needs serious cleaning (the growth/shrinking code especially, the warping code can be left messy while you experiment with it)
// N.B. The first step can be to replace all the FMin FMax's with FClamp's

Class CSMarvinPortalDecal extends Actor;


////#exec AUDIO IMPORT File="Sounds\PortalEntry.wav" Name="PortalEntry"
//#exec AUDIO IMPORT File="Sounds\PortalGrow.wav" Name="PortalGrow"
//#exec AUDIO IMPORT File="Sounds\PortalShrink.wav" Name="PortalShrink"
#exec OBJ LOAD File="Data\PortalGun.u" Package=CSMarvin
////#exec AUDIO IMPORT File="Sounds\PortalAmbientSound.wav" Name="PortalAmbientSound"


// Scripted texture related variables
var ScriptedTexture PortalTex;
var float TexRes;
var int FramerateDivider;
var int FrameCount;
var int NumPortals;


// Growth/Shrinking variables
var float GrowthTime;
var float DesiredGrowth;
var float StartingGrowthEnergy;
var float MaxShrinkage; // Minimum MANUALLY SET drawscale (i.e. from shooting the portal)
var float MaxGrowth;
var bool bFinishedGrowth;

// Related variables set by the mutator
var bool bForceMinimumGrowth;
var float DefaultDrawscale; // Used to hack drawscale changes (effectivly acts as minimum drawscale)


// General variables
var CSMarvinPortalDecal OtherSide;
var int FireMode;
var bool bDischarging; // The portal is dissapating after being hit by a discharge projectile
var RenderDevice rDev;


replication
{
	// Optimise the code and get rid of some of these
	reliable if (Role == ROLE_Authority && bNetInitial)
		bForceMinimumGrowth, FireMode, DefaultDrawScale, StartingGrowthEnergy;

	reliable if (Role == ROLE_Authority)
		OtherSide, DesiredGrowth;
}


simulated function PostNetBeginPlay()
{
	local CSMarvinPortalDecal pd;
	local string sTempStr;
	local float GrowthScale;
	local FinalBlend MainTex;
	local float ResX, ResY;


	// Setup the initial growth-spurt (might be overriden below if linking to another portal)
	SetGrowth(StartingGrowthEnergy);

	// Search for other portals owned by the same player
	foreach DynamicActors(Class'CSMarvinPortalDecal', pd)
	{
		if (Level.Netmode != NM_Client && pd != self && pd.Owner != none && pd.Owner == Owner && !pd.bDischarging)
		{
			// If the player has already created a portal using the same firemode, destroy that other portal (and 'steal' any linked portals)
			if (pd.FireMode == FireMode)
			{
				if (pd.OtherSide != none)
				{
					OtherSide = pd.OtherSide;
					pd.OtherSide.OtherSide = Self;
				}

				pd.Destroy();
			}
			else
			{
				OtherSide = pd;
				pd.OtherSide = self;
			}


			// Setup growth of this portal relative to the OtherSide portal
			if (OtherSide != none)
			{
				GrowthScale = FMax(FMax(OtherSide.DefaultDrawScale, OtherSide.DrawScale/*3D.Y*/), StartingGrowthEnergy);
				SetGrowth(GrowthScale);

				if (OtherSide.DesiredGrowth != GrowthScale)
					OtherSide.SetGrowth(GrowthScale);
			}


			continue;
		}


		// Keep track of existing portals
		if (Level.Netmode != NM_DedicatedServer)
		{
			NumPortals++;
			pd.UpdateList(True);
		}
	}


	// Setup clientside portal textures
	if (Level.Netmode != NM_DedicatedServer)
	{
		// Grab a reference to the current render device, a hack fix for the UseStencil option breaking either warp zones or drawportal
		rDev = GameEngine(FindObject("Package.GameEngine", Class'GameEngine')).GRenDev;


		// Work out the best scripted texture size (based upon screen resoloution)
		sTempStr = Level.GetLocalPlayerController().ConsoleCommand("GetCurrentRes");

		ResY = InStr(sTempStr, "x");

		// Uses logs to find the 'lowest power of 2' that fits the X/Y resoloution
		ResX = 2 ** (int(loge(float(Left(sTempStr, ResY))) / loge(2.0)) /*+ int(bDoubleRes)*/);
		ResY = 2 ** (int(loge(float(Mid(sTempStr, ResY+1))) / loge(2.0)) /*+ int(bDoubleRes)*/);

		if (ResX < ResY)
			TexRes = ResX;
		else
			TexRes = ResY;


		// Force the other sides texture to update aswel
		if (OtherSide != none)
			OtherSide.PortalTex.Revision++;


		// Setup the actual textures for this portal
		if (PortalTex == none)
			PortalTex = ScriptedTexture(Level.ObjectPool.AllocateObject(Class'ScriptedTexture'));

		PortalTex.Client = self;
		PortalTex.SetSize(TexRes, TexRes);


		// These texture effects provided by Fuegerstef
		Skins[0] = FinalBlend(Level.ObjectPool.AllocateObject(Class'FinalBlend'));


		if (FireMode == 0)
		{
			MainTex = FinalBlend'PortalPrimary';
			Skins[1] = FinalBlend'PlasmaPrimary';
		}
		else
		{
			MainTex = FinalBlend'PortalSecondary';
			Skins[1] = FinalBlend'PlasmaSecondary';
		}

		FinalBlend(Skins[0]).FrameBufferBlending = MainTex.FrameBufferBlending;
		FinalBlend(Skins[0]).ZWrite = MainTex.ZWrite;
		FinalBlend(Skins[0]).Material = Combiner(Level.ObjectPool.AllocateObject(Class'Combiner'));
		FinalBlend(Skins[0]).FallbackMaterial = FinalBlend(Skins[0]).Material;

		// If your re-using a discarded modifier (from the levels object pool) then it might still retain its old values, reset them all
		FinalBlend(Skins[0]).ZTest = MainTex.ZTest;
		FinalBlend(Skins[0]).AlphaTest = MainTex.AlphaTest;
		FinalBlend(Skins[0]).TwoSided = MainTex.TwoSided;
		FinalBlend(Skins[0]).AlphaRef = MainTex.AlphaRef;

		Combiner(FinalBlend(Skins[0]).Material).CombineOperation = Combiner(MainTex.Material).CombineOperation;
		Combiner(FinalBlend(Skins[0]).Material).Material1 = PortalTex;
		Combiner(FinalBlend(Skins[0]).Material).Material2 = Combiner(MainTex.Material).Material2;
		Combiner(FinalBlend(Skins[0]).Material).Mask = Combiner(MainTex.Material).Mask;

		Combiner(FinalBlend(Skins[0]).Material).AlphaOperation = Combiner(MainTex.Material).AlphaOperation;
		Combiner(FinalBlend(Skins[0]).Material).InvertMask = Combiner(MainTex.Material).InvertMask;
		Combiner(FinalBlend(Skins[0]).Material).Modulate2X = Combiner(MainTex.Material).Modulate2X;
		Combiner(FinalBlend(Skins[0]).Material).Modulate4X = Combiner(MainTex.Material).Modulate4X;


		Skins[2] = Texture'CollisionInvisible';



		PortalTex.Revision++;
	}


	// Start with a drawscale of 0 and make the portal 'grow', so as to make the portal seem to appear out of nothing
	//SetDrawScale3D(vect(0,0,0));
	SetDrawScale(0);
	Enable('Tick');
}

// Update texture size and framerate based upon the number of portals in the map (needs tweaking as FPS can still crawl with a lot of portals)
simulated function UpdateList(bool bNewPortal)
{
	local int NewSize;

	NumPortals += 1 - (2 * int(bNewPortal));

	if (PortalTex != none)
	{
		if (NumPortals >= 2)
		{
			NewSize = TexRes / (NumPortals / 2);
			PortalTex.SetSize(NewSize, NewSize);

			FramerateDivider = default.FramerateDivider * (NumPortals / 2);
		}
		else
		{
			PortalTex.SetSize(TexRes, TexRes);
			FramerateDivider = default.FramerateDivider;
		}
	}
}

// Handle scripted texture ticking and portal growth
simulated function Tick(float DeltaTime)
{
	local float OldDrawScale, NewDrawscale;
	local vector FinalDrawScale;

	// Test code to debug the warping functions
	//local vector OrigLoc, EndLoc;
	//local coords ThisCoords, OtherCoords;


	// Portal is still growing/shrinking (TODO: If the portal growth fails during this tick then find a way to determine the maximum portal size instead of using the last drawscale)
	if (!bFinishedGrowth)
	{
		// The Z component of drawscale3d is always 1, XY parts represent the 'true' drawscale
		OldDrawScale = DrawScale/*3D.Y*/;

		// Determine the amount of growth to apply during this tick
		if (DrawScale/*3D.Y*/ < DefaultDrawScale && DesiredGrowth > DrawScale/*3D.Y*/)
			NewDrawScale = FMin(DesiredGrowth, DrawScale/*3D.Y*/ + (DeltaTime / GrowthTime));
		else if (DesiredGrowth > DrawScale/*3D.Y*/)
			NewDrawScale = FMin(DesiredGrowth, DrawScale/*3D.Y*/ + (DeltaTime / (GrowthTime * 4)));
		else if (DesiredGrowth < DrawScale/*3D.Y*/)
			NewDrawScale = FMax(DesiredGrowth, DrawScale/*3D.Y*/ - (DeltaTime / GrowthTime));
		else
			EndGrowth();



		// This if statement fails if EndGrowth was called
		if (!bFinishedGrowth)
		{
			// Make sure the size of the portal doesn't exceed MaxGrowth
			NewDrawScale = FMin(MaxGrowth, NewDrawScale);


			// Test if the current amount of growth can be applied (checked through GrowthFail)
			FinalDrawScale = (NewDrawScale * vect(0,1,1)) + vect(1,0,0);
			//SetDrawScale3D(FinalDrawScale);
			SetDrawScale(FinalDrawScale.Y);

			// Test if the growth has failed (however if the portal is shrinking then it skips the check, portals will always be able to shrink)
			if (NewDrawScale > OldDrawScale && GrowthFail())
			{
				if (bForceMinimumGrowth && OldDrawScale < DefaultDrawScale)
				{
					// Don't integrate this if statement with the above if statement, it needs to stay here
					if (NewDrawScale > DefaultDrawScale)
					{
						SetGrowth(DefaultDrawScale);
						FinalDrawScale = (DefaultDrawScale * vect(0,1,1)) + vect(1,0,0);
						//SetDrawScale3D(FinalDrawScale);
						SetDrawScale(FinalDrawScale.Y);

						if (OtherSide != none)
							OtherSide.SetGrowth(DefaultDrawScale);

						EndGrowth();
					}
				}
				else
				{
					SetGrowth(OldDrawScale);
					FinalDrawScale = (OldDrawScale * vect(0,1,1)) + vect(1,0,0);
					//SetDrawScale3D(FinalDrawScale);
					SetDrawScale(FinalDrawScale.Y);

					// Make the other side match this portals size
					if (OtherSide != none)
						OtherSide.SetGrowth(OldDrawScale);

					EndGrowth();
				}
			}
			else if (DrawScale/*3D.Y*/ == DesiredGrowth)
			{
				EndGrowth();

				if (bDischarging)
					Destroy();
			}
		}
	}


	// Scripted texture ticking
	if (Level.Netmode != NM_DedicatedServer)
	{
		if (FrameCount > FramerateDivider)
		{
			PortalTex.Revision++;
			FrameCount = 0;
		}

		FrameCount++;
	}


	// Test code to debug the warping functions
	/*if (FireMode == 0 && OtherSide != none && Owner != none && Controller(Owner) != none && Controller(Owner).Pawn != none)
	{
		OrigLoc = Controller(Owner).Pawn.Location;
		ThisCoords = GetCoords(Location, Rotation);
		OtherCoords = Transpose(GetCoords(OtherSide.Location, OtherSide.Rotation));

		// Based off CustomUnWarp
		EndLoc = TransformPointBy(OrigLoc, ThisCoords);

		// Based off CustomWarp
		EndLoc = TransformPointBy(EndLoc, OtherCoords);


		// Draw the final data (clearing old lines while at it)
		ClearStayingDebugLines();
		DrawStayingDebugLine(OrigLoc, EndLoc, 255, 0, 0);
	}*/
}


// Growth/Shrinking helper functions

// Tells the portal to grow/shrink to the specified scale
simulated function SetGrowth(float NewScale)
{
	bFinishedGrowth = False;
	DesiredGrowth = FMin(NewScale, MaxGrowth);
	Enable('Tick');
}

// Stops all growth/shrinking
simulated function EndGrowth()
{
	bFinishedGrowth = True;

	if (Level.Netmode == NM_DedicatedServer)
		Disable('Tick');
}

// Tests if there is enough space in the surrounding level geometry for the portal to accept its current drawscale
simulated function bool GrowthFail()
{
	local plane TempPlane;
	local vector TempVect, X, Y, Z;

	TempPlane = GetRenderBoundingSphere();
	GetAxes(Rotation, X, Y, Z);
	TempVect.X = TempPlane.W;
	TempVect.Y = TempPlane.W;
	TempVect.Z = 1;



	// Maybe add this back in?
	//if (Trace(TempVect, TempVect, Location + (X * 0.5), /*Location - (X * 0.5) */, True, TempVect) != none)
	//	return True;


	// Not how I would like to do it but this is the only way to get it to ignore the extent restrictions
	// However, even with this and the above trace there is still a problem with terrain
	if (!FastTrace(Location + (Z * TempPlane.W * 0.5), Location - (Z * TempPlane.W * 0.5)))
		return True;


	if (!FastTrace(Location + (Y * TempPlane.W * 0.5), Location - (Y * TempPlane.W * 0.5)))
		return True;


	X = Normal(Z + Y);

	if (!FastTrace(Location + (X * TempPlane.W * 0.5), Location - (X * TempPlane.W * 0.5)))
		return True;


	X = Normal(Z - Y);

	if (!FastTrace(Location + (X * TempPlane.W * 0.5), Location - (X * TempPlane.W * 0.5)))
		return True;


	return False;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local string sInitVal;

	// Hopefully this will improve fps
//	if (!PlayerCanSeeMe())
	//	return;


	// Lovely hack for scripted textures :) (without this, either warp zones would break or portals would break)
	sInitVal = rDev.GetPropertyText("UseStencil");
	rDev.SetPropertyText("UseStencil", "False");


	if (OtherSide != none && Level != none && Level.GetLocalPlayerController() != none && Level.GetLocalPlayerController().Pawn != none)
		Tex.DrawPortal(0, 0, TexRes, TexRes, Level.GetLocalPlayerController().Pawn, OtherSide.Location, OtherSide.Rotation, 90, False);


	rDev.SetPropertyText("UseStencil", sInitVal);
}

// Make sure this is destroyed on round resets in Onslaught and Assault
function Reset()
{
	Destroy();
}

// Free the allocated textures and tell all portals that there is one less portal
simulated function Destroyed()
{
	local CSMarvinPortalDecal pd;

	if (PortalTex != none)
		Level.ObjectPool.FreeObject(PortalTex);

	if (Skins.Length > 0 && FinalBlend(Skins[0]) != none)
	{
		if (Combiner(FinalBlend(Skins[0]).Material) != none)
			Level.ObjectPool.FreeObject(FinalBlend(Skins[0]).Material);

		Level.ObjectPool.FreeObject(Skins[0]);
	}

	foreach DynamicActors(Class'CSMarvinPortalDecal', pd)
		if (pd.Owner != Owner)
			pd.UpdateList(False);

	Super.Destroyed();
}


// Handle actor warping

simulated function Touch(actor Other)
{
	//local float NewGrowth, ProjEnergy;
	local plane TempPlane;

	if (Other == none)
		return;

    /*

    not doing growth feature 

	// If attempting to warp another portal projectile of the same owner, use it to either increase or decrease this portals size :) (based on wether its a primary or secondary proj)
	if (CSMarvinProjectile(Other) != none && Other.Instigator != none && Other.Instigator.Controller != none && Owner == Other.Instigator.Controller)
	{
		// Not very well tested ;) the code could do with a cleanup
		ProjEnergy = (CSMarvinProjectile(Other).StartingPortalSize - CSMarvinProjectile(Other).DefaultPortalSize) * 0.5;

		//if (pgPortalProjectile(Other).FireMode == FireMode)
		if (CSMarvinProjectileBlue(Other) != None)
		{
			PlaySound(Sound'PortalGrow');

			NewGrowth = FMin(DesiredGrowth + (DefaultDrawScale * 0.25) + ProjEnergy, MaxGrowth);
		}
		else
		{
			PlaySound(Sound'PortalShrink');

			NewGrowth = FMin(FMax(MaxShrinkage, DesiredGrowth - ((DefaultDrawScale * 0.25) + ProjEnergy)), MaxGrowth);
		}

		SetGrowth(NewGrowth);

		if (OtherSide != none)
			OtherSide.SetGrowth(NewGrowth);

		Other.Destroy();

		return;
	}
    */

	// Allow warp projectile to destroy other portals
	if (CSMarvinProjectile(Other) != none && Other.Instigator != none && Other.Instigator.GetTeamNum() != CSMarvinPortalWeapon(Owner).Team)
	{
        PlaySound(Sound'PortalShrink');
        Projectile(Other).Explode(Location,vector(Rotation));
        //Destroy();
        Explode(Location,vector(Rotation));

		return;
	}

	if (OtherSide != none && OtherSide.Base != Other && ZoneInfo(Other) == none && Volume(Other) == none && Mover(Other) == none && GameObject(Other) == none
		&& ONSManualGunPawn(Other) == none && ONSAutoBomberBomb(Other) == none)
	{
		// If the other side portal is smaller than this one, limit entering objects based on THAT portals size
		if (OtherSide == none || DrawScale/*3D.Y*/ < OtherSide.DrawScale/*3D.Y*/)
			TempPlane = GetRenderBoundingSphere();
		else
			TempPlane = OtherSide.GetRenderBoundingSphere();

		//Log("Other BS is:"@Other.GetRenderBoundingSphere().W@"portals is"@TempPlane.W);

		if (Other.GetRenderBoundingSphere().W < TempPlane.W)
			WarpActor(Other);
	}
}

// ??
simulated function Attach(Actor Other)
{
	Touch(Other);
}

simulated function Bump(Actor Other)
{
	Touch(Other);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	PlaySound(sound'WeaponSounds.BExplosion3',,5.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        if(FireMode == 0)
            Spawn(class'CSMarvinPortalExplosionBlue',,,HitLocation + HitNormal*16, rotator(HitNormal) + rot(-16384,0,0));
        else
            Spawn(class'CSMarvinPortalExplosionRed',,,HitLocation + HitNormal*16, rotator(HitNormal) + rot(-16384,0,0));

    }

	Destroy();
}


simulated singular function WarpActor(actor Other)
{
	local vector WarpLoc, WarpVel, X, Y, Z, DispVect;
	local rotator WarpRot;
	local Quat AxialRot;
	local EPhysics PrePhysics;
	local bool bOldKStayUpright, bOldKAllowRotate, bIsKarma;
	local controller P;
	//local Coords ObjCoords, ThisCoords, OtherCoords;
	//local plane TempPlane;
	// New warp rot test code
	//local float TestFloat;
	//local vector TempX, TempY, TempZ;
	// New new warp rot test code
	//local float XDot, YDot, ZDot, XDiff, YDiff, ZDiff;
	//local vector EntryX, EntryY, EntryZ, ExitX, ExitY, ExitZ, ViewX, ViewY, ViewZ;
	//local float ClockX, ClockY, ClockZ;


	// So the code below looks a little more elegant ;)
	if (Vehicle(Other) != none || Other.Physics == PHYS_Karma)
		bIsKarma = True;


	//TempPlane = Other.GetRenderBoundingSphere();
	//Log("Entered actor's ("$string(Other)$") bounding sphere is:"@TempPlane.W@"as opposed to"@GetRenderBoundingSphere().W);


	if (!Other.bJustTeleported || bIsKarma)
	{
		// Play the sound (doesn't work?!?)
		//PlaySound(Sound'PortalEntry');
		//OtherSide.PlaySound(Sound'PortalEntry');

		Other.Disable('Touch');
		Other.Disable('UnTouch');
		Disable('Touch');
		WarpVel = Other.Velocity;

		//PrePhysics = Other.Physics;

		// If a vehicle is entering the portal then save its physics settings
		if (bIsKarma)
		{
			PrePhysics = Other.Physics;

			if (Other.KParams != none && KarmaParams(Other.KParams) != none)
			{
				bOldKStayUpright = KarmaParams(Other.KParams).bKStayUpright;
				bOldKAllowRotate = KarmaParams(Other.KParams).bKAllowRotate;
			}

			Other.SetPhysics(PHYS_None);
		}

		//Other.SetPhysics(PHYS_None);



		// *** Perform Location/Rotation/Velocity warping...I love quaternions, they make fucking horrible things (like arbitrary rotations) seem so easy :p (it's still fugly tho)




		// Find the rotation that will line up the portal's XYZ axes with the world's XYZ axes (greatly simplifies the math involved)
		// N.B. There is a bug with QuatFindBetween....QuatFindBetween(vect(-1,0,0), vect(1,0,0)) will return a quaternion with no rotational transformations, that might also
		// happen with other inverted vectors other than the ones checked for below
		DispVect = vector(Rotation);

		if (DispVect.X ~= -1.0 && DispVect.Y ~= 0.0 && DispVect.Z ~= 0.0)
			AxialRot = QuatFromAxisAndAngle(vect(0,0,1), PI);
		else
			AxialRot = QuatFindBetween(DispVect, vect(1,0,0));



		// Get the other sides XYZ axes
		GetAxes(OtherSide.Rotation, X, Y, Z);




		if(Pawn(Other) != None && Vehicle(Other) == none)
			WarpRot = Pawn(Other).GetViewRotation();
		else
			WarpRot = Other.Rotation;


		// Don't warp the viewrotation clientside unless the player is in a vehicle
		if (/*Role < ROLE_Authority || Level.Netmode == NM_Standalone*/ Level.Netmode != NM_DedicatedServer || Vehicle(Other) != none)
		{

			// ***** Rotation warping

			
			// Setup the displacement vector relative to this portal (in this case, that just means converting the rotator to a vector)
			DispVect = vector(WarpRot);

			// Apply the axial rotation to the displacement vector
			DispVect = QuatRotateVector(AxialRot, DispVect);

			// Perform mirror symmetry on the X and Y axes (otherwise you will be looking the opposite way you would expect)
			DispVect *= vect(-1,-1,1);

			// Transform the displacement vector in relation to the other portals axes and convert back to a rotator
			DispVect = (X * DispVect.x) + (Y * DispVect.y) + (Z * DispVect.z);
			WarpRot = Rotator(DispVect);
			


			// Test code
			//local float TestFloat;
			//local vector TempX, TempY, TempZ;

			// This code is a feasable 'Proof of Concept', it seems that this can be expanded upon to do completely arbitrary rotations
/*
			// The minus vector here is a test to flip the portal 180 degrees
			TestFloat = vector(Rotation) Dot -vector(OtherSide.Rotation);

			GetAxes(WarpRot, TempX, TempY, TempZ);

			// ClockWiseFrom will only work so long as Yaw alone can be used to determine wether the required rotation is clockwise or anticlockwise (code your own later)
			WarpRot = rotator((TempX * TestFloat) + ((-1.0 + (2.0 * float(Rotation.Yaw ClockWiseFrom OtherSide.Rotation.Yaw))) * (TempY * Sin(aCos(TestFloat)))));

*/
/*
			// More test code (expanded version of the above code)
			//local float XDot, YDot, ZDot;
			//local vector EntryX, EntryY, EntryZ, ExitX, ExitY, ExitZ, ViewX, ViewY, ViewZ;
			//local float ClockX, ClockY, ClockZ;

			GetAxes(Rotation, EntryX, EntryY, EntryZ);
			GetAxes(OtherSide.Rotation, ExitX, ExitY, ExitZ);
			GetAxes(WarpRot, ViewX, ViewY, ViewZ);

			// TODO: Only the X dot product is flipped, check if the same needs to be done on Y or Z (and if the X flip is always neccessary)
			// N.B: The Normals are essential, don't ever remove them or the code will fuck up
			XDot = Normal(EntryX * vect(1,1,0)) Dot -Normal(ExitX * vect(1,1,0)); // Change on XY axis
			YDot = Normal(EntryY * vect(0,1,1)) Dot Normal(ExitY * vect(0,1,1)); // Change on YZ axis
			ZDot = Normal(EntryZ * vect(1,0,1)) Dot Normal(ExitZ * vect(1,0,1)); // Change on XZ axis

			// Calculate the difference between the players rotation and the portals rotation (much like the above code)
			XDiff = Normal(ViewX * vect(1,1,0)) Dot Normal(EntryX * vect(1,1,0)); // XY
			YDiff = Normal(ViewY * vect(0,1,1)) Dot Normal(EntryY * vect(0,1,1)); // YZ
			ZDiff = Normal(ViewZ * vect(1,0,1)) Dot Normal(EntryZ * vect(1,0,1)); // XZ


			// TODO: Make sure these are correct and tweak them so they are more efficient (this is fucking ugly math code)

			// Is the XY change clockwise? (yaw!)
			ClockX = -1.0 + (2.0 * float(rotator(EntryX).Yaw ClockWiseFrom rotator(ExitX).Yaw));
			// Is the YZ change clockwise? (pitch!)
			ClockY = -1.0 + (2.0 * float(rotator(EntryY).Pitch ClockWiseFrom rotator(ExitY).Pitch));
			// Is the XZ change clockwise? (pitch!)
			ClockZ = -1.0 + (2.0 * float(rotator(EntryZ).Pitch ClockWiseFrom rotator(ExitZ).Pitch));


			// TODO: These do not yet account for the Z Axis
			//ViewX = (ViewX * XDot) + ((-1.0 + (2.0 * float(bClockX))) * (ViewY * Sin(aCos(XDot)))) + (ViewZ * something);

			// ViewX doesn't want to know bout YZ axis changes (i.e. roll) (broke)
			//ViewX = (ViewX * XDot * vect(1,1,0)) + (ClockX * ViewY * Sin(aCos(XDot)) * vect(0,1,1)) + (ClockZ * ViewZ * ZDot * vect(1,0,1));
			// Ignore XZ
			//ViewY = (ViewY * YDot) + (ClockY *


			// Third try (fucking ugly code but it 'kind of' works)
			// First of all, rotate the View co-ordinates as if the player just stepped out of the portal
			//ViewX = 

			// Now account for the difference in rotation between the entered portal and the exited portal
			ViewX = (ViewX * XDot * vect(1,1,0)) + (ClockX * ViewY * Sin(aCos(XDot)) * vect(1,1,0)) // XY change
				+ (ViewX * ZDot * vect(0,0,1)) + (ClockZ * ViewZ * Sin(aCos(ZDot)) * vect(0,0,1)); // XZ change


			// Using only ViewX, we can determine the correct rotation minus Roll..test it
			WarpRot = rotator(ViewX);
*/



			// ********
			// STATUS:
			//	The code above works quite well but when rotating on a straight-up wall and on a slanted surface, it rotates in wrong direction.
			//	Flipping the ZDot's ExitZ normal fixed this for the slanted surface on Torlans base but proceeded to screw up walls
			// ********

		}


		// ***** Velocity warping


		// Nearly exactly the same as above except you don't have rotator conversions (N.B. the players velocity can be considered a displacement vector)
		DispVect = QuatRotateVector(AxialRot, WarpVel);


		DispVect *= vect(-1,-1,1);
		WarpVel = (X * DispVect.x) + (Y * DispVect.y) + (Z * DispVect.z);



		// ***** Location warping

		
		// Still pretty much the same thing, there are a few differences tho
		DispVect = Other.Location - Location;

		DispVect = QuatRotateVector(AxialRot, DispVect);

		// Only flip the X axis if the player has entered the back of the portal (stops the player coming out the back of the otherside)
		if (DispVect.x < 0)
			DispVect *= vect(-1,-1,1);
		else
			DispVect *= vect(1,-1,1);

		// Offset the other portals location by the displacement vector and you have the warped location
		WarpLoc = OtherSide.Location + (X * DispVect.x) + (Y * DispVect.y) + (Z * DispVect.z) + (vector(Rotation) * 12.0);


		// After getting fed up with buggy Quaternion functions, I decided to rip the coordinate transformation functions from the C++ side of the engine
		// So much for quaternions making things easy :p (co-ordinate transformation is no more easy mind you)
/*
		WarpLoc = Other.Location;
		CustomUnWarp(WarpLoc, WarpVel, WarpRot, GetCoords(Location, Rotation));
		CustomWarp(WarpLoc, WarpVel, WarpRot, GetCoords(OtherSide.Location, OtherSide.Rotation));
*/


		// ***** Apply the warped location/rotation/velocity to the object that entered the portal (this differs between players, vehicles and other objects)

		if (bIsKarma)
		{
			// Give some extra distance between the portal and vehicles
			if (Vehicle(Other) != none)
				WarpLoc += Normal(vector(OtherSide.Rotation)) * 100.0;

			if (Other.SetLocation(WarpLoc))
			{
				Other.SetRotation(WarpRot);


				// Tricky fucking code (adapted from pub source ONS cpp files), this stops mantas/raptors/cicadas from resisting the new rotation
				if (ONSChopperCraft(Other) != none)
				{
					ONSChopperCraft(Other).TargetHeading = ACos(FClamp(Normal(vector(WarpRot)).x, -1.0, 1.0));

					if (vector(WarpRot).y < 0)
						ONSChopperCraft(Other).TargetHeading *= -1.0;
				}
				else if (ONSHoverCraft(Other) != none)
				{
					ONSHoverCraft(Other).TargetHeading = ACos(FClamp(Normal(vector(WarpRot)).x, -1.0, 1.0));

					if (vector(WarpRot).y < 0)
						ONSHoverCraft(Other).TargetHeading *= -1.0;
				}


				// Update the drivers view rotation relative to his previous view rotation not the vehicles new rotation
				if (Vehicle(Other) != none && Vehicle(Other).Controller != none)
				{

					WarpRot = Vehicle(Other).Controller.Rotation;


					// (Rotation) Setup the displacement vector relative to this portal (in this case, that just means converting the rotator to a vector)
					DispVect = vector(WarpRot);

					// (Rotation) Apply the axial rotation to the displacement vector
					DispVect = QuatRotateVector(AxialRot, DispVect);

					// (Rotation) Perform mirror symmetry on the X and Y axes (otherwise you will be looking the opposite way you would expect)
					DispVect *= vect(-1,-1,1);

					// (Rotation) Transform the displacement vector in relation to the other portals axes and convert back to a rotator
					DispVect = (X * DispVect.x) + (Y * DispVect.y) + (Z * DispVect.z);
					WarpRot = Rotator(DispVect);
/*
					CustomUnWarp(WarpLoc, DispVect, WarpRot, GetCoords(Location, Rotation));
					CustomWarp(WarpLoc, DispVect, WarpRot, GetCoords(OtherSide.Location, OtherSide.Rotation));
*/


					Vehicle(Other).Controller.SetRotation(WarpRot);
				}
			}


			// Restore the vehicles physics settings
			Other.SetPhysics(PrePhysics);

			if (Other.KParams != none && KarmaParams(Other.KParams) != none)
				Other.KSetStayUpright(bOldKStayUpright, bOldKAllowRotate);
		}
		else if (Pawn(Other) != none)
		{
			Pawn(Other).bWarping = False;

			SetCollision(False, False, False);

			if (Other.SetLocation(WarpLoc))
			{
				if (/*Role == ROLE_Authority*/ Level.Netmode != NM_Client)
					for (p=Level.ControllerList; P!=None; P=P.NextController )
						if (P.Enemy == Other)
							P.LineOfSightTo(Other);

				WarpRot.Roll = 0;
				Pawn(Other).SetViewRotation(WarpRot);
				Pawn(Other).ClientSetLocation(WarpLoc, WarpRot);

				if (Pawn(Other).Controller != None)
					Pawn(Other).Controller.MoveTimer = -1.0;
			}

			SetCollision(True, False, False);

			//Other.SetPhysics(PrePhysics);
		}
		else
		{
			Other.SetLocation(WarpLoc);
			Other.SetRotation(WarpRot);
			//Other.SetPhysics(PrePhysics);
		}



		Enable('Touch');
		Other.Enable('Touch');
		Other.Enable('UnTouch');


		// Velocity restoration is here because sometimes re-enabling touch also has an effect on velocity
		if (bIsKarma)
		{
			if (Vehicle(Other) != none)
				Other.KAddImpulse(WarpVel * 100 * ONSVehicle(Other).VehicleMass, vect(0,0,0));
			else if (KarmaParams(Other.KParams) != none)
				Other.KAddImpulse(WarpVel * 100 * KarmaParams(Other.KParams).KMass, vect(0,0,0));
			else
				Other.KAddImpulse(WarpVel * 100, vect(0,0,0));
		}
		else
		{
			Other.Velocity = WarpVel;
		}


		// For rockets, fixes sprialing rockets going ape
		if (RocketProj(Other) != none)
		{
			RocketProj(Other).Dir = vector(Other.Rotation);
		}
		/*else if (Other.IsA('LinkProjectile')) // IsA because I don't want to affect subclasses
		{
			Other.Acceleration = Normal(Other.Velocity) * VSize(Other.Acceleration);
		}
		else if (ONSAVRiLRocket(Other) != none)
		{
			// I only do this here because it's kind of expensive to do it on everything (remember to change this bit if you change the warping system)
			DispVect = QuatRotateVector(AxialRot, Other.Acceleration);


			DispVect *= vect(-1,-1,1);
			Other.Acceleration = (X * DispVect.x) + (Y * DispVect.y) + (Z * DispVect.z);
		}*/
		else if (Projectile(Other) != none && Other.Acceleration != vect(0,0,0))
		{
			DispVect = QuatRotateVector(AxialRot, Other.Acceleration);


			DispVect *= vect(-1,-1,1);
			Other.Acceleration = (X * DispVect.x) + (Y * DispVect.y) + (Z * DispVect.z);
		}
	}
}

// Unfinished test code for a new warping system which gets rid of quaternion functions
/*
function Coords GetCoords(vector Vect, rotator Rot)
{
	local Coords TempCoords;

	TempCoords.Origin = Vect;
	GetAxes(Rot, TempCoords.XAxis, TempCoords.YAxis, TempCoords.ZAxis);

	return TempCoords;
}

// This is minimally better but needs a LOT of improvment (N.B. On further testing, this is EXACTLY THE SAME as the warp zone code...and the warp zone code is SHIT, so I can't use it :/)
function CustomWarp(out vector Loc, out vector Vel, out rotator Rot, Coords Coord)
{
	local Coords Trans;
	local vector X, Y, Z;

	Trans = Transpose(Coord);

	Loc = TransformPointBy(Loc, Trans);
	Vel = TransformVectorBy(Vel, Trans);

	GetAxes(Rot, X, Y, Z);
	X = TransformVectorBy(X, Trans);
	Y = TransformVectorBy(Y, Trans);
	Z = TransformVectorBy(Z, Trans);
	Rot = OrthoRotation(X, Y, Z);
}

function CustomUnWarp(out vector Loc, out vector Vel, out rotator Rot, Coords Coord)
{
	local vector X, Y, Z;

	Loc = TransformPointBy(Loc, Coord);
	Vel = TransformVectorBy(Vel, Coord);

	GetAxes(Rot, X, Y, Z);
	X = TransformVectorBy(X, Coord);
	Y = TransformVectorBy(Y, Coord);
	Z = TransformVectorBy(Z, Coord);
	Rot = OrthoRotation(X, Y, Z);
}

static final operator(16) float | (vector A, vector B)
{
	return A.X * B.X + A.Y * B.Y + A.Z * B.Z;
}

static final function vector TransformPointBy(vector Vect, Coords Coord)
{
	local vector TempVect;

	TempVect = Vect - Coord.Origin;

	Vect.X = TempVect | Coord.XAxis;
	Vect.Y = TempVect | Coord.YAxis;
	Vect.Z = TempVect | Coord.ZAxis;

	return Vect;
}

static final function vector TransformVectorBy(vector Vect, Coords Coord)
{
	local vector TempVect;

	TempVect.X = Vect | Coord.XAxis;
	TempVect.Y = Vect | Coord.YAxis;
	TempVect.Z = Vect | Coord.ZAxis;

	return TempVect;
}

static final function Coords Transpose(Coords A)
{
	local Coords TempCoords;

	TempCoords.Origin = -TransformVectorBy(A.Origin, A);

	TempCoords.XAxis.X = A.XAxis.X;
	TempCoords.XAxis.Y = A.YAxis.X;
	TempCoords.XAxis.Z = A.ZAxis.X;

	TempCoords.YAxis.X = A.XAxis.Y;
	TempCoords.YAxis.Y = A.YAxis.Y;
	TempCoords.YAxis.Z = A.ZAxis.Y;

	TempCoords.ZAxis.X = A.XAxis.Z;
	TempCoords.ZAxis.Y = A.YAxis.Z;
	TempCoords.ZAxis.Z = A.ZAxis.Z;

	return TempCoords;
}
*/

defaultproperties
{
     FramerateDivider=4
     GrowthTime=0.500000
     MaxShrinkage=0.250000
     MaxGrowth=5.000000
     DefaultDrawscale=1.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CSMarvin.MeshPortal'
     RemoteRole=ROLE_SimulatedProxy
     Style=STY_Additive
     bUnlit=True
     TransientSoundVolume=1.000000
     bCollideActors=True
}
