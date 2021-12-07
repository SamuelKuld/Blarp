local fileIO = {}

function Split(string, thing_to_split_by)
    local result = {};
    for match in (string..thing_to_split_by):gmatch("(.-)"..thing_to_split_by) do
        table.insert(result, match);
    end
    return result;
end

function Combine(array)
    local output = ""
    for i, value in ipairs(array) do
        output = output .. value
    end
    return output
end

function fileIO.write_to_new_file(name, data)
    local file,err = io.open(name, "w+")
    if file then
        file:write(tostring(data))
        file:close()
    else
        return err
    end
end

function fileIO.write_array_to_file(name, array)
    fileIO.write_to_new_file(name, Combine(array))
end

function fileIO.read_file(name)
    local file,err = io.open(name, "r")

    if file then
        local contents = file:read"*a"
        file:close()
        return contents
    else
        return err
    end
end

function fileIO.read_lines_of_file_as_array(name)
    local file,err = io.open(name, "r")
    if file then
        local contents_as_string = fileIO.read_file(name)
        local contents = Split(contents_as_string, "\n")
        file:close()
        return contents
    else
        return err
    end
end


fileIO.write_to_new_file("joe.dat", "Something\nIs\nWatching\nMe")
for i,v in ipairs(fileIO.read_lines_of_file_as_array('joe.dat')) do
    print(v)
end
return fileIO