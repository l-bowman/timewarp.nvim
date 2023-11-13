local M = {}

local last_edit_location = nil
local last_yank_location = nil
local last_yank_location_buffer_length = nil
local initial_cursor_position = nil
local initial_cursor_position_buffer_length = nil

local function is_position_valid_in_buffer(bufnr, pos)
	if vim.api.nvim_buf_is_valid(bufnr) then
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		local line_length = #(vim.api.nvim_buf_get_lines(bufnr, pos[1] - 1, pos[1], false)[1] or "")
		return pos[1] <= line_count and pos[2] <= line_length
	end
	return false
end

local function navigate_to_location(location, position_type)
	if location and is_position_valid_in_buffer(location.bufnr, location.pos) then
		vim.api.nvim_set_current_buf(location.bufnr)
		vim.api.nvim_win_set_cursor(0, location.pos)
		vim.api.nvim_out_write("TIMEWARP: Moving to " .. position_type .. " location.\n")
	else
		vim.api.nvim_out_write("TIMEWARP: No valid location set.\n")
	end
end

function M.update_last_edit_location()
	-- Check if the buffer is associated with a regular file
	local bufnr, pos = vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)
	local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
	if buftype ~= "" then
		-- Exit the function if the buffer is not a regular file (e.g., it's a quickfix, terminal, etc.)
		return
	end
	last_edit_location = { bufnr = bufnr, pos = pos }

	-- nil the initial cursor position if the last edit location is on the same line
	if initial_cursor_position and initial_cursor_position.pos[1] == last_edit_location.pos[1] then
		initial_cursor_position = nil
	else
		if initial_cursor_position and initial_cursor_position.bufnr == bufnr then
			if
				initial_cursor_position.pos[1] > pos[1]
				or (initial_cursor_position.pos[1] == pos[1] and initial_cursor_position.pos[2] > pos[2])
			then
				local buffer_length = vim.api.nvim_buf_line_count(bufnr)
				if buffer_length ~= initial_cursor_position_buffer_length then
					initial_cursor_position.pos[1] = initial_cursor_position.pos[1]
						+ buffer_length
						- initial_cursor_position_buffer_length
					initial_cursor_position_buffer_length = buffer_length
				end
			end
		end
	end

	-- nil the last yank location if the last edit location is on the same line
	if last_yank_location and last_yank_location.pos[1] == last_edit_location.pos[1] then
		last_yank_location = nil
	else
		if last_yank_location and last_yank_location.bufnr == bufnr then
			if
				last_yank_location.pos[1] > pos[1]
				or (last_yank_location.pos[1] == pos[1] and last_yank_location.pos[2] > pos[2])
			then
				local buffer_length = vim.api.nvim_buf_line_count(bufnr)
				if buffer_length ~= last_yank_location_buffer_length then
					last_yank_location.pos[1] = last_yank_location.pos[1]
						+ buffer_length
						- last_yank_location_buffer_length
					last_yank_location_buffer_length = buffer_length
				end
			end
		end
	end
end

function M.update_last_yank_location(event)
	if event.operator == "d" then
		return
	end
	local bufnr, pos = vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)
	last_yank_location = { bufnr = bufnr, pos = pos }
	last_yank_location_buffer_length = vim.api.nvim_buf_line_count(bufnr)
end

function M.goto_last_edit()
	initial_cursor_position = { bufnr = vim.api.nvim_get_current_buf(), pos = vim.api.nvim_win_get_cursor(0) }
	initial_cursor_position_buffer_length = vim.api.nvim_buf_line_count(initial_cursor_position.bufnr)
	navigate_to_location(last_edit_location, "last edit")
end

function M.goto_last_yank()
	initial_cursor_position = { bufnr = vim.api.nvim_get_current_buf(), pos = vim.api.nvim_win_get_cursor(0) }
	initial_cursor_position_buffer_length = vim.api.nvim_buf_line_count(initial_cursor_position.bufnr)
	navigate_to_location(last_yank_location, "last yank")
end

function M.goto_initial_cursor()
	navigate_to_location(initial_cursor_position, "initial cursor")
end

-- autocmds to capture the last edit location
vim.api.nvim_exec(
	[[
    augroup TimewarpLastEditTracker
        autocmd!
        autocmd TextChanged,TextChangedI * lua require'timewarp'.update_last_edit_location()
        autocmd TextYankPost * lua require'timewarp'.update_last_yank_location(vim.v.event)

    augroup END
    ]],
	false
)

-- user commands for easier usage
vim.api.nvim_exec(
	[[
    command! TimewarpLastEdit lua require'timewarp'.goto_last_edit()
    command! TimewarpLastYank lua require'timewarp'.goto_last_yank()
    command! TimewarpReturn lua require'timewarp'.goto_initial_cursor()
    ]],
	false
)

-- Setup function to initialize the plugin with optional configurations
function M.setup(opts)
	opts = opts or {}
end

return M
