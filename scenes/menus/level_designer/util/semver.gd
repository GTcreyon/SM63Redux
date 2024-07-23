class_name SemVer
## A Semantic Versioning version number with major, minor, and patch version.

enum Ordering {
	LESSER = -1,
	EQUAL = 0,
	GREATER = 1
}

var major: int = 0
var minor: int = 0
var patch: int = 0


func _init(maj: int, min: int, pat: int):
	major = maj
	minor = min
	patch = pat


func _to_string():
	return "%s.%s.%s" % [major, minor, patch]


## Parses a Semantic Version from a string. 
static func from_string(string: String) -> SemVer:
	var nums: Array = string.split(".")
	for i in len(nums):
		nums[i] = nums[i].to_int()
	
	var major = 0 if len(nums) < 1 else nums[0]
	var minor = 0 if len(nums) < 2 else nums[1]
	var patch = 0 if len(nums) < 3 else nums[2]
	
	return SemVer.new(major, minor, patch)


## Returns version number 0.0.0.
static func zero() -> SemVer:
	return SemVer.new(0,0,0)


## Compares this SemVer against another. Returns how this SemVer is ordered
## relative to the other.
func compare(other: SemVer) -> Ordering:
	# Start by comparing major versions.
	if self.major < other.major:
		return Ordering.LESSER
	elif self.major > other.major:
		return Ordering.GREATER
	
	# Major versions are equal. Compare minor versions.
	if self.minor < other.minor:
		return Ordering.LESSER
	elif self.minor > other.minor:
		return Ordering.GREATER

	# Major and minor versions are equal. Compare patch release.
	if self.patch < other.patch:
		return Ordering.LESSER
	elif self.patch > other.patch:
		return Ordering.GREATER
	
	# All versions are equal.
	return Ordering.EQUAL


## Returns whether this SemVer is exactly equal to another.
func equals(other: SemVer) -> bool:
	return compare(other) == Ordering.EQUAL


## Returns whether this SemVer is greater than another.
func greater_than(other: SemVer) -> bool:
	return compare(other) == Ordering.GREATER


## Returns whether this SemVer is less than another.
func less_than(other: SemVer) -> bool:
	return compare(other) == Ordering.LESSER


## Returns whether this SemVer is greater than or equal to another.
func greater_or_equal(other: SemVer) -> bool:
	return compare(other) != Ordering.LESSER


## Returns whether this SemVer is less than or equal to another.
func less_or_equal(other: SemVer) -> bool:
	return compare(other) != Ordering.GREATER


## Returns whether this SemVer is not equal to another.
func not_equals(other: SemVer) -> bool:
	return compare(other) != Ordering.EQUAL
