#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: FINDER#NEW TEXT FILE
# nmxt: .applescript
# pDSC: Creates a new, blank text file at the current insertion location in
#       Finder.  If an "Untitled Text Document.txt" already exists at that
#       location, an incrementing index number is appended to the filename. 

# plst: -

# rslt: «psxp» : The posix path to the newly created text document
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-22
# asmo: 2019-05-20
--------------------------------------------------------------------------------
property Finder : application "Finder"
use scripting additions
--------------------------------------------------------------------------------
property name : "Untitled Text Document"
property file type : "txt"
property id : missing value
property file name : a reference to [name, my id, ".", file type]
property folder : a reference to Finder's «class pins»
--------------------------------------------------------------------------------
# IMPLEMENTATION:
Finder's (make new file at (my folder as alias) ¬
	with properties {name:choose file name})
return the POSIX path of (the result as text)
--------------------------------------------------------------------------------
# HANDLERS:
to choose file name
	script
		on fn(i)
			local i
			
			set my id to [space, i] as text
			if 1 ≥ i then set my id to ""
			
			script TextDocument
				property name : contents of file name as text
				property path : [folder as text, name]
			end script
			
			try
				alias (TextDocument's path as text)
				return fn(i + 1)
			on error
				return the TextDocument's name
			end try
		end fn
	end script
	
	result's fn(0)
end choose file name
---------------------------------------------------------------------------❮END❯