
class MutLinkNukeConfig extends GUICustomPropertyPage;

var() Automated moCheckBox cb_bFlipNodes;

var() Automated moCheckBox cb_bHealNodes;
var() Automated moSlider  e_NodeHealRate;
var() Automated moSlider  e_NodeHealDuration;

var() Automated moCheckBox cb_bHealPlayers;
var() Automated moSlider  e_PlayerHealRate;
var() Automated moSlider  e_PlayerHealDuration;
var() Automated moSlider  e_PlayerHealMax;

var() Automated moCheckBox cb_bHealVehicles;
var() Automated moSlider  e_VehicleHealRate;
var() Automated moSlider  e_VehicleHealDuration;
var() Automated moSlider  e_VehicleHealMax;

var() Automated moSlider  e_Damage;
var() Automated moSlider  e_CoreDamage;
var() Automated moSlider  e_NodeDamage;
var() Automated moSlider  e_RespawnTime;

var() Automated moButton  b_ResetSettings;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	b_Cancel.Caption="Close";
	b_Cancel.Hint="Close this window";
	b_Cancel.WinWidth=0.159649;
	b_Cancel.WinHeight=0.044444;
	b_Cancel.WinLeft=0.759737;
	b_Cancel.WinTop=0.910658;
	b_Cancel.TabOrder=21;

	b_Ok.Caption="Save";
	b_Ok.Hint="Save current settings";
	b_Ok.Onclick=SaveLinkNukeConfig;
	b_Ok.WinWidth=0.159649;
	b_Ok.WinHeight=0.044444;
	b_Ok.WinLeft=0.535350;
	b_Ok.WinTop=0.910658;
	b_Ok.TabOrder=22;

	sb_Main.Caption = "YEAAAHHH Nuke Configuration 2.1";

    b_ResetSettings.OnChange = ResetSettings;

    cb_bFlipNodes.Checked(class'MutUseLinkNuke'.default.bFlipNodes);

    cb_bHealNodes.Checked(class'MutUseLinkNuke'.default.bHealNodes);
    e_NodeHealRate.SetValue(class'MutUseLinkNuke'.default.NodeHealRate);
    e_NodeHealDuration.SetValue(class'MutUseLinkNuke'.default.NodeHealDuration);

    cb_bHealPlayers.Checked(class'MutUseLinkNuke'.default.bHealNodes);
    e_PlayerHealRate.SetValue(class'MutUseLinkNuke'.default.PlayerHealRate);
    e_PlayerHealDuration.SetValue(class'MutUseLinkNuke'.default.PlayerHealDuration);
    e_PlayerHealMax.SetValue(class'MutUseLinkNuke'.default.PlayerHealMax);

    cb_bHealVehicles.Checked(class'MutUseLinkNuke'.default.bHealVehicles);
    e_VehicleHealRate.SetValue(class'MutUseLinkNuke'.default.VehicleHealRate);
    e_VehicleHealDuration.SetValue(class'MutUseLinkNuke'.default.VehicleHealDuration);
    e_VehicleHealMax.SetValue(class'MutUseLinkNuke'.default.VehicleHealMax);

    e_Damage.SetValue(class'MutUseLinkNuke'.default.Damage);
    e_CoreDamage.SetValue(class'MutUseLinkNuke'.default.CoreDamage);
    e_NodeDamage.SetValue(class'MutUseLinkNuke'.default.NodeDamage);
    e_RespawnTime.SetValue(class'MutUseLinkNuke'.default.RespawnTime);

}

function bool InternalOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

function ResetSettings(GUIComponent Sender)
{
    cb_bFlipNodes.Checked(true);

    cb_bHealNodes.Checked(true);
    e_NodeHealRate.SetValue(150);
    e_NodeHealDuration.SetValue(5.0);

    cb_bHealPlayers.Checked(true);
    e_PlayerHealRate.SetValue(10);
    e_PlayerHealDuration.SetValue(5.0);
    e_PlayerHealMax.SetValue(199);

    cb_bHealVehicles.Checked(true);
    e_VehicleHealRate.SetValue(100);
    e_VehicleHealDuration.SetValue(5.0);
    e_VehicleHealMax.SetValue(800);

    e_Damage.SetValue(250);
    e_CoreDamage.SetValue(6000);
    e_NodeDamage.SetValue(5000);
    e_RespawnTime.SetValue(60);
}


