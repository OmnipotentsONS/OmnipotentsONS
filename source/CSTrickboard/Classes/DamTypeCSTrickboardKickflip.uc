class DamTypeCSTrickboardKickflip extends DamTypeRoadKill;

defaultproperties
{
     VehicleClass=Class'CSTrickboard.CSTrickboard'
     DeathString="%k did a 720 kickflip on %o's head"
     bLocationalHit=True
     bAlwaysSevers=True
     bSpecial=True
     bNeverSevers=False
     VehicleDamageScaling=0.166    
     MessageClass=Class'CSTrickboardKillMessage'
}