--[[
Generic layout algorith for fitting squares of varying size into a square of
approximately minimal size.

Arguments:
    words:
        List of tables with keys 'width' and 'height'
    width, height:
        Used to specify the desired aspect ratio
    horizByDepth:
        Whether the binary tree should split horizontally or vertically at a
        certain depth.

Returns:
    The scaling that should be applied to the calculated coordinates and the
    rendering of the squared to fill the given width and height. 

Effect:
    The argument words is modified: Its order is randomized and every element
    obtains further values describing the rectangle allocated for the element:
        'x', 'y':
            Position of the allocated rectangle (corner)
        'width_alloc, 'height_alloc':
            Size of the allocated rectangle
    The x/y positions do _not_ center the element but describe the corner of
    the allocated space.
--]]

function wordCloud(words, width, height, horizByDepth)
    -- Put the words in random order
    shuffle(words) 
    -- Create a binary tree blanced by size (top-down)
    local tree = toTree(words, horizByDepth, 1)
    -- Calculate the minimum dimensions of each node (bottom-up)
    calcDim(tree, horizByDepth, 1)
    local scale = math.min(width/tree['width'], height/tree['height'])
    -- Lay out allocated rectangles for each node, including leaves.
    layout(tree, 0, 0, width/scale, height/scale)
    return scale
end

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

function toTree(words, horizByDepth, depth)
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
	    left = toTree(left, horizByDepth, depth + 1);
	    right = toTree(right, horizByDepth, depth + 1);
	}
        return tree

    else
	return words[1]
    end
end




function calcDim(tree, horizByDepth, depth)
    if tree['left'] then
	calcDim(tree['left'],  horizByDepth, depth + 1)
	calcDim(tree['right'], horizByDepth, depth + 1)

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

