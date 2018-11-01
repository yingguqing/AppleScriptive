#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _TEXT
# nmxt: .applescript
# pDSC: String manipulation handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2018-10-31
--------------------------------------------------------------------------------
property name : "_text"
property id : "chrisk.applescript._text"
property version : 1.0
property _text : me
#property parent : script "load.scpt"
#property _array : load script "_array"
--------------------------------------------------------------------------------
property tid : AppleScript's text item delimiters
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on tid:(d as list)
	local d
	
	if d = {} or d = {0} then
		set d to tid
	else if d's item 1 = null then
		set N to random number from 0.0 to 1.0
		set d's first item to (1 / pi) * N
	end if
	
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to d
end tid:


to join(t as list, d as list)
	tid_(d)
	set t to t as text
	tid_(0)
	t
end join


on split(t as text, d as list)
	tid_(d)
	set t to text items of t
	tid_(0)
	t
end split


on offset of txt in str -- ALL occurrences of substring
	local txt, str
	
	if txt is not in str then return {}
	
	tid_(txt)
	
	script
		property N : txt's length
		property t : {1 - N} & str's text items
	end script
	
	tell the result
		repeat with i from 2 to (its t's length) - 1
			set item i of its t to (its N) + ¬
				(length of its t's item i) + ¬
				(its t's item (i - 1))
		end repeat
		
		tid_(0)
		
		items 2 thru -2 of its t
	end tell
end offset
---------------------------------------------------------------------------❮END❯