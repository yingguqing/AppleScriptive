#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Get Handler From Script File.applescript
#
#	Given an AppleScript file (text) containing a handler definitions,
#	the script will retrieve a list of handlers by name and present a list
#	from which the user can select.  The chosen handler is then read for
#	text content, copied to the clipboard, and pasted into Script Editor
#	(if running).
#
#  Input:
#	％fp％				The .AppleScript filepath
#
#  Result:
#	⟨Text⟩				Handler source code copied to clipboard
#					and pasted into Script Editor
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-08-08
#  Date Last Edited: 2018-08-08
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run {fp}
	tell application "System Events" to set fp to POSIX path of file fp
	
	set OK to ["Copy", "Paste"]
	set value to ((application "Script Editor" is running) as integer) + 1
	
	choose from list sort(getHandlers from fp) ¬
		with title fp with prompt ("Select a handler:") ¬
		OK button name OK's item value cancel button name ("Close") ¬
		multiple selections allowed false ¬
		without empty selection allowed
	
	set [H] to (the result & {})
	if H = false then return
	
	set the clipboard to getHandler(fp, H) as «class ut16»
	
	if value = 1 then return -- Script Editor not running
	tell application "Script Editor" to tell the front document ¬
		to set the contents of ¬
		the selection to ¬
		the clipboard as «class ut16»
end run
--------------------------------------------------------------------------------
###SCRIPT FILE HANDLERS
#
#
to getHandler(input, H)
	local input, H
	
	if H is not in (getHandlers from input) then return ""
	
	script scriptfile
		property f : POSIX file input
		property L : paragraphs of (read f as «class ut16»)
		property M : {}
	end script
	
	
	tell scriptfile to repeat with i from 1 to length of its L
		set x to item i of its L
		
		if x's words is not {} and ¬
			x's first word is in ["on", "to"] and ¬
			x's second word is H then exit repeat
	end repeat
	
	tell scriptfile to repeat with j from i to length of its L
		set x to item j of its L
		set end of its M to trimL(x)
		
		if x's words is not {} and ¬
			x's first word is "end" and ¬
			x's second word is H then exit repeat
	end repeat
	
	set the text item delimiters to linefeed
	scriptfile's M as text
end getHandler

to getHandlers from input
	local input
	
	script scriptfile
		property f : POSIX file input
		property L : paragraphs of (read f as «class ut16»)
		property M : {}
		property prep : {"about", "above", "against", "apart from", ¬
			"around", "as", "aside from", "at", "below", ¬
			"beneath", "beside", "between", "by", "for", "from", ¬
			"given", "in", "instead of", "into", "of", "on", ¬
			"onto", "out of", "over", "since", "to", "thru", ¬
			"through", "under"}
		property types : {"list", "integer", "number", "string", ¬
			"text", "boolean", "null", "missing value"}
		property exclusions : {"run", "error", "idle", "quit"}
	end script
	
	
	ignoring white space
		tell scriptfile to repeat with i from 2 to length of its L
			set x to item i of its L
			set y to item (i - 1) of its L
			
			if y does not end with "¬" and ¬
				(x starts with "on" or x starts with "to") and ¬
				x's first word is in ["on", "to"] then
				
				set hname to x's second word
				# set the text item delimiters to fname
				# set [params] to rest of x's text items
				
				if hname is not in its exclusions then ¬
					set end of its M to hname
			end if
		end repeat
	end ignoring
	
	scriptfile's M
end getHandlers
--------------------------------------------------------------------------------
###LIST HANDLERS
#
#
to sort(L as list)
	local L
	
	if L = {} then return {}
	if L's length = 1 then return L
	
	script Array
		property min : minimum(L)
		property i : lastIndexOf(min, L)
		property x0 : a reference to L's first item
		property xN : a reference to rest of L
	end script
	
	tell the Array
		if its i ≠ 1 then swap(L, 1, its i)
		return [contents of its x0] & sort(contents of its xN)
	end tell
end sort

on minimum(L as list)
	local L
	
	if L is {} then return {}
	if L's length = 1 then return L's first item
	
	script
		property Array : L
	end script
	
	tell the result
		set [x0, xN] to [first item, rest] of its Array
		set min to minimum(xN)
		if x0 < min then return x0
		min
	end tell
end minimum

on lastIndexOf(x, L as list)
	local x, L
	
	if x is not in L then return 0
	if L = {} then return 0
	
	script
		property Array : L
	end script
	
	tell the result
		set [x0, xN] to [¬
			last item, ¬
			reverse of rest of reverse] of its Array
	end tell
	
	if x = x0 then return 1 + (xN's length)
	lastIndexOf(x, xN)
end lastIndexOf

to swap(L as list, i as integer, j as integer)
	local i, j, L
	
	set x to item i of L
	set item i of L to item j of L
	set item j of L to x
end swap
--------------------------------------------------------------------------------
###TEXT HANDLERS
#
#
to trimL(s)
	local s
	
	if class of s is not list then set s to (id of s) as list
	if s = {} then return ""
	
	script
		property str : s
		property fn : trimL
	end script
	
	tell the result
		set [x0, xN] to [first item, rest] of its str
		if x0 is not in [32, 9] then return character id s
		its fn(xN)
	end tell
end trimL