Class ONSPlusRulesPage extends FloatingWindow;

var automated GUITabControl MainTab;

// Option status (static labels)
var automated moEditBox l_bSelectableExits;
var automated moEditBox l_bAllowEnhancedRadar;
var automated moEditBox l_bDropChecks;
var automated moEditBox l_bNodeHealScoreFix;
var automated moEditBox l_bVehicleHealScoreFix;
var automated moEditBox l_HealScoreQuota;
var automated moEditBox l_bVehicleDamageScore;
var automated moEditBox l_DamageScoreQuota;
var automated moEditBox l_bIsolateNodeBonus;
var automated moEditBox l_IsolateBonusPctPerNode;
var automated moEditBox l_bAllowPreferredTeam;
var automated moEditBox l_bDisablePreMatchTeamSwitch;
var automated moEditBox l_bVehicleDistanceCheck;
var automated moEditBox l_RespawnTimerDistance;
var automated moEditBox l_DistanceCheckTimer;
var automated moEditBox l_bPallyShieldBonus;
var automated moEditBox l_PallyScoreQuota;

// Setup property values
function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	local ONSPlusGameReplicationInfo GRI;

	Super.InitComponent(MyController, MyComponent);


	if (PlayerOwner() != none && PlayerOwner().GameReplicationInfo != none && ONSPlusGameReplicationInfo(PlayerOwner().GameReplicationInfo) != none)
	{
		GRI = ONSPlusGameReplicationInfo(PlayerOwner().GameReplicationInfo);

		l_bSelectableExits.SetText(string(GRI.bSelectableExits));
		l_bSelectableExits.SetReadOnly(True);

		l_bAllowEnhancedRadar.SetText(string(GRI.bAllowEnhancedRadar));
		l_bAllowEnhancedRadar.SetReadOnly(True);

		l_bDropChecks.SetText(string(GRI.bDropChecks));
		l_bDropChecks.SetReadOnly(True);

		l_bNodeHealScoreFix.SetText(string(GRI.bNodeHealScoreFix));
		l_bNodeHealScoreFix.SetReadOnly(True);

		l_bVehicleHealScoreFix.SetText(string(GRI.bVehicleHealScoreFix));
		l_bVehicleHealScoreFix.SetReadOnly(True);

		l_HealScoreQuota.SetText(string(GRI.HealScoreQuota));
		l_HealScoreQuota.SetReadOnly(True);

		l_bVehicleDamageScore.SetText(string(GRI.bVehicleDamageScore));
		l_bVehicleDamageScore.SetReadOnly(True);

		l_DamageScoreQuota.SetText(string(GRI.DamageScoreQuota));
		l_DamageScoreQuota.SetReadOnly(True);

		l_bIsolateNodeBonus.SetText(string(GRI.bIsolateNodeBonus));
		l_bIsolateNodeBonus.SetReadOnly(True);

		l_IsolateBonusPctPerNode.SetText(string(GRI.IsolateBonusPctPerNode));
		l_IsolateBonusPctPerNode.SetReadOnly(True);

		l_bAllowPreferredTeam.SetText(string(GRI.bAllowPreferredTeam));
		l_bAllowPreferredTeam.SetReadOnly(True);

		l_bDisablePreMatchTeamSwitch.SetText(string(!GRI.bDisablePreMatchTeamSwitch));
		l_bDisablePreMatchTeamSwitch.SetReadOnly(True);

		l_bVehicleDistanceCheck.SetText(string(GRI.bVehicleDistanceCheck));
		l_bVehicleDistanceCheck.SetReadOnly(True);

		l_RespawnTimerDistance.SetText(string(GRI.RespawnTimerDistance));
		l_RespawnTimerDistance.SetReadOnly(True);

		l_DistanceCheckTimer.SetText(string(GRI.DistanceCheckTimer));
		l_DistanceCheckTimer.SetReadOnly(True);

		l_bPallyShieldBonus.SetText(string(GRI.bPallyShieldScore));
		l_bPallyShieldBonus.SetReadOnly(True);

		l_PallyScoreQuota.SetText(string(GRI.PallyScoreQuota));
		l_PallyScoreQuota.SetReadOnly(True);
	}

	WindowName="ONSPlus Server Rules";

	t_WindowTitle.SetCaption(WindowName);
}

