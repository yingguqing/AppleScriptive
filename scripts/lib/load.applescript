#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: LOAD
# nmxt: .applescript
# comt: This is the text version of load.scpt for the purposes of online viewing
# pDSC: Enables loading of non-compiled AppleScripts from a custom location.
#       Also provides top-level handlers and properties to scripts invoking 
#       this as its parent.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-07
# asmo: 2019-05-07
--------------------------------------------------------------------------------
property name : "load"
property id : "chri.sk.applescript#load"
property version : 1.5
property parent : AppleScript
--------------------------------------------------------------------------------
property rootdir : "~/Scripts/AppleScript/scripts/"
property library : "~/Scripts/AppleScript/Script Libraries/"
property ASFileTypes : ["applescript", "scpt", "js", "jxa"]
--------------------------------------------------------------------------------
property sys : application "System Events"
property Finder : application "Finder"
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
# resolve()
#   Recursively resolves alias files and symlinks and returns the posix path
#   to the original file or folder
to resolve(fp as text)
	local fp
	
	tell Finder's item (sys's alias fp as alias)
		if its class ≠ «class alia» then return ¬
			the POSIX path of (it as alias)
		my resolve(its «class orig»)
	end tell
end resolve

# load script [ syn. load() ]
#   Allows loading of a script file in text (.applescript) format, providing
#   access to its handlers and properties to the invoking script 
to load script s as text
	local s
	
	script
		property fp : path to s
		property tmp : "/tmp/load.scpt"
		
		to load()
			if fp = missing value then return AppleScript
			if fp ends with ".scpt" then return fp
			
			do shell script {"osacompile", "-o", ¬
				tmp, the quoted form of fp}
			
			return tmp
			# delete sys's file tmp
		end load
	end script
	
	tell result's load()
		if it = AppleScript then return it
		continue load script it
	end tell
end load script
to load(s)
	load script s
end load

# path to
#   Adds functionality to the builtin to accept HFS file paths or alias objects
#   and return a posix path.  Specifying a filename only will trigger a search
#   for AppleScript files located in rootdir.
on path to thing from domain : user domain
	local thing, domain
	
	try
		continue path to thing from domain
		return the result's POSIX path
	end try
	
	set thing to thing as text
	set fp to a reference to sys's alias named thing
	if fp exists then return resolve(fp's path)'s POSIX path
	
	set my text item delimiters to "."
	if thing's last text item is not in ASFileTypes then ¬
		set thing to [thing, ".applescript"] as text
	
	set fp to recurse thru rootdir for the thing
	if fp ≠ false then return resolve(fp)
	set fp to recurse thru library for the thing
	if fp ≠ false then return resolve(fp)
	
	missing value
end path to

# do shell script
#   Instantiates a shell process and runs the command specified by the parameter
#   +sh, which can be a string or a list of strings that the handler will join
#   together using a space delimiter
to do shell script sh
	local sh
	
	set [tids, text item delimiters] to [text item delimiters, space]
	set sh to sh as text
	set text item delimiters to tids
	
	continue do shell script sh
end do shell script

# APPLESCRIPT-OBJC HANDLERS:
use framework "Foundation"

property this : a reference to the current application
property nil : a reference to missing value
property _1 : a reference to reference

property NSFileManager : a reference to NSFileManager of this
property NSMutableSet : a reference to NSMutableSet of this
property NSSet : a reference to NSSet of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this

property FileManager : a reference to NSFileManager's defaultManager

property path : "path"
property lcaseLPC : "lastPathComponent.lowercaseString"
property resolveSymlinks : "stringByResolvingSymlinksInPath"

# recurse
#   Performs a deep enumeration of the specified +directory, resolving symlinks
#   and enumerating those until a file named +name is found, returning its full
#   path or 'false' in its absence
to recurse thru directory as text for name as text
	local directory, name
	
	set name to (NSString's stringWithString:name)'s lowercaseString()
	
	-- Options: 6 => Skip hidden files & package descendants
	tell ((FileManager()'s enumeratorAtURL:(NSURL's ¬
		fileURLWithPath:((NSString's ¬
			stringWithString:directory)'s ¬
			stringByStandardizingPath())) ¬
		includingPropertiesForKeys:[] options:6 ¬
		errorHandler:nil)'s allObjects()'s ¬
		valueForKey:path)
		
		set i to valueForKeyPath_(lcaseLPC)'s indexOfObject:name
		if i < |count|() then return objectAtIndex_(i) as text
		it
	end tell
	set A to the NSSet's setWithArray:result
	set B to A's valueForKey:resolveSymlinks
	tell (NSMutableSet's setWithSet:B)
		its minusSet:A
		
		repeat with dir in allObjects() as list
			tell my (recurse thru dir for name) ¬
				to if false ≠ it then return it
		end repeat
	end tell
	
	false
end recurse
---------------------------------------------------------------------------❮END❯