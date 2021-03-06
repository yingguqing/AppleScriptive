#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: HOSTNAMES
# nmxt: .applescript
# pDSC: Lists hostnames of available devices found on the local network

# plst: -

# rslt: «list» : List of hostname/IPv4 address pairs
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-06
# asmo: 2019-06-01
--------------------------------------------------------------------------------
property text item delimiters : "."
property IPv4 address : a reference to the IPv4 address of (system info)
--------------------------------------------------------------------------------
# IMPLEMENTATION:
repeat with host in (a reference to the lan's hosts)
	set addr to the lan's subnet & the host as text
	try
		with timeout of 2 seconds
			[hostname of lan at addr, addr]
		end timeout
	on error
		missing value
	end try
	set the host's contents to the result
end repeat

return lists of the lan's hosts
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on array from i as integer : 1 to j as integer
	local N
	
	tell {}
		repeat with k from i to j by ((j > i) as integer) * 2 - 1
			set its end to k
		end repeat
		
		it
	end tell
end array

script lan
	use framework "Foundation"
	use scripting additions
	------------------------------------------------------------------------
	property subnet : text items 1 thru 3 of IPv4 address
	property hosts : array to 254
	------------------------------------------------------------------------
	on hostname at address
		tell (current application's NSHost's ¬
			hostWithAddress:address)'s ¬
			|name|() to if it ≠ missing value ¬
			then return it as text
	end hostname
end script
---------------------------------------------------------------------------❮END❯