defaultproperties
{
	Begin Object Class=moEditBox Name=SelectableExitsLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.100000
		ComponentWidth=0.710000
		Caption="Selectable exits"
		Hint="Wether or not the server has selectable exits enabled"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=21
	End Object
	l_bSelectableExits=SelectableExitsLabel

	Begin Object Class=moEditBox Name=EnhancedRadarLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.150000
		ComponentWidth=0.710000
		Caption="Enhanced Radar"
		Hint="Wether or not the server has enabled the enhanced radar"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=22
	End Object
	l_bAllowEnhancedRadar=EnhancedRadarLabel

	Begin Object Class=moEditBox Name=DropCheckLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.200000
		ComponentWidth=0.710000
		Caption="Drop Checks"
		Hint="Wether or not the server has vehicle exit height checks enabled"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=23
	End Object
	l_bDropChecks=DropCheckLabel

	Begin Object Class=moEditBox Name=NodeHealScoreFixLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.250000
		ComponentWidth=0.710000
		Caption="Shared Node Score"
		Hint="Wether or not the server has enabled the sharing of points when linking up to charge a node"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=24
	End Object
	l_bNodeHealScoreFix=NodeHealScoreFixLabel

	Begin Object Class=moEditBox Name=VehicleHealScoreFixLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.300000
		ComponentWidth=0.710000
		Caption="Vehicle Heal Score"
		Hint="Wether or not the server has enabled getting points for healing a vehicle"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=25
	End Object
	l_bVehicleHealScoreFix=VehicleHealScoreFixLabel

	Begin Object Class=moEditBox Name=HealScoreQuotaLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.350000
		ComponentWidth=0.710000
		Caption="Vehicle Heal Quota"
		Hint="The amount of a vehicles health you have to heal before getting one point"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=26
	End Object
	l_HealScoreQuota=HealScoreQuotaLabel

	Begin Object Class=moEditBox Name=VehicleDamageScoreLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.400000
		ComponentWidth=0.710000
		Caption="Vehicle Damage Score"
		Hint="Wether or not the server has enabled getting points for damaging a vehicle"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=27
	End Object
	l_bVehicleDamageScore=VehicleDamageScoreLabel

	Begin Object Class=moEditBox Name=DamageScoreQuotaLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.450000
		ComponentWidth=0.710000
		Caption="Vehicle Damage Quota"
		Hint="The amount of damage you have to give a vehicle before getting one point"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=28
	End Object
	l_DamageScoreQuota=DamageScoreQuotaLabel

	Begin Object Class=moEditBox Name=IsolateNodeBonusLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.500000
		ComponentWidth=0.710000
		Caption="Isolate Score"
		Hint="Wether or not the server has enabled bonus points for isolating a node"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=29
	End Object
	l_bIsolateNodeBonus=IsolateNodeBonusLabel

	Begin Object Class=moEditBox Name=IsolateBonusPctPerNodeLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.550000
		ComponentWidth=0.710000
		Caption="Isolate Bonus"
		Hint="The percentage by which your score is increased for every isolated node (the more nodes you isolated, the bigger this bonus)"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=30
	End Object
	l_IsolateBonusPctPerNode=IsolateBonusPctPerNodeLabel

	Begin Object Class=moEditBox Name=AllowPreferredTeamLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.600000
		ComponentWidth=0.710000
		Caption="Allow Preferred Team"
		Hint="Wether or not the server is allowing people to use their preferred team"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=31
	End Object
	l_bAllowPreferredTeam=AllowPreferredTeamLabel

	Begin Object Class=moEditBox Name=DisablePreMatchTeamSwitchLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.650000
		ComponentWidth=0.710000
		Caption="Allow PreMatch Team Change"
		Hint="Wether or not the server is allowing people to change team before the match begins"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=32
	End Object
	l_bDisablePreMatchTeamSwitch=DisablePreMatchTeamSwitchLabel

	Begin Object Class=moEditBox Name=VehicleDistanceCheckLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.700000
		ComponentWidth=0.710000
		Caption="Vehicle Distance Check"
		Hint="Wether or not the server checks the distance of locked vehicles from their spawns, respawning them if they are too far away"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=32
	End Object
	l_bVehicleDistanceCheck=VehicleDistanceCheckLabel

	Begin Object Class=moEditBox Name=RespawnTimerDistanceLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.750000
		ComponentWidth=0.710000
		Caption="Respawn Timer Distance"
		Hint="The distance at which the vehicle distance checks enable the vehicles respawn timer"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=32
	End Object
	l_RespawnTimerDistance=RespawnTimerDistanceLabel

	Begin Object Class=moEditBox Name=DistanceCheckTimerLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.800000
		ComponentWidth=0.710000
		Caption="Distance Check Timer"
		Hint="When the vehicle distance checks enable the respawn timer, this is the respawn delay"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=32
	End Object
	l_DistanceCheckTimer=DistanceCheckTimerLabel

	Begin Object Class=moEditBox Name=PallyShieldBonusLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.850000
		ComponentWidth=0.710000
		Caption="Pally Shield Score"
		Hint="Wether or not the server has enabled points for absorbing damage with the Pally shield"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=32
	End Object
	l_bPallyShieldBonus=PallyShieldBonusLabel

	Begin Object Class=moEditBox Name=PallyScoreQuotaLabel
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.900000
		ComponentWidth=0.710000
		Caption="Pally Shield Quota"
		Hint="The amount of damage your Pally's shield must absorb before getting one point"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=32
	End Object
	l_PallyScoreQuota=PallyScoreQuotaLabel

	DefaultWidth=0.250000
	DefaultHeight=0.300000
	DefaultLeft=0.110313
	DefaultTop=0.057916
	WinWidth=0.500000
	WinHeight=0.700000
	WinLeft=0.110313
	WinTop=0.057916

	bRenderWorld=True
	bAllowedAsLast=True
	bCaptureInput=True
	bResizeWidthAllowed=False
	bResizeHeightAllowed=False
}