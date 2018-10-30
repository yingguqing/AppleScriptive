#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: LISTS
# nmxt: .applescript
# pDSC: List manipulation handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-23
# asmo: 2018-10-30
--------------------------------------------------------------------------------
property name : "_array"
property id : "chrisk.applescript._array"
property version : 1.0
property _array : me
property parent : AppleScript
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

set L to make 100
set R to {}
filterItems from L into R given handler:even

on even(x)
	x mod 2 = 0
end even

to make N
	script
		property list : {}
	end script
	
	tell the result
		repeat with i from 1 to N
			set end of its list to i
		end repeat
		
		its list
	end tell
end make

to iterate over L
	local L
	
	script
		property array : L
		
		on nextItem()
			if done() then return
			set [x, array] to [item 1, rest] of array
			
			x
		end nextItem
		
		on done()
			array = {}
		end done
	end script
end iterate


to flatten(L)
	local L
	
	if L = {} then return {}
	if L's class ≠ list then return {L}
	
	script
		property list : L
	end script
	
	tell the result to set [x, x_] to ¬
		[item 1, rest] of its list
	
	flatten(x) & flatten(x_)
end flatten


to mapItems from L as list onto R as list : null ¬
	given handler:function
	local L, R
	
	if R = null then set R to {}
	
	script
		property list : L
		property result : R
	end script
	
	tell the result to repeat with x in (a reference to its list)
		tell wrapper(function) to set y to fn(x's contents)
		set end of its result to y
		set x's contents to y
	end repeat
	
	R
end mapItems


to filterItems from L as list into R as list : null ¬
	given handler:function
	local L, R
	
	if R = null then set R to {}
	
	script
		property list : L
		property result : R
	end script
	
	tell the result to repeat with x in its list
		tell wrapper(function) to set y to fn(x's contents)
		if y then set end of its result to x's contents
	end repeat
	
	R
end filterItems


to putItems into L as list at i as integer : 0 given list:x_ as list : {}
	local L, i, x_
	
	script
		property list : L
		property y : x_
		property N : L's length
		property index : (i + N + 1) mod (N + 1)
	end script
	
	tell the result
		set i to its index
		if i = 0 then set i to (its N) + 1
		repeat with x in its y
			if i ≤ its N then
				set its list's item i to x's contents
			else
				set end of its list to x's contents
			end if
			
			set i to i + 1
		end repeat
	end tell
	
	L
end putItems


to pushItems onto L as list at i as integer : 0 given list:x_ as list : {}
	local L, i, x_
	
	script
		property list : L
		property y : x_
		property N : L's length
		property index : (i + N + 1) mod (N + 1)
	end script
	
	tell the result
		set i to its index
		if i = 0 then
			set its list to its list & its y
		else if i = 1 then
			set its list to its y & its list
		else
			set its list to ¬
				(its list's items 1 thru (i - 1)) & ¬
				(its y) & ¬
				(its list's items i thru -1)
			
			its list
		end if
	end tell
end pushItems


on wrapper(function)
	if the function's class = script ¬
		then return the function
	
	script
		property fn : function
	end script
end wrapper
---------------------------------------------------------------------------❮END❯