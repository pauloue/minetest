--Minetest
--Copyright (C) 2014 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


local function delete_world_formspec(dialogdata)
	return "size[10,2.5,true]" ..
		"label[0.5,0.5;" ..
		fgettext("Delete World \"$1\"?", dialogdata.delete_name) .. "]" ..
		"style[world_delete_confirm;bgcolor=red]" ..
		"button[0.5,1.5;2.5,0.5;world_delete_confirm;" .. fgettext("Delete") .. "]" ..
		"button[7.0,1.5;2.5,0.5;world_delete_cancel;" .. fgettext("Cancel") .. "]"
end

local function delete_world_buttonhandler(this, fields)
	if fields["world_delete_confirm"] then
		if this.data.delete_index > 0 and
				this.data.delete_index <= #menudata.worldlist:get_raw_list() then
			core.delete_world(this.data.delete_index)
			menudata.worldlist:refresh()
		end
		this:hide()
		return true

	elseif fields["world_delete_cancel"] then
		this:hide()
		return true
	end
end


function create_delete_world_dlg(name_to_del, index_to_del)
	assert(type(name_to_del) == "string")
	assert(type(index_to_del) == "number")

	local dlg = View.new({
		name = "delete_world",
		get_formspec = delete_world_formspec,
		button_handler = delete_world_buttonhandler
	})
	dlg.data.delete_name  = name_to_del
	dlg.data.delete_index = index_to_del

	return dlg
end
