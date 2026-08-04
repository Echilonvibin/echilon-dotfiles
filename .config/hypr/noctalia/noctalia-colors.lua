local M = {}

M.primary   = "rgba(a7c080ff)"
M.surface   = "rgba(232a2eff)"
M.secondary = "rgba(d3c6aaff)"
M.error     = "rgba(e67e80ff)"
M.tertiary  = "rgba(9da9a0ff)"
M.surface_lowest = "rgba(252c30ff)"

M.general = {
	col = {
		active_border = M.primary,
		inactive_border = M.surface,
	},
}

M.group = {
	col = {
		border_active = M.secondary,
		border_inactive = M.surface,
		border_locked_active = M.error,
		border_locked_inactive = M.surface,
	},
	groupbar = {
		col = {
			active = M.secondary,
			inactive = M.surface,
			locked_active = M.error,
			locked_inactive = M.surface,
		},
	},
}

M.config = {
	general = M.general,
	group = M.group,
}
        
return M
