


util.AddNetworkString("hev_voice")

hook.Add("EntityTakeDamage","HEV_Voice_System",function( ply, dmg )

	if not ply:IsPlayer() then return end

	net.Start("hev_voice")
	net.WriteUInt( dmg:GetDamageType() , 32 )
	net.WriteUInt( dmg:GetDamage() , 32 )
	net.Send( ply )

end)