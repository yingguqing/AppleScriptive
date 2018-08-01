#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Get KM Macro Properties.applescript
#
#	Retrieves an AppleScript record containing properties of all existing
#	Keyboard Maestro macros.  A record for a specific macro can be sought
#	given a name of the macro and the name of the macro group in which it
#	resides.  From this, the date the macro was last used is retrieved, and
#	converted from Apple's Cocoa time to an AppleScript date object.
#
#  Input:
#	None				-
#
#  Result:
#	％date％				When the specified macro was last used
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-08-01
#  Date Last Edited: 2018-08-01
--------------------------------------------------------------------------------
tell application "Keyboard Maestro Engine" to set macrosxml to ¬
	getmacros with asstring

tell application "System Events" to set kmmacros to the value of ¬
	(make new property list item with properties ¬
		{name:"kmmacros", text:macrosxml})

getMacroRecord from kmmacros given group:"Global Macro Group", macro:"Empty Trash"
if the result ≠ false then AppleTimeToASDate(the result's lastused)
--------------------------------------------------------------------------------
###HANDLERS
#
#
on AppleTimeToASDate(t as number)
	local t
	
	tell (the current date) to set ¬
		[ASdate, year, its month, day, time] to ¬
		[it, 2001, January, 1, 0]
	
	ASdate + (t / 60) * minutes
end AppleTimeToASDate


to getMacroRecord from L as list ¬
	given group:macro_group_name : null, macro:macro_name : null
	local L, macro_group_name, macro_name
	
	if L is {} then return false
	
	script Array
		property R : L's item 1
		property Ln : rest of L
		property m : text in [macro_group_name, macro_name]
		property this : R's |name| = m's item 1
	end script
	
	tell the Array
		if its this = true then
			if the rest of its m = {} then return its R
			set [L] to its R's lists
			getMacroRecord from L given macro:macro_name
		else
			getMacroRecord from its Ln ¬
				given group:macro_group_name ¬
				, macro:macro_name
		end if
	end tell
end getMacroRecord
---------------------------------------------------------------------------❮END❯