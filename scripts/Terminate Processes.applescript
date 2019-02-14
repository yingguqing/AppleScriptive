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
# asmo: 2019-01-04
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to the current application
property NSMutableArray : a reference to NSMutableArray of this
property NSPredicate : a reference to NSPredicate of this
property NSSortDescriptor : a reference to NSSortDescriptor of this
property NSWorkspace : a reference to NSWorkspace of this

property key : "localizedName"
property sort : "caseInsensitiveCompare:"

property text item delimiters : linefeed
--------------------------------------------------------------------------------
# IMPLEMENTATION:
set A to NSMutableArray's array()
set SortDescriptor to NSSortDescriptor's ¬
	sortDescriptorWithKey:key ascending:yes selector:sort
set sharedWorkspace to NSWorkspace's sharedWorkspace()

A's addObjectsFromArray:(sharedWorkspace's runningApplications())
A's sortUsingDescriptors:[SortDescriptor]

(* tell application "Keyboard Maestro Engine"
	do script "List" with parameter A's localizedName as list as text
	getvariable "Result"
end tell *)

tell (choose from list A's localizedName as list ¬
	with title "Running Processes" with prompt ¬
	"Select processes to kill:" OK button name ¬
	"Quit" empty selection allowed false ¬
	with multiple selections allowed) to ¬
	if {} ≠ it then repeat with proc in (A's ¬
		filteredArrayUsingPredicate:(NSPredicate's ¬
			predicateWithFormat:(my key & " IN %@") ¬
				argumentArray:[it]))
		# proc's terminate()
		proc's forceTerminate()
	end repeat
---------------------------------------------------------------------------❮END❯