#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: LIST & RECORD PRINTER
# nmxt: .applescript
# pDSC: Pretty prints a text representation of an AppleScript list or record

# plst: +input : A list or record or a valid string representation of such

# rslt: «ctxt» : Pretty-printed string representation of the input
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-20
# asmo: 2019-05-01
# vers: 2.0
--------------------------------------------------------------------------------
# IMPLEMENTATION:
global q, N

on run input
	if the input's class = script or the input = {} then set ¬
		input to [{[1, 2, {a:3, b:4}, "Hello, \"World!\""], ¬
		{c:{alpha:1, beta:"foo{bar}"}, d:"5"}, "6", [7, ¬
		{8, 9}, 0]}, null]
	set [input, null] to the input
	
	set the input to the characters of the __string__(input)
	
	set [q, N] to [false, 0]
	set my text item delimiters to ""
	(mapItems from the input given handler:tabulate) as text
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on __(function)
	if the function's class = script ¬
		then return the function
	
	script
		property fn : function
	end script
end __


to __string__(object)
	local object
	
	if the object's class = text then return the object
	
	try
		{_:object} as text
	on error E --> "Can’t make %object% into type text."
		set text item delimiters to {"Can’t make ", ¬
			" into type text."}
		text item 2 of E
	end try
	
	result's text 4 thru -2
end __string__


to mapItems from L as list given handler:function
	local L, function
	
	script
		property list : L
	end script
	
	tell (a reference to the result's list) to ¬
		repeat with i from 1 to its length
			set x to (a reference to its item i)
			set x's contents to my __(function)'s ¬
				fn(x's contents, i, it)
		end repeat
	
	L
end mapItems

on indent(N)
	local N
	
	if N = 0 then return ""
	tab & indent(N - 1)
end indent

to tabulate(y, i, L)
	global q, N
	
	if i > 1 then set x to item (i - 1) of L
	if i < L's length then set z to item (i + 1) of L
	
	if y = quote and i ≠ 1 and x ≠ "\\" then
		set q to not q
		return y
	end if
	if q then return y
	if y is in "{[" then
		set N to N + 1
		return [y, return, indent(N)]
	end if
	if y = space and x = "," then return [y, return, indent(N)]
	if y is in "}]" then
		set N to N - 1
		return [return, indent(N), y]
	end if
	if y = ":" then return [y, space]
	return y
end tabulate
---------------------------------------------------------------------------❮END❯