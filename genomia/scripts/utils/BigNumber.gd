class_name BigNumber
extends RefCounted

var mantissa: float = 0.0
var exp: int = 0

static func zero() -> BigNumber:
	return BigNumber.new()

static func from_float(v: float) -> BigNumber:
	var bn := BigNumber.new()
	if v <= 0.0:
		return bn
	bn.exp = int(floor(log(v) / log(10.0)))
	bn.mantissa = v / pow(10.0, float(bn.exp))
	return bn

static func from_values(m: float, e: int) -> BigNumber:
	var bn := BigNumber.new()
	bn.mantissa = m
	bn.exp = e
	bn._normalize()
	return bn

func _normalize() -> void:
	if mantissa == 0.0:
		exp = 0
		return
	while abs(mantissa) >= 10.0:
		mantissa /= 10.0
		exp += 1
	while abs(mantissa) > 0.0 and abs(mantissa) < 1.0:
		mantissa *= 10.0
		exp -= 1

func add(other: BigNumber) -> BigNumber:
	if mantissa == 0.0:
		return other.copy()
	if other.mantissa == 0.0:
		return copy()
	var diff := exp - other.exp
	if diff > 15:
		return copy()
	if diff < -15:
		return other.copy()
	var result := BigNumber.new()
	if diff >= 0:
		result.mantissa = mantissa + other.mantissa * pow(10.0, float(-diff))
		result.exp = exp
	else:
		result.mantissa = mantissa * pow(10.0, float(diff)) + other.mantissa
		result.exp = other.exp
	result._normalize()
	return result

func subtract(other: BigNumber) -> BigNumber:
	if other.mantissa == 0.0:
		return copy()
	var diff := exp - other.exp
	if diff > 15:
		return copy()
	if diff < 0:
		return BigNumber.zero()
	var result := BigNumber.new()
	result.mantissa = mantissa - other.mantissa * pow(10.0, float(-diff))
	result.exp = exp
	if result.mantissa < 0.0:
		return BigNumber.zero()
	result._normalize()
	return result

func multiply_float(factor: float) -> BigNumber:
	if factor == 0.0 or mantissa == 0.0:
		return BigNumber.zero()
	return BigNumber.from_values(mantissa * factor, exp)

func greater_than(other: BigNumber) -> bool:
	if exp != other.exp:
		return exp > other.exp
	return mantissa > other.mantissa

func greater_than_or_equal(other: BigNumber) -> bool:
	if exp != other.exp:
		return exp > other.exp
	return mantissa >= other.mantissa

func copy() -> BigNumber:
	return BigNumber.from_values(mantissa, exp)

func to_float() -> float:
	return mantissa * pow(10.0, float(exp))

func format() -> String:
	const SUFFIXES := ["", "K", "M", "B", "T", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "aj"]
	if exp < 3:
		var v := to_float()
		if v < 10.0:
			return "%.1f" % v
		return str(int(v))
	var tier := exp / 3
	if tier >= SUFFIXES.size():
		return "%.2fe%d" % [mantissa, exp]
	var display_val := mantissa * pow(10.0, float(exp - tier * 3))
	if display_val >= 100.0:
		return "%d%s" % [int(display_val), SUFFIXES[tier]]
	if display_val >= 10.0:
		return "%.1f%s" % [display_val, SUFFIXES[tier]]
	return "%.2f%s" % [display_val, SUFFIXES[tier]]

func to_dict() -> Dictionary:
	return {"m": mantissa, "e": exp}

static func from_dict(d: Dictionary) -> BigNumber:
	return BigNumber.from_values(d.get("m", 0.0), d.get("e", 0))
