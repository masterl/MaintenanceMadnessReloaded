return function( ... )
    local arguments = table.pack( ... )

    local path = arguments[1]

    for i = 2, arguments.n do
        path = path .. '/' .. arguments[i]
    end

    return path
end