function bool SaveLinkNukeConfig(GUIComponent Sender)
{
    class'MutUseLinkNuke'.default.bHealNodes = cb_bHealNodes.IsChecked();
    class'MutUseLinkNuke'.default.NodeHealRate = e_NodeHealRate.GetValue();
    class'MutUseLinkNuke'.default.NodeHealDuration = e_NodeHealDuration.GetValue();

    class'MutUseLinkNuke'.default.bHealPlayers = cb_bHealPlayers.IsChecked();
    class'MutUseLinkNuke'.default.PlayerHealRate = e_PlayerHealRate.GetValue();
    class'MutUseLinkNuke'.default.PlayerHealDuration = e_PlayerHealDuration.GetValue();
    class'MutUseLinkNuke'.default.PlayerHealMax = e_PlayerHealMax.GetValue();

    class'MutUseLinkNuke'.default.bHealVehicles = cb_bHealVehicles.IsChecked();
    class'MutUseLinkNuke'.default.VehicleHealRate = e_VehicleHealRate.GetValue();
    class'MutUseLinkNuke'.default.VehicleHealDuration = e_VehicleHealDuration.GetValue();
    class'MutUseLinkNuke'.default.VehicleHealMax = e_VehicleHealMax.GetValue();

    class'MutUseLinkNuke'.default.Damage = e_Damage.GetValue();
    class'MutUseLinkNuke'.default.CoreDamage = e_CoreDamage.GetValue();
    class'MutUseLinkNuke'.default.NodeDamage = e_NodeDamage.GetValue();
    class'MutUseLinkNuke'.default.RespawnTime = e_RespawnTime.GetValue();

    class'MutUseLinkNuke'.default.bFlipNodes = cb_bFlipNodes.IsChecked();

    class'MutUseLinkNuke'.static.StaticSaveConfig();

	return true;
}

