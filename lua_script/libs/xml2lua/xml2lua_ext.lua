
xml = xml or {}

function xml.parse_file(file_path)
    local xml2lua = require("libs.xml2lua.xml2lua")
    local handler = require("libs.xml2lua.xmlhandler.tree")
    local xml = xml2lua.loadFile(file_path)
    local parser = xml2lua.parser(handler)
    parser:parse(xml)
    return handler.root
end

function xml.print_table(xml_node)
    local xml2lua = require("libs.xml2lua.xml2lua")
    xml2lua.printable(xml_node)
end