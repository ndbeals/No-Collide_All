TOOL.Category		= "Constraints"
TOOL.Name			= "#No-Collide All Multi"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "on" ] = 1

if ( CLIENT ) then
    language.Add( "Tool.nocollideall_multi.name", "Multi No-Collide All tool" )
    language.Add( "Tool.nocollideall_multi.desc", "Toggle collisions for an entity or a selected set of entities." )
    language.Add( "Tool.nocollideall_multi.0", "Primary: Select a prop to disable collisions. (Use to select all) Secondary: Confirm and disable collisions. Reload: Clear Targets." )
end

TOOL.enttbl = {}

/*******************************************************************************************************
Purpose: this function is what's needed to make dupe support work the "_" is a replacement for the Player argument whiich the function needs
*******************************************************************************************************/
local function SetCollisionGroup(Entity,Group)
	if not Group then return false end
	Entity:SetCollisionGroup(Group)
	Entity.CollisionGroup = Group
end


function TOOL:LeftClick(Trace)
	if CLIENT then return true end
	local ent = Trace.Entity
	if not IsValid(ent) then return false end

	if not self.enttbl then self.enttbl = {} end

	if self:GetOwner():KeyDown(IN_USE) then
		for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
			if !self.enttbl[v] then
				self.enttbl[v] = v:GetColor()
				v:SetColor(40,255,0,150)
			end
		end
	else
		if not self.enttbl[ent] then
			self.enttbl[ent] = ent:GetColor()
			ent:SetColor(40,255,0,150)
		else
			local temp = self.enttbl[ent]
			ent:SetColor(temp.r,temp.g,temp.b,temp.a)
			self.enttbl[ent] = nil
		end
	end
	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return true end
	if table.Count(self.enttbl) < 1 then return end

	local onoff = self:GetClientNumber( "on" )
	local ent = trace.Entity

	for k,v in pairs(self.enttbl) do

		if IsValid(k) then
			k:SetColor(v)

			if onoff == 1 then
				group = COLLISION_GROUP_WORLD
			end
			if onoff == 0 then
				group = COLLISION_GROUP_NONE
			end	
			SetCollisionGroup(k,group)
			
			if freeze == 1 then
				local phys = k:GetPhysicsObject()
				if phys:IsMoveable() then
					phys:EnableMotion(false)
					phys:Wake()
				end
			end
		end
	end 

	self.enttbl = {}
	return true
end


function TOOL:Reload()
	if CLIENT then return true end
	if table.Count(self.enttbl) < 1 then return end
	
	for k,v in pairs(self.enttbl) do
		if k:IsValid() then
			k:SetColor(v)
		end
	end
	self.enttbl = {}
	return true
end

if CLIENT then
	function TOOL.BuildCPanel(Panel)
		Panel:AddControl("Header",{Text = "#nocollideall_multi.name", Description	= "Toggle collisions for an entity or a selected set of entities."})	
		local temp = Panel:AddControl("CheckBox", {Label = "Collisions", Description ="Enable or disable collisions", Command = "nocollideall_multi_on"})
		temp:SetToolTip("Ticking this means that collisions with everything will be disabled for the selected entities.")
	end
end