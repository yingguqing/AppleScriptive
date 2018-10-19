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
#  Date Last Edited: 2018-10-09
--------------------------------------------------------------------------------
property noQuit : {¬
	"Alfred 3", ¬
	"Finder", ¬
	"Keyboard Maestro Engine", ¬
	"Little Snitch Agent", ¬
	"Resilio Sync", ¬
	"Typinator", ¬
	"Battery Monitor", ¬
	"ManyCam", ¬
	"FastScripts"}
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run
	tell application "System Events" to set runningApps to ¬
		the bundle identifier of application processes where ¬
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
to kill(Apps as list, X as list)
	local Apps, X
	
	if Apps = {} then return
	
	script
		property list : Apps
	end script
	
	tell the result's list to set [A, A_] to its [item 1, rest]
	try
		if A is not in X then quit the application id A
	on error E
		display notification E ¬
			with title my name ¬
			subtitle name of application id A
	end try
	
	kill(An, X)
end kill
---------------------------------------------------------------------------❮END❯