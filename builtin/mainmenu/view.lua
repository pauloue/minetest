--Minetest
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

View = {}

--- Set parent view.
-- @param view View
function View:set_parent(view)
	self.parent = view
end

--- Hide the active view and show this view.
function View:show()
	ui.active_view = self
end

--- Hide the view and show its parent.
function View:hide()
	ui.active_view = self.parent
end

--- Hide the view and delete it from the UI.
function View:delete()
	self:hide()
	ui.delete(self)
end

--- Add a new view to the UI and return the view.
-- @param name string: A unique name for the view.
-- @param get_formspec function(data): Function that returns the formspec.
-- @param button_handler function(self, fields): Function to handle buttons.
-- The formspec will be updated if it returns true.
-- @return View
-- Field data is a table used to store data specific to the view.
function View.new(name, get_formspec, button_handler)
	assert(type(name) == "string")
	assert(type(get_formspec) == "function")
	assert(type(button_handler) == "function")

	local self = {}
	setmetatable(self, { __index = View })

	self.name = name
	self.parent = ui.root_view
	self.get_formspec = get_formspec
	self.button_handler = button_handler
	self.data = {}

	ui.add(self)
	return self
end
