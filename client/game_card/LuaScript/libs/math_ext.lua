function math.isinf(v)
	return v == math.huge or v == -math.huge
end

function math.isnan(v)
	return v ~= v
end

function math.finite(v)
	return type(v) == "number" and not math.isinf(v) and not math.isnan(v)
end

function math.equal(v1, v2, e)
	e = e or 0.000000001
	return math.abs(v1 - v2) < e
end


math.RECIPROCAL_PI = 1.0 / math.pi
math.HALF_PI = math.pi / 2.0
math.DEGREES_TO_RADIANS = math.pi / 180.0 		-- 角度转弧度
math.RADIANS_TO_DEGREES = 180.0 / math.pi 		-- 弧度转角度
math.DEGREES_TO_DIR = 256.0 / 360.0 			-- 角度转朝向
math.DIR_TO_DEGREES = 360.0 / 256.0 			-- 朝向转角度
math.RADIANS_TO_DIR = 128.0 / math.pi 			-- 弧度转朝向
math.DIR_TO_RADIANS = math.pi / 128.0 			-- 朝向转弧度

-- 角度转弧度
function math.Degrees2Radians(fDegrees) 
	return math.DEGREES_TO_RADIANS * fDegrees
end

-- 弧度转角度
 function math.Radians2Degrees(fRadians)
 	return math.RADIANS_TO_DEGREES * fRadians
end

-- 角度转朝向
function math.Degrees2Dir(fDegrees)
	return math.DEGREES_TO_DIR * fDegrees
end

-- 朝向转角度
function math.Dir2Degrees(nDir)
	return math.DIR_TO_DEGREES * nDir
end

-- 弧度转朝向
function math.Radians2Dir(fRadians)
	return math.RADIANS_TO_DIR * fRadians
end

-- 朝向转弧度
function math.Dir2Radians(nDir)
	return math.DIR_TO_RADIANS * nDir
end


-- 矩形裁剪线段算法实现
function math.ClipSegmentByRectangle(nX1, nY1, nX2, nY2, nXL, nXR, nYB, nYT)
	assert(nXL <= nXR)
	assert(nYB <= nYT) 

	local LEFT = 1
	local TOP = 8
	local RIGHT = 2
	local BOTTOM = 4
	
	local function Encode(x, y)
		local ret = 0
		if x < nXL then
			ret = bit.Or(ret, LEFT)
		elseif x > nXR then
			ret = bit.Or(ret, RIGHT)
		elseif y < nYB then
			ret = bit.Or(ret, BOTTOM)
		elseif y > nYT then
			ret = bit.Or(ret, TOP)
		end
		
		return ret
	end
	
	local function GetIntersectPoint(nCode, nMainX, nMainY, nAssistX, nAssistY)
		local nX, nY = nMainX, nMainY
		
		if nCode == 0 then
			return nX, nY
			
		elseif bit.And(nCode, LEFT) ~= 0 then
			nX = nXL
			nY = nMainY + (nAssistY - nMainY) * (nXL - nMainX) /  (nAssistX - nMainX)
			
		elseif bit.And(nCode, RIGHT) ~= 0 then
			nX = nXR
			nY = nMainY + (nAssistY - nMainY) * (nXR - nMainX) / (nAssistX - nMainX)
			
		elseif bit.And(nCode, TOP) ~= 0 then
			nY = nYT
			nX = nMainX + (nAssistX - nMainX) * (nYT - nMainY) / (nAssistY - nMainY)
			
		elseif bit.And(nCode, BOTTOM) ~= 0 then
			nY = nYB
			nX = nMainX + (nAssistX - nMainX) * (nYB - nMainY) / (nAssistY - nMainY)
		end
		
		return nX, nY
	end
	
	local nCode1 = Encode(nX1, nY1)
	local nCode2 = Encode(nX2, nY2)
	while nCode1 ~= 0 or nCode2 ~= 0 do
		if bit.And(nCode1, nCode2) ~= 0 then
			break
		end
		
		if nCode1 ~= 0 then
			nX1, nY1 = GetIntersectPoint(nCode1, nX1, nY1, nX2, nY2)
			nCode1 = Encode(nX1, nY1)
		end
		
		if nCode2 ~= 0 then
			nX2, nY2 = GetIntersectPoint(nCode2, nX2, nY2, nX1, nY1)
			nCode2 = Encode(nX2, nY2)
		end
	end
	
	return nX1, nY1, nX2, nY2
end

function math.SanYuanExpressions(bCondition, result1, result2)
    if bCondition then
    	if bCondition == 0 then
    		return result2
    	end
    	
        return result1
    else
        return result2
    end
 end

math.randomseed(os.time())