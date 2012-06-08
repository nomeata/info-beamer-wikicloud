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

-- from http://www.gammon.com.au/forum/?id=9908
function shuffle(t)
  local n = #t
 
  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
 
  return t
end

function join(horiz, dim1, dim2)
    if horiz then
	return {
	    w = math.max(dim1['w'], dim2['w']);
	    h = dim1['h'] + dim2['h']
	}
    else
	return {
	    w = dim1['w'] + dim2['w'];
	    h = math.max(dim1['h'], dim2['h'])
	}
    end
end

function stockmayer(tree)
    if tree['name'] then
	tree['orient'] = {
	    { w = tree['width'];
	      h = tree['height'];
	    }
	}
    else
	

    end

end

function calcDim(tree, depth)
    if tree['left'] then
	calcDim(tree['left'], depth + 1)
	calcDim(tree['right'], depth + 1)

        local wh = math.max(tree['left']['width'], tree['right']['width'])
        local hh = tree['left']['height'] + tree['right']['height']

        local wv = tree['left']['width'] + tree['right']['width']
        local hv = math.max(tree['left']['height'], tree['right']['height'])


        local horiz = horizByDepth[depth]
        --[[
        rdh = math.abs((WIDTH/HEIGHT)/(wh/hh) - 1)
        rdv = math.abs((WIDTH/HEIGHT)/(wv/hv) - 1)

        print (rdh, rdv)

        local horiz
        if rdh > 0.7 or rdv > 0.7 then
            if rdh > rdv then
                horiz = false
            else
                horiz = true
            end
        elseif math.random(0, 3) == 1 then 
            horiz = true
        end
        ]]

        if horiz then
            tree['horiz'] = true
            tree['width'] = wh
            tree['height'] = hh
        else
            tree['horiz'] = false
            tree['width'] = wv
            tree['height'] = hv
        end
    end
end

function layout(tree, x, y, w, h)
    tree['x'] = x
    tree['y'] = y
    tree['width_alloc'] = w
    tree['height_alloc'] = h
    if tree['left'] then
	if tree['horiz'] then
	    local alloc_left = tree['left']['height']/(tree['left']['height'] + tree['right']['height']) * h
	    layout(tree['left'],
		x, y,
		w, alloc_left)
	    layout(tree['right'],
		x, y + alloc_left,
		w, h - alloc_left)
	else
	    local alloc_left = tree['left']['width']/(tree['left']['width'] + tree['right']['width']) * w
	    layout(tree['left'],
		x, y,
		alloc_left, h)
	    layout(tree['right'],
		x + alloc_left, y,
		w - alloc_left, h)
	end
    else 
    end
end

function toTree(words,depth)
    local left = {}
    local left_cost = 0
    local right = {}
    local right_cost = 0

    local horiz = horizByDepth[depth]
    local what
    if horiz then
	what = 'width'
    else
	what = 'height'
    end

    if (#words > 1) then
	for n, entry in ipairs(words) do
	    if left_cost <= right_cost then
		table.insert(left, entry)
		left_cost = left_cost + entry[what]
	    else
		table.insert(right, entry)
		right_cost = right_cost + entry[what]
	    end
	end

	local tree = {
	    left = toTree(left,depth + 1);
	    right = toTree(right,depth + 1);
	}
        return tree

    else
	return words[1]
    end
end

function area(tree)
    return tree['width'] * tree['height']
end


function forAllWords(tree, f)
    if tree['left'] then forAllWords(tree['left'], f) end
    if tree['right'] then forAllWords(tree['right'], f) end
    if tree['name'] then f(tree) end
end

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
	    b = 0.5
	    g = 0.5
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


-- Unused:
function shufflePos(words)
    for n, entry in pairs(words) do
        local bad = true
        while bad do
            local bad = false
            for n2, entry2 in pairs(words) do
                if n ~= n2 then
                    if collide(entry, entry2) then
                        bad = true
                    end
                end
            end
            if bad then
                randomPos(entry) 
            end
        end
    end
end

function randomPos(e) 
    e['x'] = math.random(0, WIDTH - e['width']) ;
    e['y'] = math.random(0, HEIGHT - e['height'] - headerspace) ;
end


function collide(e1,e2)
    local x1 = e1['x']
    local y1 = e1['y']
    local x2 = e2['x']
    local y2 = e2['y']
    local dx1 = e1['width']
    local dx2 = e1['width']
    local dy1 = e1['height']
    local dy2 = e1['height']
    return 
       (    (x1 < x2 and x2 < x1 + dx1)
         or (x1 < x2 + dx2 and x2 + dx2 < x1 + dx1)
         or (x2 < x1 and x1 < x2 + dx2)
         or (x2 < x1 + dx1 and x1 + dx1 < x2 + dx2)
       ) and
       (    (y1 < y2 and y2 < y1 + dy1)
         or (y1 < y2 + dy2 and y2 + dy2 < y1 + dy1)
         or (y2 < y1 and y1 < y2 + dy2)
         or (y2 < y1 + dy1 and y1 + dy1 < y2 + dy2)
       )
end
