#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: URL PARSER#APPLESCRIPT
# nmxt: .applescript
# pDSC: URL scheme parser for applescript://

# plst: +filename : The URL without the scheme component, which equates to the
#                   name of the AppleScript file

# rslt: - AppleScript file opened
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-30
# asmo: 2019-05-01
--------------------------------------------------------------------------------
property parent : script "load.scpt"
property scheme : "applescript"
property folder : rootdir
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run filename
	if the filename's class = script then set the filename ¬
		to ["Finder#Ascend.applescript"]
	set [filename] to the filename
	
	set fURL to the file named filename in sys's item folder as alias
	set f to Finder's file fURL
	if f's class = «class alia» then set f to f's «class orig»
	
	tell application "Script Editor" to open (f as alias)
	true
end run
---------------------------------------------------------------------------❮END❯