basicGuiStylePrototypes = data.raw["gui-style"]["default"]

basicGuiStylePrototypes["maintenanceMadness_item_table"] = {
	type = "table_style",
	parent = "bordered_table",
	-- default orange with alfa
	hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
	selected_row_color = default_orange_color,
	top_cell_padding = 4,
	bottom_cell_padding = 7,
	left_cell_padding = 10,
	right_cell_padding = 10,
	odd_row_graphical_set =	{
		filename = "__core__/graphics/gui.png",
		position = {78, 18},
		size = 1,
		opacity = 0.2,
		scale = 1
	},
	column_alignments = {
		{
			column = 1,
			alignment = "middle-left"
		},
		{
			column = 2,
			alignment = "middle-center"
		},
		{	
			column = 3, 
			alignment = "middle-center"
		}
	},
	column_widths =	{
		{ -- entity name
		  column = 1,
		  width = 237
		},
		{ -- item slots
		  column = 2,
		  width = 214
		},
		{ -- information
		  column = 3,
		  width = 216
		}
	}
}

basicGuiStylePrototypes["maintenanceMadness_item_header_table"] = {
	type = "table_style",
	parent = "table",
	left_cell_padding = 10,
	right_cell_padding = 10,
	column_alignments = {
		{
			column = 1,
			alignment = "middle-center"
		},
		{
			column = 2,
			alignment = "middle-center"
		},
		{	
			column = 3, 
			alignment = "middle-center"
		}
	},
	column_widths =	{
		{ -- entity name
		  column = 1,
		  width = 241
		},
		{ -- item slots
		  column = 2,
		  width = 218
		},
		{ -- information
		  column = 3,
		  width = 222
		}
	}
}

basicGuiStylePrototypes["maintenanceMadness_red_notched_slider"] = {
	type = "slider_style",
	parent = "notched_slider",
	full_bar = {
		base = {position = {240, 71}, corner_size = 8},
		shadow = default_dirt
	}
}