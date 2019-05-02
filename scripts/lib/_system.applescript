#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _SYSTEM
# nmxt: .applescript
# pDSC: System information, interface and utility handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-11-17
# asmo: 2019-05-02
--------------------------------------------------------------------------------
property name : "_system"
property id : "chri.sk.applescript._system"
property version : 1.0
property _system : me
--------------------------------------------------------------------------------
use framework "Automator"
use framework "CoreWLAN"
use framework "Foundation"
use framework "JavaScriptCore"
use scripting additions

property this : a reference to current application
property nil : a reference to missing value
property _1 : a reference to reference

property AMWorkflow : a reference to AMWorkflow of this
property CWWiFiClient : a reference to CWWiFiClient of this
property JSContext : a reference to JSContext of this
property NSDictionary : a reference to NSDictionary of this
property NSPredicate : a reference to NSPredicate of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this
property NSWorkspace : a reference to NSWorkspace of this

property interface : a reference to CWWiFiClient's sharedWiFiClient's interface
property Workspace : a reference to NSWorkspace's sharedWorkspace

property UTF8 : a reference to 4
property WEP104 : a reference to 2

property WiFiChannels : {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 36, 40, 44, 48}
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

on JSObjC(objc_framework, function, args as linked list)
	local objc_framework, function, args
	
	repeat with arg in args
		if the arg's contents ends with ")" then ¬
			set arg's contents to ["$.", arg]
		set the arg's contents to [linefeed, tab, tab, arg, ","]
	end repeat
	
	set args to args as text
	if args ≠ "" then set args to arg's text 1 thru -2
	
	"ObjC.import(" & objc_framework's quoted form & ");
	 nil=$();
	 ObjC.deepUnwrap($." & function & "(" & args & "));"
end JSObjC

# WiFiOn:
#   If +state is a boolean value, then this handler sets the power state of the
#   WiFi interface accordingly: true/yes -> On, false/no -> Off.  Otherwise,
#   the handler retrieves the current power state of the interface.
on WiFiOn:state
	tell the interface()
		if state is not in [true, false, yes, no] ¬
			then return its powerOn() as boolean
		
		its setPower:state |error|:nil
	end tell
	
	WiFiOn_(null)
end WiFiOn:

# WiFiStrengths()
#   Returns a records containing the signal strengths of nearby WiFi networks
#   labelled according to their SSIDs
on WiFiStrengths()
	tell the interface()
		if not (its powerOn() as boolean) then return false
		
		its scanForNetworksWithName:nil |error|:nil
		set networks to the result's allObjects()
	end tell
	set SSIDs to networks's valueForKey:"ssid"
	set RSSIValues to networks's valueForKey:"rssiValue"
	
	NSDictionary's dictionaryWithObjects:RSSIValues forKeys:SSIDs
	result as record
end WiFiStrengths

# joinNetwork
#   Turns on the WiFi interface and attempts to search for visible networks
#   with the specified +ssid, joining the first one that matches
to joinNetwork given name:ssid as text, password:pw as text : missing value
	local ssid, pw
	
	set predicate to "self.ssid == %@"
	set |?| to NSPredicate's predicateWithFormat_(predicate, ssid)
	
	tell the interface()
		its setPower:true |error|:nil
		
		set networks to {}
		tell cachedScanResults() to if it ≠ missing value then ¬
			set networks to filteredSetUsingPredicate_(|?|)
		
		if the number of networks = 0 then set networks to ¬
			(its scanForNetworksWithName:ssid |error|:nil)
		
		set network to (allObjects() in networks)'s firstObject()
		its associateToNetwork:network |password|:pw |error|:_1
		set [success, E] to the result
		if E ≠ missing value then return ¬
			E's localizedDescription() ¬
			as text
		success
	end tell
end joinNetwork

