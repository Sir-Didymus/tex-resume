-- Global table to store the resume data
ResumeData = {}

-- Function to load and parse the JSON resume data
function load_resume_data(filepath)
	-- Get a json parser
	local json_parser = get_json_parser()
	if not json_parser then
		error("CRITICAL: JSON parser not available! Cannot proceed.")
		return false
	end

	-- Load the `resume.json` file
	local file_content = load_resume_file(filepath)
	if not file_content then
		error("CRITICAL: " .. filepath .. " not found! Cannot proceed.")
		return false
	end

	-- Decode the file's content into the global `ResumeData` array
	if not decode_json_file(json_parser, file_content) then
		error("CRITICAL: Could not decode the JSON file's content! Cannot proceed.")
		return false
	end

	return true
end

-- Deep table access function with LaTeX escaping
function get_value(...)
	local args = { ... }
	local current = ResumeData

	for i, key in ipairs(args) do
		if type(current) ~= "table" then
			tex.sprint("\\texttt{Not found: invalid path}")
			return
		end
		current = current[key]
		if current == nil then
			tex.sprint("\\texttt{Not found: " .. table.concat(args, ".") .. "}")
			return
		end
	end

	-- Handle different types appropriately
	if type(current) == "table" then
		tex.sprint("\\texttt{Cannot print table}")
	elseif current == true then
		tex.sprint("true")
	elseif current == false then
		tex.sprint("false")
	else
		tex.sprint(escape_tex(tostring(current)))
	end
end

-- Function to sanitize strings for LaTeX
function escape_tex(str)
	if type(str) ~= "string" then
		return tostring(str)
	end

	-- Replace special TeX characters with escaped versions
	local result = str:gsub("([&%%$#_{}~^\\])", "\\%1")
	return result
end

-- Loads the `resume.json` file.
-- Returns the file's contents.
function load_resume_file(filepath)
	-- Open the json file
	local file = io.open(filepath, "r")
	if not file then
		error("CRITICAL: " .. filepath .. " not found! Cannot proceed.")
		return false
	end

	-- Read the file
	local content = file:read("*a")
	file:close()

	return content
end

-- Tries to load a JSON parser
function get_json_parser()
	-- Get the JSON parser from lualibs
	local json_parser = nil
	if utilities and utilities.json then
		json_parser = utilities.json
	else
		-- Try to load it directly
		pcall(require, "lualibs")
		if utilities and utilities.json then
			json_parser = utilities.json
		else
			error("CRITICAL: JSON parser not available! Cannot proceed.")
			return false
		end
	end

	return json_parser
end

-- Decodes the JSON file into the global `ResumeData` table
function decode_json_file(json_parser, content)
	if json_parser and json_parser.decode then
		ResumeData = json_parser.decode(content)
	elseif json_parser and json_parser.tolua then
		ResumeData = json_parser.tolua(content)
	else
		error("CRITICAL: JSON parser has no function for decoding! Cannot proceed.")
		return false
	end
	return true
end
