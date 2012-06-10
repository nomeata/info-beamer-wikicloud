
horizByDepth = {true, true, true, false, false, true, false, false}

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