# createAdHocNetwork:
#   creates and joins an ad-hoc local Wi-Fi network using the supplied +ssid,
#   and password (+pw), broadcasting on the specified +channel
to createAdHocNetwork:{name:ssid as text ¬
	, password:pw as text ¬
	, channel:channel as integer}
	local ssid, pw, channel
	
	if channel is not in WiFiChannels then set ¬
		channel to some item of WiFiChannels
	
	interface()'s startIBSSModeWithSSID:((NSString's ¬
		stringWithString:ssid)'s ¬
		dataUsingEncoding:UTF8) ¬
		security:WEP104 channel:channel ¬
		|password|:pw |error|:_1
	set [success, E] to the result
	if E ≠ missing value then return E's localizedDescription() as text
	
	success
end createAdHocNetwork:

# battery()
#   Battery information
on battery()
	script battery
		use framework "IOKit"
		
		on info()
			current application's IOPSCopyPowerSourcesInfo() ¬
				as record
		end info
	end script
	
	battery's info()
end battery

# defaultBrowser()
#   Returns the name of the system's default web browser
on defBrowser()
	set sharedWorkspace to NSWorkspace's sharedWorkspace()
	set www to NSURL's URLWithString:"http:"
	(sharedWorkspace's URLForApplicationToOpenURL:www)'s ¬
		lastPathComponent()'s ¬
		stringByDeletingPathExtension() as text
end defaultBrowser

# colour [ syn. colorAt() ]
#   Returns the RGBA colour value of the pixel at coordinates {+x, +y}.
#   Pass either ordinate as null to use the mouse cursor location.  RGB
#   values' ranges are all 0-255; the alpha value range is 0.0-1.0.
on colour at {x, y}
	local x, y
	
	if {x, y} contains null then set {x, y} to {"mouseLoc.x", "mouseLoc.y"}
	set coords to [x, ",", space, y] as text
	
	run script "
	ObjC.import('Cocoa');
		
	var mouseLoc = $.NSEvent.mouseLocation;
	var screenH = $.NSScreen.mainScreen.frame.size.height;
	mouseLoc.y = screenH - mouseLoc.y;
		
	var image = $.CGDisplayCreateImageForRect(
			$.CGMainDisplayID(),
			$.CGRectMake(" & coords & ", 1, 1)
	            );
					
	var bitmap = $.NSBitmapImageRep.alloc.initWithCGImage(image);
	$.CGImageRelease(image);
		
	var color = bitmap.colorAtXY(0,0);
	bitmap.release;
		
	var r = Ref(), g = Ref(), b = Ref(), a = Ref();
	color.getRedGreenBlueAlpha(r,g,b,a);
		
	var rgba = [r[0]*255, g[0]*255, b[0]*255, a[0]];
	rgba;" in "JavaScript"
end colour
on colorAt(x, y)
	colour at {x, y}
end colorAt

# mouse
#   Moves the mouse cursor to a new position specified by {+x, +y}, relative to
#   the top-left corner of the screen
on mouse to {x, y}
	local x, y
	
	run script "
	ObjC.import('CoreGraphics');

	$.CGDisplayMoveCursorToPoint(
		$.CGMainDisplayID(), 
		{x:" & x & ", y:" & y & "}
	);" in "JavaScript"
end mouse

# click [ syn. clickAt() ]
#   Issues a mouse click at coordinates {+x, +y}, or at the current mouse 
#   cursor location if either ordinate is passed null
to click at {x, y}
	local x, y
	
	if {x, y} contains null then set {x, y} to {"mouseLoc.x", "mouseLoc.y"}
	
	run script "
	ObjC.import('Cocoa');
	nil=$();
		
	var mouseLoc = $.NSEvent.mouseLocation;
	var screenH = $.NSScreen.mainScreen.frame.size.height;
	mouseLoc.y = screenH - mouseLoc.y;
		
	var coords = {x: " & x & ", y: " & y & "};
		
	var mousedownevent = $.CGEventCreateMouseEvent(nil, 
	                     		$.kCGEventLeftMouseDown,
	                     		coords,
	                     		nil);
							       
	var mouseupevent = $.CGEventCreateMouseEvent(nil, 
	                   		$.kCGEventLeftMouseUp,
	                   		coords,
	                   		nil);
							     
	$.CGEventPost($.kCGHIDEventTap, mousedownevent);
	$.CGEventPost($.kCGHIDEventTap, mouseupevent);
	$.CFRelease(mousedownevent);
	$.CFRelease(mouseupevent);" in "JavaScript"
end click
to clickAt(x, y)
	click at {x, y}
end clickAt

# scrollY()
#   Issues a mousewheel vertical scrolling event with velocity +dx
to scrollY(dx)
	local dx
	
	run script "ObjC.import('CoreGraphics');
	nil=$();

	event = $.CGEventCreateScrollWheelEvent(
                        nil, 
                        $.kCGScrollEventUnitLine,
                        1,
                        " & dx & "
                );
	$.CGEventPost($.kCGHIDEventTap, event);
	$.CFRelease(event)" in "JavaScript"
end scrollY

# sendKeyCode [ see: press: ]
#   Sends a keyboard event to an application, +A, specified by name (or as an
#   application reference).  Boolean options are available to simulate key
#   modifier buttons, but these currently don't work due to a bug in the
#   API.
to sendKeyCode at key to A as text given shiftkey:shift as boolean : false ¬
	, commandkey:cmd as boolean : false, optionkey:alt as boolean : false
	local key, A, shift, cmd, alt
	
	shiftkey(shift)
	cmdKey(cmd)
	altKey(alt)
	
	run script "
	ObjC.import('Cocoa');
	nil=$();
		
	var app = '" & A & "';
	var bundleID = Application(app).id();
	var pid = ObjC.unwrap($.NSRunningApplication
	                       .runningApplicationsWithBundleIdentifier(
	                                bundleID))[0].processIdentifier;
		
	var keydownevent = $.CGEventCreateKeyboardEvent(nil," & key & ",true);
	var keyupevent = $.CGEventCreateKeyboardEvent(nil," & key & ",false);
	
	$.CGEventPostToPid(pid, keydownevent);
	$.CGEventPostToPid(pid, keyupevent);
			
	$.CFRelease(keydownevent);
	$.CFRelease(keyupevent);" in "JavaScript"
	
	shiftkey(up)
	cmdKey(up)
	altKey(up)
end sendKeyCode

# sendKeyChar:toApplication:using:
#   Similar in function to sendKeyCode but receives a text character in place
#   of a keycode
to sendKeyChar:(char as character) toApplication:(A as text) ¬
	using:{shift:shift as boolean ¬
	, command:cmd as boolean ¬
	, option:alt as boolean}
	
	(* To be implemented *)
	
end sendKeyChar:toApplication:using:

# shiftKey()
#   Declare the state of the shift key
on shiftkey(state)
	tell application "System Events" to key up shift
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down shift
end shiftkey

# cmdKey()
#   Declare the state of the command key
on cmdKey(state)
	tell application "System Events" to key up command
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down command
end cmdKey

# altKey()
#   Declare the state of the option key
on altKey(state)
	tell application "System Events" to key up option
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down option
end altKey

# ctrlKey()
#   Declare the state of the control key
on ctrlKey(state)
	tell application "System Events" to key up control
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down control
end ctrlKey

# define() [ syn. synonyms ]
#   Look up a word in the system's default dictionary or thesaurus
to define(w as text)
	local w
	
	run script "ObjC.import('CoreServices');
	nil = $();
	var word = '" & w & "';
	ObjC.unwrap(
		$.DCSCopyTextDefinition(
			nil, 
			word, 
			$.NSMakeRange(0, word.length)
		));" in "JavaScript"
end define
on synonyms for w
	define(w)
end synonyms
---------------------------------------------------------------------------❮END❯