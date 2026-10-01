-- require("full-border"):setup({
-- type = ui.Border.ROUNDED,
-- })

-- Track current working directory for seamless rice-switch reload
ps.sub("cd", function()
	local env_file = os.getenv("YAZI_LIVE_CWD_FILE")
	if env_file and cx and cx.active and cx.active.current and cx.active.current.cwd then
		local f = io.open(env_file, "w")
		if f then
			f:write(tostring(cx.active.current.cwd))
			f:close()
		end
	end
end)
