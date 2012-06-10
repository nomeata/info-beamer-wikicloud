require "wordcloud"

gl.setup(1024, 768)

font = resource.load_font("DejaVuSans.ttf")

headersize = 60
headerspace = 70

words = {}

padding = 5

horizByDepth = {true, true, true, false, false, true, false, false}

node.event("content_update", function(filename) 
    local str = resource.load_file("text")
    local n = 1
    words = {}
    for line in str:gmatch("[^\r\n]+") do
        count, oldcount, name = line:match("([0-9]+) ([0-9]+) (.*)")
        size = math.pow(count,0.4)*10
        words[n] = { name = name ;
            count = count;
	    oldcount = oldcount;
	    size = size;
            height = size + 2 * padding;
            width = font:write(10000, 10000, name, size, 1, 1, 1, 1) + 2 * padding
            }
        n = n + 1
        --if n > 50 then
        --    break
        --end
    end

    --table.sort (words, function(entry1,entry2)
    --    return entry1['count'] > entry2['count']
    --end)

    shuffle(words)

    tree = toTree(words,1)

    calcDim(tree, 1)

    scale = math.min(WIDTH/tree['width'], (HEIGHT-headerspace)/tree['height'])

    layout(tree, 0, 0, WIDTH/scale, (HEIGHT-headerspace)/scale)

    -- Now we could forget the tree and shuffle stuff around

end)

function node.render()
    local width = font:write(1000,1000,"Die GPN-12-Wiki-Hit-Cloud", headersize, 1, 1, 1)
    font:write((WIDTH-width)/2, 0, "Die GPN-12-Wiki-Hit-Cloud", headersize, 1, 1, 1)
    
    for n, entry in ipairs(words) do
    --forAllWords(tree, function(entry) 
	local f = 1 + (math.sin(entry['x']+sys.now()) + math.sin(entry['y']+sys.now()))*0.05
	local x = entry['x'] + padding + (entry['width_alloc'] - entry['width'] * f)/2
	local y = entry['y'] + padding + (entry['height_alloc'] - entry['height'] * f)/2

	local r, g, b
	if entry['oldcount'] < entry['count'] then
	    r = 1
	    b = 0
	    g = 0
	else
	    r = 1
	    b = 1
	    g = 1
	end
        font:write(
	    x * scale,
	    y * scale + headerspace,
	    entry['name'],
	    entry['size'] * scale * f,
	    r,g,b)
    end
end

