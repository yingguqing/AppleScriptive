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
#	％input％		Either a single value or pair of values: the
#				first is always a filepath to the .applescript
#				file; if it's the only parameter, the script
#				progresses normally.  If the second parameter is
#				⟨missing value⟩, then the list of handlers is
#				returned as text, one per line.  Finally, a
#				string value for the second parameter will be
#				the name of the handler to fetch.
#
#  Result:
#	⟨Text⟩			Handler source code copied to clipboard and
#				pasted into Script Editor (if running)
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-08-08
#  Date Last Edited: 2018-08-16
--------------------------------------------------------------------------------
property text item delimiters : {linefeed, "/"}
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run input
	set [fp, H] to the input & {null}
	if fp's class = script then set fp to (path to fp)'s POSIX path
	
	set hList to sort(getHandlersByName from fp)
	
	if H = missing value then return hList as text
	
	set OK to ["Copy", "Paste"]
	set value to ((application "Script Editor" is running) as integer) + 1
	
	if H = null then set H to ¬
		(choose from list hList ¬
			with title fp's last text item ¬
			with prompt ("Select a handler:") ¬
			OK button name OK's item value ¬
			cancel button name ("Close") ¬
			multiple selections allowed true ¬
			without empty selection allowed)
	
	if H = false then return
	
	getHandlersByName from fp given names:H
	set the clipboard to the result
	
	if value = 1 then return -- Script Editor not running
	tell application "Script Editor" to tell the front document ¬
		to set the contents of the selection to ¬
		the clipboard as «class ut16»
end run
--------------------------------------------------------------------------------
###SCRIPT FILE HANDLERS
#
#
to getHandlersByName from input given names:H as list : null
	local input, H
	
	if H is in [{null}, {missing value}, {""}] then set H to null
	
	script scriptfile
		property f : POSIX file input
		property L : paragraphs of (read f as «class ut16»)
		property M : {}
		property i : 2
		property prep : {"about", "above", "against", "apart from", ¬
			"around", "as", "aside from", "at", "below", ¬
			"beneath", "beside", "between", "by", "for", "from", ¬
			"given", "in", "instead of", "into", "of", "on", ¬
			"onto", "out of", "over", "since", "to", "thru", ¬
			"through", "under"}
		property types : {"list", "integer", "number", "string", ¬
			"text", "boolean", "null", "missing value"}
		property exclusions : {null, "run", "error", "idle", "quit"}
		
		to getHandler(hname as text)
			repeat with j from i to L's length
				set s to trimL(item j of L)
				set end of M to s
				
				try
					false is not in [¬
						s starts with "end ", ¬
						word 2 of s = hname]
				on error
					false
				end try
				if the result = true then exit repeat
			end repeat
			
			set end of M to linefeed
			
			set i to j
		end getHandler
	end script
	
	
	tell scriptfile to repeat until its i > its L's length
		set i to its i
		
		set hname to null
		
		set p to trimL(item i of its L) -- current line
		set q to trimL(item (i - 1) of its L) -- previous line
		
		try
			false is not in [¬
				q = "" or q's last character ≠ "¬" or ¬
				q's first character is in ["#", "-"], ¬
				p's first word is in ["on", "to"]]
		on error
			false
		end try
		
		if the result = true then set hname to p's second word
		
		if H = null then
			if hname is not in its exclusions then ¬
				set end of its M to hname
		else
			if hname is in H then getHandler(hname)
		end if
		
		set its i to i + 1
	end repeat
	
	if H = null then return scriptfile's M
	scriptfile's M as text
end getHandlersByName
--------------------------------------------------------------------------------
###LIST HANDLERS
#
#
on minimum(L as list)
	local L
	
	if L is {} then return {}
	if L's length = 1 then return L's first item
	
	script
		property Array : L
	end script
	
	tell the result's Array to set [x0, xN] to [¬
		(its first item), the rest of it]
	
	tell minimum(xN) to if it < x0 then return it
	return x0
end minimum

on lastIndexOf(x, L)
	local x, L
	
	if L = {} or (x is not in L) then return 0
	if L's class = text then set L to L's characters
	
	script
		property Array : reverse of L
	end script
	
	tell the result's Array to repeat with i from 1 to its length
		if x = its item i then return 1 + (its length) - i
	end repeat
	
	0
end lastIndexOf

to swap(L as list, i as integer, j as integer)
	local i, j, L
	
	if i = j then return
	
	set x to item i of L
	set item i of L to item j of L
	set item j of L to x
end swap

to sort(L as list)
	local L
	
	if L = {} then return {}
	if L's length = 1 then return L
	
	script
		property Array : L
	end script
	
	tell the result's Array
		set [x0, xN, i] to [¬
			a reference to its first item, ¬
			a reference to the rest of it, ¬
			(my lastIndexOf(my minimum(it), it))]
		my swap(it, 1, i)
	end tell
	
	{x0's contents} & sort(xN's contents)
end sort
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
	end script
	
	tell the result
		set [x0, xN] to [first item, rest] of its str
		if x0 is not in [32, 9] then return character id (its str)
	end tell
	
	trimL(xN)
end trimL
---------------------------------------------------------------------------❮END❯