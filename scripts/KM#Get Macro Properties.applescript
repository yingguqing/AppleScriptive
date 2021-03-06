#!/usr/bin/osascript
--------------------------------------------------------------------------------
###[KM] Get Macro Properties.applescript
#
#	Retrieves an AppleScript record containing properties of all existing
#	Keyboard Maestro macros.  A record for a specific macro can be sought
#	given a name or UID of the macro and the name of the macro group in 
#	which it resides.
#
#  Input:
#	％macro_group_name％		The name of the KM macro group
#	％macro_name_or_uid％		The name or UID of the KM macro
#
#  Result:
#	❮record❯			The property record for the macro
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-08-01
#  Date Last Edited: 2018-09-05
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run {macro_group as text, macro_name_or_uid as text}
	getKMMacro of macro_group by macro_name_or_uid
	
	# e.g.:
	# if the result ≠ false then AppleTimeToASDate(the result's lastused)
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
to getKMMacro of macro_group_name by macro_name_or_uid
	local macro_group_name, macro_name_or_uid
	
	script macros
		to getAllMacros()
			tell application "Keyboard Maestro Engine" to ¬
				set macrosXML to getmacros with asstring
			
			tell application "System Events" to ¬
				return the value of (make new ¬
					property list item with properties ¬
					{name:"KMmacros", text:macrosXML})
		end getAllMacros
		
		to searchMacros(L, group, |name/uid|)
			local L, group, |name/uid|
			
			if L = {} then return false
			
			script FindMacro
				property R : item 1 of L
				property Ln : rest of L
				property m : text in [group, |name/uid|]
				property |?n| : R's |name| = item 1 of m
				property |?u| : R's UID = item 1 of m
			end script
			
			tell FindMacro
				if (its |?n| or its |?u|) = true then
					if the rest of its m = {} then ¬
						return its R
					set [L] to its R's lists
					searchMacros(L, null, |name/uid|)
				else
					searchMacros(its Ln, group, |name/uid|)
				end if
			end tell
		end searchMacros
	end script
	
	tell macros to ¬
		searchMacros(getAllMacros() ¬
			, macro_group_name ¬
			, macro_name_or_uid)
end getKMMacro


on AppleTimeToASDate(t as number)
	local t
	
	tell (the current date) to set ¬
		[ASdate, year, its month, day, time] to ¬
		[it, 2001, January, 1, 0]
	
	ASdate + t
end AppleTimeToASDate
---------------------------------------------------------------------------❮END❯