class CSChuteInvAtt extends InventoryAttachment placeable;

#exec obj load file=StaticMeshes\CSEjectorSeat_SM.usx package=CSEjectorSeat

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CSEjectorSeat.chutemesh'
     AttachmentBone="spine"
     DrawScale=2.000000
    Skins(0)=Texture'CSEjectorSeat.chute_up'
    Skins(1)=Texture'CSEjectorSeat.chute_down'
}
