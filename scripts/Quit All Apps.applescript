#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: QUIT ALL APPS
# nmxt: .applescript
# pDSC: Quits all running applications except those in a predefined "No Quit"
#       exceptions list

# plst: -

# rslt: -          : Applications terminate
#       «sysonotf» : App-specific error message
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-08
# asmo: 2018-12-22
--------------------------------------------------------------------------------
property noQuit : {¬
	"Alfred 3", ¬
	"Keyboard Maestro Engine", ¬
	"Little Snitch Agent", ¬
	"Typinator", ¬
	"FastScripts", ¬
	"Script Editor", ¬
	"Safari"}
--------------------------------------------------------------------------------
# IMPLEMENTATION:
tell application "System Events" to set runningApps to the ¬
	bundle identifier of application processes where the ¬
	POSIX path of the application file starts with "/Applications"

-- OR:
-- the bundle identifier of application processes where ¬
-- the class of its menu bar contains menu bar and ¬
-- the POSIX path of the application file ¬
--	does not start with "/System" and ¬
-- the POSIX path of the application file ¬
--	does not start with "/Library"

kill(runningApps, noQuit)
--------------------------------------------------------------------------------
# HANDLERS:
to kill(Apps as list, X as list)
	local Apps, X
	
	script programs
		property list : Apps
	end script
	
	repeat with A in the list of programs
		ignoring application responses
			tell application id A to if its name ¬
				is not in X then quit it
		end ignoring
	end repeat
end kill
---------------------------------------------------------------------------❮END❯