class CSShieldMech extends CSHoverMech
    placeable;

#exec AUDIO IMPORT FILE=Sounds\1812overture.wav
#exec AUDIO IMPORT FILE=Sounds\ofortuna.wav
#exec AUDIO IMPORT FILE=Sounds\EngStop2.wav
#exec AUDIO IMPORT FILE=Sounds\EngStart2.wav
#exec AUDIO IMPORT FILE=Sounds\FootStep2.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle5.wav

var(Gfx) Color ChargeColor;
var(Gfx) vector RechargeOrigin;
var(Gfx) vector RechargeSize;

function ShouldTargetMissile(Projectile P)
{
	local AIController C;

	C = AIController(Controller);
	if ( (C != None) && (C.Skill >= 2.0) )
		CSShieldMechWeapon(Weapons[0]).ShieldAgainstIncoming(P);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	CSShieldMechWeapon(Weapons[0]).ShieldAgainstIncoming();
	return false;
}

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (bWasAltFire && CSShieldMechWeapon(Weapons[ActiveWeapon]) != None)
        CSShieldMechWeapon(Weapons[ActiveWeapon]).CeaseAltFire();
}


event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local vector ShieldHitLocation, ShieldHitNormal;

	// don't take damage if should have been blocked by shield
	if ( (Weapons.Length > 0) && CSShieldMechWeapon(Weapons[0]).bShieldActive && (CSShieldMechWeapon(Weapons[0]).ShockShield != None) && (Momentum != vect(0,0,0))
		&& (HitLocation != Location) && (DamageType != None) && (ClassIsChildOf(DamageType,class'WeaponDamageType') || ClassIsChildOf(DamageType,class'VehicleDamageType')) 
		&& !CSShieldMechWeapon(Weapons[0]).ShockShield.TraceThisActor(ShieldHitLocation,ShieldHitNormal,HitLocation,HitLocation - 2000*Normal(Momentum)) )
        {
            return;
        }

    Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

simulated function vector GetTargetLocation()
{
	return Location + vect(0,0,1)*CollisionHeight;
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

    /*
    L.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Body_0');
    L.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Head_0');
    L.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Body_1');
    L.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Head_1');
    L.AddPrecacheMaterial(Texture'XEffectMat.Shock.shock_ring_b');
    */

    L.AddPrecacheStaticMesh(StaticMesh'CSMech.Shield');

}

simulated function UpdatePrecacheStaticMeshes()
{
    Super.UpdatePrecacheStaticMeshes();
    Level.AddPrecacheStaticMesh(StaticMesh'CSMech.Shield');
}

simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
    /*
    Level.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Body_0');
    Level.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Head_0');
    Level.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Body_1');
    Level.AddPrecacheMaterial(Texture'UT2004PlayerSkins.Matrix.XanF1v2_Head_1');
    Level.AddPrecacheMaterial(Texture'XEffectMat.Shock.shock_ring_b');
    */
}


simulated function DrawHUD(Canvas Canvas)
{
    RenderChargeBar(Canvas);
    super.DrawHUD(Canvas);
}

function RenderChargeBar( Canvas Canvas )
{
	local float tileScaleX;
	local float tileScaleY;
	local float ChargeBar;

	local float barOrgX;
	local float barOrgY;
	local float barSizeX;
	local float barSizeY;
    local CSShieldMechWeapon shieldweapon;

    if(Level.NetMode == NM_DedicatedServer)
        return;

    if ( Weapons[0].FireCountdown >= Level.TimeSeconds )
    {
        ChargeBar = 1.0;
    }
    else
    {
        shieldweapon = CSShieldMechWeapon(Weapons[0]);
        if(shieldweapon != None)
        {
            if(shieldweapon.bHoldingFire && !bWeaponIsAltFiring && !shieldweapon.bShieldActive)
            {
                ChargeBar = FClamp((Level.TimeSeconds - shieldweapon.StartHoldTime) / shieldweapon.MaxHoldTime, shieldweapon.MinDamageScale, 1.0);
            }
            else
            {
                ChargeBar = 0;
            }
        }
    }

    tileScaleX = Canvas.SizeX / 640.0f;
    tileScaleY = Canvas.SizeY / 480.0f;

    barOrgX = RechargeOrigin.X * tileScaleX;
    barOrgY = RechargeOrigin.Y * tileScaleY;

    barSizeX = RechargeSize.X * tileScaleX;
    barSizeY = RechargeSize.Y * tileScaleY;


    Canvas.DrawColor = ChargeColor;
    Canvas.DrawColor.A = 255;

    if(ChargeBar <1)
        Canvas.DrawColor.R = 255*ChargeBar;
    else
    {
        Canvas.DrawColor.R = 0;
        Canvas.DrawColor.B = 0;
    }

    if(ChargeBar == 1)
    {
        Canvas.DrawColor.G = 255;
    }
    else
    {
        Canvas.DrawColor.G = 0;
    }

    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.SetPos( barOrgX, barOrgY );
    Canvas.DrawTile(Texture'Engine.WhiteTexture',barSizeX,barSizeY*ChargeBar, 0.0, 0.0,Texture'Engine.WhiteTexture'.USize,Texture'Engine.WhiteTexture'.VSize*ChargeBar);
}


defaultproperties
{
    VehicleNameString="Armortron 2.1"
    VehiclePositionString="in an Armortron"
    bExtraTwist=false
    //Mesh=Mesh'CSMech.XanM03'
    //RedSkin=Texture'UT2004PlayerSkins.Xan.XanM3_Body_0'
    //RedSkinHead=Texture'UT2004PlayerSkins.Xan.XanM3_Head'
    //BlueSkin=Texture'UT2004PlayerSkins.Xan.XanM3_Body_1'
    //BlueSkinHead=Texture'UT2004PlayerSkins.Xan.XanM3_Head'
    Mesh=Mesh'CSMech.EnigmaM'
    RedSkin=Texture'UT2004PlayerSkins.Matrix.XanF1v2_Body_0'
    RedSkinHead=Texture'UT2004PlayerSkins.Matrix.XanF1v2_Head_0'
    BlueSkin=Texture'UT2004PlayerSkins.Matrix.XanF1v2_Body_1'
    BlueSkinHead=Texture'UT2004PlayerSkins.Matrix.XanF1v2_Head_1'

	Health=2000
	HealthMax=2000
	DriverWeapons(0)=(WeaponClass=class'CSShieldMechWeapon',WeaponBone=righthand)
    HornAnims(0)=gesture_halt
    HornAnims(1)=gesture_point
    HornSounds(0)=sound'CSMech.1812overture'
    HornSounds(1)=sound'CSMech.ofortuna'
    IdleSound=sound'CSMech.EngIdle5'        
    StartUpSound=sound'CSMech.EngStart2'
	ShutDownSound=sound'CSMech.EngStop2'
    FootStepSound=sound'CSMech.FootStep2'

	ChargeColor=(R=255,G=255,B=255,A=255)
    RechargeOrigin=(X=600,Y=330,Z=0)
	RechargeSize=(X=10,Y=-180,Z=0)
}