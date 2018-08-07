#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Quit All Apps.applescript
#
#	Quits any running applications except those in a predefined "No Quit"
#	exceptions list.
#
#  Input:
#	None				-
#
#  Result:
#	-				Applications will quit
#	Notification			App-specific error message
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-02-26
#  Date Last Edited: 2018-08-07
--------------------------------------------------------------------------------
use application "System Events"
use scripting additions
--------------------------------------------------------------------------------
property noQuit : {¬
	"Finder", ¬
	"Keyboard Maestro Engine", ¬
	"Little Snitch Agent", ¬
	"Resilio Sync", ¬
	"Typinator", ¬
	"Memory Cleaner", ¬
	"Battery Monitor", ¬
	"ManyCam", ¬
	"Air Display Host", ¬
	"FastScripts"}
--------------------------------------------------------------------------------
on run
	set runningApps to the name of every application process where ¬
		the class of its menu bar contains menu bar and ¬
		the POSIX path of the application file ¬
			does not start with "/System" and ¬
		the POSIX path of the application file ¬
			does not start with "/Library"
	
	kill(runningApps, noQuit)
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
to kill(A as list, X as list)
	local A, X
	
	if A = {} then return
	
	script
		property Apps : A
	end script
	
	tell the result
		set [A0, An] to [first item, rest] of its Apps
		try
			if A0 is not in X then ¬
				quit the application named (A0)
		on error E
			display notification E ¬
				with title my name ¬
				subtitle A0
		end try
		
		kill(An, X)
	end tell
end kill
---------------------------------------------------------------------------❮END❯