defaultproperties
{
    bScaleToParent=True

    Begin Object Class=moCheckBox Name=HealNodes
         CaptionWidth=0.800000
         ComponentWidth=0.200000
         StandardHeight=0.040000
         Caption="Heal Nodes:"
         OnCreateComponent=HealNodes.InternalOnCreateComponent
         Hint="Heal nodes?"
         WinTop=0.202812
         WinLeft=0.085136
         WinWidth=0.143189
         WinHeight=0.042857
         TabOrder=0
         bBoundToParent=True
     End Object
     cb_bHealNodes=moCheckBox'CSLinkNuke.MutLinkNukeConfig.HealNodes'

    Begin Object Class=moSlider Name=HealNodeRate
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Rate:"
         OnCreateComponent=HealNodeRate.InternalOnCreateComponent
         Hint="Amount of health to add every 100ms"
         WinTop=0.202812
         WinLeft=0.295136
         WinWidth=0.123189
         WinHeight=0.042857
         TabOrder=1
         bBoundToParent=True
         MaxValue=200.0
         MinValue=1.0
         Value=150.0
         bIntSlider=True
     End Object
     e_NodeHealRate=moSlider'CSLinkNuke.MutLinkNukeConfig.HealNodeRate'

    Begin Object Class=moSlider Name=HealNodeDuration
         ComponentWidth=0.600000
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Duration:"
         OnCreateComponent=HealNodeDuration.InternalOnCreateComponent
         Hint="How many seconds to heal for"
         WinTop=0.202812
         WinLeft=0.495136
         WinWidth=0.163189
         WinHeight=0.042857
         TabOrder=2
         bBoundToParent=True
         MaxValue=20.0
         MinValue=0.0
         Value=5.0
     End Object
     e_NodeHealDuration=moSlider'CSLinkNuke.MutLinkNukeConfig.HealNodeDuration'

    ////////////////////////////////////////////////////////////////////////////////
    Begin Object Class=moCheckBox Name=HealPlayers
         CaptionWidth=0.800000
         ComponentWidth=0.200000
         StandardHeight=0.040000
         Caption="Heal Players:"
         OnCreateComponent=HealPlayers.InternalOnCreateComponent
         Hint="Heal players?"
         WinTop=0.302812
         WinLeft=0.085136
         WinWidth=0.143189
         WinHeight=0.042857
         TabOrder=3
         bBoundToParent=True
     End Object
     cb_bHealPlayers=moCheckBox'CSLinkNuke.MutLinkNukeConfig.HealPlayers'

    Begin Object Class=moSlider Name=HealPlayerRate
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Rate:"
         OnCreateComponent=HealPlayerRate.InternalOnCreateComponent
         Hint="Amount of health to add every 100ms"
         WinTop=0.302812
         WinLeft=0.295136
         WinWidth=0.123189
         WinHeight=0.042857
         TabOrder=4
         bBoundToParent=True
         MinValue=0.0
         MaxValue=100.0
         bIntSlider=True
     End Object
     e_PlayerHealRate=moSlider'CSLinkNuke.MutLinkNukeConfig.HealPlayerRate'

    Begin Object Class=moSlider Name=HealPlayerDuration
         ComponentWidth=0.600000
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Duration:"
         OnCreateComponent=HealPlayerDuration.InternalOnCreateComponent
         Hint="How many seconds to heal for"
         WinTop=0.302812
         WinLeft=0.495136
         WinWidth=0.163189
         WinHeight=0.042857
         TabOrder=5
         bBoundToParent=True
         MinValue=0.0
         MaxValue=20.0
     End Object
     e_PlayerHealDuration=moSlider'CSLinkNuke.MutLinkNukeConfig.HealPlayerDuration'

    Begin Object Class=moSlider Name=HealPlayerMax
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Max:"
         OnCreateComponent=HealPlayerMax.InternalOnCreateComponent
         Hint="Maximum amount of healing"
         WinTop=0.302812
         WinLeft=0.765136
         WinWidth=0.103189
         WinHeight=0.042857
         TabOrder=6
         bBoundToParent=True
         MinValue=0.0
         MaxValue=199.0
         bIntSlider=True
     End Object
     e_PlayerHealMax=moSlider'CSLinkNuke.MutLinkNukeConfig.HealPlayerMax'

    //////////////////////////////////////////////////////////////////////////////
    Begin Object Class=moCheckBox Name=HealVehicles
         CaptionWidth=0.800000
         ComponentWidth=0.200000
         StandardHeight=0.040000
         Caption="Heal Vehicles:"
         OnCreateComponent=HealVehicles.InternalOnCreateComponent
         Hint="Heal vehicles?"
         WinTop=0.402812
         WinLeft=0.085136
         WinWidth=0.143189
         WinHeight=0.042857
         TabOrder=7
         bBoundToParent=True
     End Object
     cb_bHealVehicles=moCheckBox'CSLinkNuke.MutLinkNukeConfig.HealVehicles'

    Begin Object Class=moSlider Name=HealVehicleRate
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Rate:"
         OnCreateComponent=HealVehicleRate.InternalOnCreateComponent
         Hint="Amount of health to add every 100ms"
         WinTop=0.402812
         WinLeft=0.295136
         WinWidth=0.123189
         WinHeight=0.042857
         TabOrder=8
         bBoundToParent=True
         MinValue=0.0
         MaxValue=1000.0
         bIntSlider=True
     End Object
     e_VehicleHealRate=moSlider'CSLinkNuke.MutLinkNukeConfig.HealVehicleRate'

    Begin Object Class=moSlider Name=HealVehicleDuration
         ComponentWidth=0.600000
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Duration:"
         OnCreateComponent=HealVehicleDuration.InternalOnCreateComponent
         Hint="How many seconds to heal for"
         WinTop=0.402812
         WinLeft=0.495136
         WinWidth=0.163189
         WinHeight=0.042857
         TabOrder=9
         bBoundToParent=True
         MinValue=0.0
         MaxValue=20.0
     End Object
     e_VehicleHealDuration=moSlider'CSLinkNuke.MutLinkNukeConfig.HealVehicleDuration'

    Begin Object Class=moSlider Name=HealVehicleMax
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Max:"
         OnCreateComponent=HealVehicleMax.InternalOnCreateComponent
         Hint="Maximum amount of healing"
         WinTop=0.402812
         WinLeft=0.765136
         WinWidth=0.103189
         WinHeight=0.042857
         TabOrder=10
         bBoundToParent=True
         MinValue=0.0
         MaxValue=1000.0
         bIntSlider=True
     End Object
     e_VehicleHealMax=moSlider'CSLinkNuke.MutLinkNukeConfig.HealVehicleMax'

    Begin Object Class=moSlider Name=NukeDamage
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="Damage:"
         OnCreateComponent=NukeDamage.InternalOnCreateComponent
         Hint="Nuke damage"
         WinTop=0.622000
         WinLeft=0.085136
         WinWidth=0.193189
         WinHeight=0.042857
         TabOrder=11
         bBoundToParent=True
         MinValue=0.0
         MaxValue=2000.0
         bIntSlider=True
     End Object
     e_Damage=moSlider'CSLinkNuke.MutLinkNukeConfig.NukeDamage'

    Begin Object Class=moSlider Name=CoreDamage
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="CoreDmg:"
         OnCreateComponent=NukeDamage.InternalOnCreateComponent
         Hint="Damage applied to power cores"
         WinTop=0.682000
         WinLeft=0.085136
         WinWidth=0.193189
         WinHeight=0.042857
         TabOrder=12
         bBoundToParent=True
         MinValue=0.0
         MaxValue=6000.0
         bIntSlider=True
     End Object
     e_CoreDamage=moSlider'CSLinkNuke.MutLinkNukeConfig.CoreDamage'

    Begin Object Class=moSlider Name=NodeDamage
         ComponentWidth=0.7
         StandardHeight=0.040000
         CaptionWidth=1.0
         Caption="NodeDmg:"
         OnCreateComponent=NukeDamage.InternalOnCreateComponent
         Hint="Damage applied to power nodes"
         //WinTop=0.682000
         WinTop=0.732000
         WinLeft=0.085136
         WinWidth=0.193189
         WinHeight=0.042857
         TabOrder=13
         bBoundToParent=True
         MinValue=0.0
         MaxValue=6000.0
         bIntSlider=True
     End Object
     e_NodeDamage=moSlider'CSLinkNuke.MutLinkNukeConfig.NodeDamage'
     
    Begin Object Class=moSlider Name=RespawnTime
         StandardHeight=0.040000
         CaptionWidth=1.0
         ComponentWidth=0.400000
         Caption="Respawn Time:"
         OnCreateComponent=RespawnTime.InternalOnCreateComponent
         Hint="Respawn time"
         WinTop=0.622000
         WinLeft=0.398325
         WinWidth=0.193189
         WinHeight=0.042857
         TabOrder=14
         bBoundToParent=True
         MinValue=1.0
         MaxValue=180.0
     End Object
     e_RespawnTime=moSlider'CSLinkNuke.MutLinkNukeConfig.RespawnTime'


////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
    Begin Object Class=moCheckBox Name=FlipNodes
         StandardHeight=0.040000
         CaptionWidth=1.000000
         Caption="Flip Nodes:"
         OnCreateComponent=FlipNodes.InternalOnCreateComponent
         Hint="If true, flips node to other team when hit"
         WinTop=0.487812
         WinLeft=0.085136
         WinWidth=0.143189
         WinHeight=0.042857
         TabOrder=15
         bBoundToParent=True
     End Object
     cb_bFlipNodes=moCheckBox'CSLinkNuke.MutLinkNukeConfig.FlipNodes'


     Begin Object Class=moButton Name=ResetSettingsButton
         StandardHeight=0.040000
         //CaptionWidth=1.000000
         ButtonCaption="Reset"
         OnCreateComponent=ResetSettingsButton.InternalOnCreateComponent
         Hint="Reset to default settings"
         //WinTop=0.722000
         WinTop=0.772000
         WinLeft=0.085136
         WinWidth=0.523189
         WinHeight=0.042857
         TabOrder=16
         bBoundToParent=True
     End Object
     b_ResetSettings=moButton'CSLinkNuke.MutLinkNukeConfig.ResetSettingsButton'

}