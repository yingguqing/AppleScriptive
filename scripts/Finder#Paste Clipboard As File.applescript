#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: FINDER#PASTE CLIPBOARD AS FILE
# nmxt: .applescript
# pDSC: Pastes the contents of the clipboard as a new file in Finder.  The
#       compatible data types are image data (JPG, PNG) and plain text.

# plst: -

# rslt: - : File pasted and revealed in Finder
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-04-17
# asmo: 2018-12-06
--------------------------------------------------------------------------------
property filename : "Pasted from clipboard on {timestamp}.{ext}"
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run
	-- Process clipboard data
	set [cbData, cbType, ext] to the clipboard
	if cbData = null then return beep
	if cbData's class = alias then set [cbData, cbType, ext] to read cbData
	
	-- Filename
	replace(a reference to filename, "{timestamp}", current date)
	replace(a reference to filename, "{ext}", ext)
	
	-- Create the file
	-- Write the data to it
	tell application "Finder"
		set f to (make new file at insertion location as alias ¬
			with properties {name:filename}) as alias
		
		write cbData to f as cbType
		reveal f -- OR: set selection to f
	end tell
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on the clipboard
	set cbObj to continue the clipboard as record
	try
		set cbData to cbObj's «class furl» as alias
		set [ext, cbType] to [null, null]
	on error
		try
			set cbData to cbObj's string
			set [ext, cbType] to ["txt", «class utf8»]
		on error
			try
				set cbData to cbObj's JPEG picture
				set [ext, cbType] to ["jpg", JPEG picture]
			on error
				return [null, null, null]
			end try
		end try
	end try
	
	return [cbData, cbType, ext]
end the clipboard

to replace(s, t1, t2)
	set my text item delimiters to {t2, t1}
	set contents of s to text items of s as text
end replace

on current date
	set ts to (continue current date) as «class isot» as string
	set my text item delimiters to {" at ", "T"}
	set ts to text items of (ts) as text
	set my text item delimiters to {".", ":"}
	set ts to text items of ts as text
	
	return text 1 thru -4 of ts
end current date

to read f
	tell (info for f) to if its kind = "JPEG image" then
		set [ext, cbType] to ["jpg", JPEG picture]
	else if its kind = "PNG image" then
		set [ext, cbType] to ["png", «class PNGf»]
	else if its kind contains "text" then
		set [ext, cbtye] to ["txt", «class utf8»]
	end if
	
	try
		set cbData to continue read f as cbType
	on error
		set cbType to «class ut16»
		set cbData to continue read f as cbType
	end try
	
	return [cbData, cbType, ext]
end read
---------------------------------------------------------------------------❮END❯