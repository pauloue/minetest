--Minetest
--Copyright (C) 2014 sapier
--Copyright (C) 2019 Paul Ouellette (pauloue)
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

ui = {}
ui.childlist = setmetatable({}, { __mode = "v" })

--- Set the root view.
-- @param view View
function ui.set_root(view)
	ui.root_view = view
end

View = {}

--- Set parent view.
-- @param view View
function View:set_parent(view)
	self.parent = view
end

--- Hide the active view and show this view.
function View:show()
	ui.active_view = self
	if self.on_enter then
		self:on_enter()
	end
end

--- Hide the view and show its parent.
function View:hide()
	self.parent:show()
end

--- Add a new view to the UI and return the view.
-- @param def table: View definition table.
-- def.name string: A unique name for the view.
-- def.get_formspec function(data): Function that returns the formspec.
-- def.button_handler function(self, fields): Function to handle buttons.
-- The formspec will be updated if it returns true.
-- def.on_enter function(self) or nil: Called when the view is shown.
-- @return View
-- Field data is a table used to store data specific to the view.
function View.new(def)
	assert(type(def.name) == "string")
	assert(type(def.get_formspec) == "function")
	assert(type(def.button_handler) == "function")

	local self = {}
	setmetatable(self, { __index = View })

	self.name = def.name
	self.parent = ui.root_view
	self.get_formspec = def.get_formspec
	self.button_handler = def.button_handler
	self.on_enter = def.on_enter
	self.data = {}

	ui.childlist[view.name] = view
	return self
end

--- Update the menu formspec based on the active view.
-- Call this function to initially show the menu formspec.
-- The root view must be set with ui.set_root before calling this function.
function ui.update()
	local formspec
	-- TODO: real_coordinates, textarea
	if gamedata.reconnect_requested then
		formspec = "size[12,5]" ..
			"label[0.5,0;" .. fgettext("The server has requested a reconnect:") ..
			"]textlist[0.2,0.8;11.5,3.5;;" .. gamedata.errormessage or "" ..
			"]button[6,4.6;3,0.5;btn_reconnect_no;" .. fgettext("Main menu") ..
			"]button[3,4.6;3,0.5;btn_reconnect_yes;" .. fgettext("Reconnect") .. "]"
	elseif gamedata.errormessage then
		local title
		if gamedata.errormessage:find("ModError") then
			title = fgettext("An error occurred in a Lua script, such as a mod:")
		else
			title = fgettext("An error occurred:")
		end
		formspec = "size[12,5]"..
			"label[0.5,0;" .. title ..
			"]textlist[0.2,0.8;11.5,3.5;;" .. gamedata.errormessage ..
			"]button[4.5,4.6;3,0.5;btn_error_confirm;" .. fgettext("Ok") .. "]"
	else
		if not ui.active_view then
			ui.root_view:show()
		end
		formspec = ui.active_view.get_formspec(view.data)
	end
	core.update_formspec(formspec)
end

--
-- Initialize callbacks
--

function core.button_handler(fields)
	if fields["btn_reconnect_yes"] then
		gamedata.reconnect_requested = false
		gamedata.errormessage = nil
		gamedata.do_reconnect = true
		core.start()
	elseif fields["btn_reconnect_no"] or fields["btn_error_confirm"] then
		gamedata.reconnect_requested = false
		gamedata.errormessage = nil
		ui.update()
	end

	if ui.active_view:handle_buttons(fields) then
		ui.update()
	end
end

function core.event_handler(event)
	if event == "MenuQuit" then
		if ui.active_view == ui.root_view then
			core.close()
		else
			ui.active_view:hide()
			ui.update()
		end
	end
end
