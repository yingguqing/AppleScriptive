#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: TERMINATE PROCESSES
# nmxt: .applescript
# pDSC: Presents a list of running processes for termination

# plst: -

# rslt: - Processes terminate
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-17
# asmo: 2019-04-27
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to the current application
property NSPredicate : a reference to NSPredicate of this
property NSSortDescriptor : a reference to NSSortDescriptor of this
property NSWorkspace : a reference to NSWorkspace of this

property key : "localizedName"
property sortMethod : "caseInsensitiveCompare:"
property |?| : key & " IN %@"
--------------------------------------------------------------------------------
# IMPLEMENTATION:
NSWorkspace's sharedWorkspace()'s runningApplications()
set A to the result's sortedArrayUsingDescriptors:[NSSortDescriptor's ¬
	sortDescriptorWithKey:key ascending:yes selector:sortMethod]

tell (choose from list A's localizedName as list ¬
	with title ["Running Processes"] ¬
	with prompt ["Select processes to kill:"] OK button name ["Quit"] ¬
	with multiple selections allowed without empty selection allowed) ¬
	to if {} ≠ it then repeat with proc in (A's ¬
	filteredArrayUsingPredicate:(NSPredicate's ¬
		predicateWithFormat_(|?|, it)))
	# proc's terminate()
	proc's forceTerminate()
end repeat
---------------------------------------------------------------------------❮END❯