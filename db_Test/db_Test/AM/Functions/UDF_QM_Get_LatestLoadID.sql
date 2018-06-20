--get latest load id for batch id
Select Max(LoadID) from AM.artifact_ctrl_master nolock
