return function(folder, file)
    folder = folder or "Settings"
    file = file or "config.json"

    local function encode(t)
        local function ser(obj)
            local tp = type(obj)
            if tp == "string" then return '"'..obj:gsub('\\','\\\\'):gsub('"','\\"')..'"'
            elseif tp == "number" or tp == "boolean" then return tostring(obj)
            elseif tp == "table" then
                local r = "{"
                local first = true
                for k,v in pairs(obj) do
                    if not first then r = r.."," end
                    first = false
                    r = r..'"'..tostring(k)..'":'..ser(v)
                end
                return r.."}"
            end
            return "null"
        end
        return ser(t)
    end

    local function decode(str)
        if not str or str == "" then return {} end
        local ok, result = pcall(function()
            if game then
                return game:GetService("HttpService"):JSONDecode(str)
            else
                return loadstring("return "..str:gsub("null","nil"))()
            end
        end)
        return ok and result or {}
    end

    return {
        save = function(data)
            if not isfolder or not makefolder or not writefile then return false end
            if not isfolder(folder) then makefolder(folder) end
            local ok = pcall(writefile, folder.."/"..file, encode(data))
            return ok
        end,

        load = function()
            if not readfile or not isfile then return {} end
            local path = folder.."/"..file
            if not isfile(path) then return {} end
            local ok, content = pcall(readfile, path)
            return ok and decode(content) or {}
        end
    }
end
