local fileIO = {}

function fileIO.split(string, thing_to_split_by)
    local result = {};
    for match in (string..thing_to_split_by):gmatch("(.-)"..thing_to_split_by) do
        table.insert(result, match);
    end
    return result;
end

function fileIO.combine(array)
    local output = ""
    for i, value in ipairs(array) do
        if value ~= nil then
            output = output ..  value .. "\n"
        end
    end
    return output
end

function fileIO.write_to_new_file(name, data)
    name =  "saves/" .. name
    local file,err = io.open(name, "w+")
    if file then
        file:write(tostring(data))
        file:close()
    else
        return err
    end
end

function fileIO.write_array_to_file(name, array)
    fileIO.write_to_new_file(name, fileIO.combine(array))
end

function fileIO.read_file(name)
    name = "saves/" .. name
    local file,err = io.open(name, "r")

    if file then
        local contents = file:read"*a"
        file:close()
        return contents
    else
        return err
    end
end


function fileIO.count_lines_in_file(name)
    local counter = 0
    for _ in io.lines("saves/" .. name) do
        counter = counter + 1
    end
    return counter
end


function fileIO.read_lines_of_file_as_array(name)
    local lines = {}
    for line in io.lines("saves/" .. name) do
        lines[#lines + 1] = line
    end
    return lines
end

return fileIO