local VectorUtils = {}
VectorUtils.__index = VectorUtils

function VectorUtils.multiply(vector1, vector2)
	assert((typeof(vector1) == "Vector3" and typeof(vector2) == "Vector3"), "Passed value not a vectpr3!!")

	return Vector3.new(vector1.x * vector2.x, vector1.y * vector2.y, vector1.z * vector2.z)
end

return VectorUtils
