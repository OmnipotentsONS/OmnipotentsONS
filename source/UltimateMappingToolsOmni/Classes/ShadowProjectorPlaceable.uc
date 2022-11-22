//-----------------------------------------------------------------------------
// ShadowProjectorPlaceable
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 11.10.2011 21:33:56 in Package: UltimateMappingTools$
//
// A fixed version of the ShadowProjector that works when manually placed in a map.
//-----------------------------------------------------------------------------
class ShadowProjectorPlaceable extends ShadowProjector;

var(ShadowProjector) edfindable Actor AssignedShadowActor;
var(ShadowProjector) bool bUseProjectorLocationForLight;
var(ShadowProjector) bool bForceManualFOV; // If True, will use the FOV specified and don't calculate it.
var(ShadowProjector) float UpdateFrequency; // Updates per second.
var(ShadowProjector) bool bOnlyUpdateOnTrigger; // Ultimate performance saving. Will only update the shadow on triggering.
var(ShadowProjector) byte ShadowDarkness; // How dark the shadow will be. 255 is maximum and default.

event PostBeginPlay()
{
    local vector ActorLocation;
    local plane BoundingSphere; // We need to get the Actor's real center, not the pivot location.

    if (Level.NetMode == NM_DedicatedServer)
        return;

    super.PostBeginPlay();

    if (AssignedShadowActor != None)
        ShadowActor = AssignedShadowActor;

    if (ShadowActor != None)
    {
        SetOwner(ShadowActor);

        if (UpdateFrequency == 0)
            UpdateFrequency = default.UpdateFrequency;

        if (bUseProjectorLocationForLight)
        {
            BoundingSphere = ShadowActor.GetRenderBoundingSphere();
            ActorLocation.X = BoundingSphere.X;
            ActorLocation.Y = BoundingSphere.Y;
            ActorLocation.Z = BoundingSphere.Z;

            LightDirection = (ActorLocation - Location) * vect(-1,-1,-1);
            LightDistance = VSize(LightDirection);
        }

        InitShadow();
        if (!bOnlyUpdateOnTrigger)
        {
            SetTimer(1/UpdateFrequency, True);
        }
        else
        {
            UpdateShadow();
        }
    }
    else
        Destroy();
}

function InitShadow()
{
    local Plane     BoundingSphere;

    if (ShadowActor != None)
    {
        if (!bForceManualFOV || FOV <= 0)
        {
            BoundingSphere = ShadowActor.GetRenderBoundingSphere();
            FOV = Atan(BoundingSphere.W * 2 + 160, LightDistance) * 180 / PI;
        }

        ShadowTexture = ShadowBitmapMaterial(Level.ObjectPool.AllocateObject(class'ShadowBitmapMaterial'));
        ProjTexture = ShadowTexture;

        if(ShadowTexture != None)
        {
            SetDrawScale(LightDistance * tan(0.5 * FOV * PI / 180) / (0.5 * ShadowTexture.USize));

            ShadowTexture.Invalid = False;
            ShadowTexture.bBlobShadow = bBlobShadow;
            ShadowTexture.ShadowActor = ShadowActor;
            ShadowTexture.LightDirection = Normal(LightDirection);
            ShadowTexture.LightDistance = LightDistance;
            ShadowTexture.LightFOV = FOV;
            ShadowTexture.CullDistance = CullDistance;
            ShadowTexture.ShadowDarkness = ShadowDarkness;

            Enable('Tick');
            UpdateShadow();
        }
        else
            Log(Name$".InitShadow: Failed to allocate texture");
    }
    else
        Log(Name$".InitShadow: No actor");
}

event Timer()
{
    UpdateShadow();
}

event Trigger(Actor Other, Pawn EventInstigator)
{
    UpdateShadow();
}

defaultproperties
{
     UpdateFrequency=3.000000
     ShadowDarkness=255
     LightDistance=1200.000000
     bClipStaticMesh=True
     CullDistance=2000.000000
     bDirectional=False
}
