

class UTComp_ServerReplicationInfo extends ReplicationInfo;

var bool bEnableVoting;
var byte EnableBrightSkinsMode;
var bool bEnableClanSkins;
var bool bEnableTeamOverlay;
var bool bEnablePowerupsOverlay;
var bool bEnableExtraHudClock;
var byte EnableHitSoundsMode;
var bool bEnableScoreboard;
var bool bEnableWarmup;
var bool bEnableWeaponStats;
var bool bEnablePowerupStats;
var bool benableDoubleDamage;
var bool bEnableTimedOvertimeVoting;


var bool bEnableBrightskinsVoting;
var bool bEnableHitsoundsVoting;
var bool bEnableWarmupVoting;
var bool bEnableTeamOverlayVoting;
var bool bEnablePowerupsOverlayVoting;
var bool bEnableMapVoting;
var bool bEnableGametypeVoting;
var bool bEnableDoubleDamageVoting;
var byte ServerMaxPlayers;
var byte MaxPlayersClone;
var bool bEnableAdvancedVotingOptions;

var string VotingNames[15];
var string VotingOptions[15];
var bool bEnableTimedOvertime;

var PlayerReplicationInfo LinePRI[10];
var bool bEnableEnhancedNetCode;
var bool bEnableEnhancedNetCodeVoting;
var bool bForward;
var bool bEnableForwardVoting;

var bool bShieldFix;
var bool bAllowRestartVoteEvenIfMapVotingIsTurnedOff;

var int MaxMultiDodges;
var int MinNetSpeed;
var int MaxNetSpeed;

var int NodeIsolateBonusPct;
var int VehicleHealScore;
var int PowerNodeScore;
var int PowerCoreScore;
var int NodeHealBonusPct;
var bool bNodeHealBonusForLockedNodes;
var bool bNodeHealBonusForConstructor;
var bool bEnableReady;


replication
{
    reliable if(Role==Role_Authority)
        bEnableVoting, EnableBrightSkinsMode, EnableHitSoundsMode,
        bEnableClanSkins, bEnableTeamOverlay, bEnablePowerupsOverlay,
        bEnableWarmup, bEnableBrightskinsVoting,
        bEnableHitsoundsVoting, bEnableTeamOverlayVoting, bEnablePowerupsOverlayVoting,
        bEnableMapVoting, bEnableGametypeVoting, VotingNames,
        benableDoubleDamage, ServerMaxPlayers, bEnableTimedOvertime,
        MaxPlayersClone, bEnableAdvancedVotingOptions, VotingOptions, LinePRI, bEnableTimedOvertimeVoting,
        bEnableEnhancedNetCodeVoting,bEnableEnhancedNetCode, bEnableWarmupVoting, bForward, bEnableForwardVoting,
        bAllowRestartVoteEvenIfMapVotingIsTurnedOff, MaxMultiDodges, MinNetSpeed, MaxNetSpeed,
        NodeIsolateBonusPct, VehicleHealScore, PowerNodeScore, PowerCoreScore, NodeHealBonusPct, 
        bNodeHealBonusForLockedNodes, bNodeHealBonusForConstructor, bEnableReady;
}

defaultproperties
{
     bEnableVoting=False
     EnableBrightSkinsMode=3
     bEnableClanSkins=True
     bEnableTeamOverlay=True
     bEnablePowerupsOverlay=True;
     EnableHitSoundsMode=1
     bEnableScoreboard=False
     bEnableWarmup=True
     bEnableWeaponStats=True
     bEnablePowerupStats=True
     bEnableBrightskinsVoting=True
     bEnableHitsoundsVoting=False
     bEnableWarmupVoting=True
     bEnableTeamOverlayVoting=True
     bEnablePowerupsOverlayVoting=True;
     bEnableMapVoting=True
     bEnableGametypeVoting=True
     bEnableDoubleDamageVoting=True
     ServerMaxPlayers=10
     bEnableTimedOvertimeVoting=True
     bEnableTimedOvertime=False

     NodeIsolateBonusPct=20
     VehicleHealScore=500
     PowerNodeScore=10
     PowerCoreScore=5
     NodeHealBonusPct=60
     bEnableReady=true
     bNodeHealBonusForConstructor=false
}
