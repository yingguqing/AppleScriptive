#!/usr/bin/osascript
--------------------------------------------------------------------------------
###_.applescript
#
#	A library of AppleScript properties and handlers that provides top-level
#	handlers and script objects to AppleScripts that invoke this as its
#	parent
#
#  Input:
#	None
#
#  Result:
#	Self			The whole AppleScript as a script object
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-04-17
#  Date Last Edited: 2018-09-16
--------------------------------------------------------------------------------
property god : me
property parent : AppleScript
property path : missing value
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
[path to me, "::"] as text as alias
set (my path) to the result's POSIX path

run _
_
--------------------------------------------------------------------------------
property tid : text item delimiters
--------------------------------------------------------------------------------
script common
	property parent : god
	------------------------------------------------------------------------
	###FILE MANIPULATION HANDLERS
	#
	#
	on fullPath for f as text : "~/"
		local f
		
		if f does not contain "~/" then return f
		
		replace of f from "~/" to (_path to home folder)
	end fullPath
	
	
	on _path to f
		local f
		
		#if f's class is constant then return POSIX path of (path to f)
		try
			path to f
		on error
			fullPath for f
		end try
		
		POSIX path of the result
	end _path
	
	
	on fRef(f)
		local f
		
		try
			(_path to f) as POSIX file as alias
		on error
			return null
		end try
	end fRef
	
	
	on basename for f
		set f to _path to f
		if f ends with "/" then set f to text 1 thru -2 of f
		
		return the last item in split(f, "/")
	end basename
	
	
	on dirname for f
		set f to _path to f
		if f ends with "/" then set f to text 1 thru -2 of f
		
		items 1 thru -2 in split(f, "/")
		join(the result, "/")
	end dirname
	
	
	on extension for f
		last item in split(_path to f, ".")
	end extension
	
	
	on isFileOrFolder(f)
		local f
		
		set f to fRef(f)
		if f = null then return null -- path doesn't exist
		
		set f to (f's POSIX path) as POSIX file
		tell application "Finder" to tell ¬
			item f to if its class ¬
			is in [document file, folder] ¬
			then return its class
		
		false
	end isFileOrFolder
	
	
	to rm(f)
		local f
		
		set f to fRef(f)
		if f = null then return null
		
		tell application "Finder" to delete f
	end rm
	------------------------------------------------------------------------
	###TEXT MANIPULATION HANDLERS
	#
	#
	on tid:(d as list) -- set text item delimiters (0 to revert to previous)
		local d
		
		if d is {} or d is {0} then
			set d to tid
		else if d's first item is null then
			set d's first item ¬
				to (1 / pi) * (random number from 0.0 to 1.0)
		end if
		
		set tid to AppleScript's text item delimiters
		set AppleScript's text item delimiters to d
	end tid:
	
	
	to split(s as text, d as list)
		tid_(d)
		set s to the text items of s
		tid_(0)
		
		return s
	end split
	
	
	to join(s as list, d as list)
		tid_(d)
		set s to s as text
		tid_(0)
		
		return s
	end join
	
	
	to replace of (s as text) from a as list to b
		local a, b
		local s
		
		my tid:({b} & a)
		set s to the text items of s as text
		tid_(0)
		
		return s
	end replace
	on del(s as text, d as list)
		local s, d
		
		replace of s from d to null
	end del
	
	
	on quoted(s as text)
		quoted form of s
	end quoted
	on q(s)
		quoted(s)
	end q
	
	
	to escape(s as text)
		local s
		
		repeat with char in items of "\\][^$.|?*+(){}"
			(my tid:{"\\" & char, char})
			set s to text items of s as text
		end repeat
		
		tid_(0)
		
		return s
	end escape
	on esc(s)
		escape(s)
	end esc
	
	
	on toString:object
		local object
		
		try
			set s to object as null
		on error E --> "Can’t make %object% into type null."
			tid_("Can’t make ")
			set s to the rest of the text items of E as text
			
			tid_(" into type null.")
			set s to text items 1 thru -2 of s as text
		end try
	end toString:
	on str(obj)
		toString_(obj)
	end str
	
	
	on toNumber:object
		local object
		
		if the object is in ["", {}] then return s
		
		if the class of the object is list then return ¬
			{my toNumber:(the object's first item)} & ¬
			(my toNumber:(the rest of the object))
		
		try
			the object as number
		on error
			try -- true/false, yes/no
				the object as boolean as integer
			on error
				the object
			end try
		end try
	end toNumber:
	on val(obj)
		my toNumber:obj
	end val
	
	
	to trimL(s)
		local s
		
		if class of s is not list then set s to (id of s) as list
		if s = {} then return ""
		
		script
			property str : s
		end script
		
		tell the result
			set [x, xN] to [first item, rest] of its str
			if x is not in [32, 9] then return character id (its str)
		end tell
		
		trimL(xN)
	end trimL
	to trimR(s)
		set s to {} & id of s
		{} & id of trimL(reverse of s)
		character id (reverse of result)
	end trimR
	to trim(s)
		trimR(trimL(s))
	end trim
	------------------------------------------------------------------------
	###LIST MANIPULATION HANDLERS
	#
	# (filter, foldl, map): http://forum.latenightsw.com/u/ComplexPoint
	# filter :: (a -> Bool) -> [a] -> [a]
	to filter(fn, xs)
		set L to {}
		
		tell wrap(fn) to ¬
			repeat with i from 1 to the length of xs
				set v to item i of xs
				if |λ|(v, i, xs) then set end of L to v
			end repeat
		
		return L
	end filter
	
	# foldl :: (a -> b -> a) -> a -> [b] -> a
	to foldl(fn, startValue, xs)
		set v to startValue
		
		tell wrap(fn) to ¬
			repeat with i from 1 to the length of xs
				set v to |λ|(v, item i of xs, i, xs)
			end repeat
		
		return v
	end foldl
	
	# map :: (a -> b) -> [a] -> [b]
	to map(fn, xs)
		set L to {}
		
		tell wrap(fn) to ¬
			repeat with i from 1 to the length of xs
				set end of L to |λ|(item i of xs, i, xs)
			end repeat
		
		return L
	end map
	
	# Lift 2nd class handler function into 1st class script wrapper
	# mReturn :: First-class m => (a -> b) -> m (a -> b)
	on wrap(fn)
		if class of fn is script then
			fn
		else
			script
				property |λ| : fn
			end script
		end if
	end wrap
	
	
	to flatten(L)
		local L
		
		if L = {} then return {}
		if L's class ≠ list then return {L}
		
		script
			property array : L
		end script
		
		tell the result to set [x, xN] to ¬
			[first item, rest] of its array
		
		flatten(x) & flatten(xN)
	end flatten
	
	
	on indexOf(x, L)
		local x, L
		
		if L = {} or (x is not in L) then return 0
		if L's class = text then set L to L's characters
		
		script
			property array : L
		end script
		
		tell the result's array
			repeat with i from 1 to its length
				if x ≠ its item i then
					set its item i to null
				else
					set its item i to i
				end if
			end repeat
			
			its numbers
		end tell
	end indexOf
	to getIndex of x from L
		indexOf(x, L)
	end getIndex
	
	
	on maximum(L as list)
		local L
		
		if L = {} then return {}
		if L's length = 1 then return L's first item
		if (numbers of L ≠ L) and (strings of L ≠ L) then return
		
		script
			property array : L
		end script
		
		tell the result's array to set [x, xN] to [¬
			(its first item), the rest of it]
		
		tell maximum(xN) to if it > x then return it
		return x
	end maximum
	
	
	on minimum(L as list)
		local L
		
		if L = {} then return {}
		if L's length = 1 then return L's first item
		if (numbers of L ≠ L) and (strings of L ≠ L) then return
		
		script
			property array : L
		end script
		
		tell the result's array to set [x, xN] to [¬
			(its first item), the rest of it]
		
		tell minimum(xN) to if it < x then return it
		return x
	end minimum
	
	
	on lastIndexOf(x, L)
		local x, L
		
		if L = {} or (x is not in L) then return 0
		if L's class = text then set L to L's characters
		
		script
			property array : reverse of L
		end script
		
		tell the result's array to repeat with i from 1 to its length
			if x = its item i then return 1 + (its length) - i
		end repeat
		
		0
	end lastIndexOf
	
	
	to swap(L as list, i as integer, j as integer)
		local i, j, L
		
		if i = j then return
		
		set x to item i of L
		set item i of L to item j of L
		set item j of L to x
	end swap
	
	
	to sort(L as list)
		local L
		
		if L = {} then return {}
		if L's length = 1 then return L
		
		script
			property array : L
		end script
		
		tell the result's array
			set [x, xN, i] to [¬
				a reference to its first item, ¬
				a reference to the rest of it, ¬
				(my lastIndexOf(my minimum(it), it))]
			my swap(it, 1, i)
		end tell
		
		{x's contents} & sort(xN's contents)
	end sort
	
	
	to sum(L as list)
		local L
		
		if L = {} then return 0
		if numbers of L ≠ L then return
		
		script
			property array : L's contents
		end script
		
		tell the result to tell its array
			repeat with i from 1 to (its length) - 1
				set [x0, x1] to its [item i, item (i + 1)]
				set its item (i + 1) to x1 + x0
				set its item i to null
			end repeat
			
			its end
		end tell
	end sum
	
	
	on unique(L as list)
		local L
		
		if L = {} then return {}
		
		script
			property array : L
		end script
		
		tell the result's array
			repeat with i from 1 to (its length) - 1
				set [x, xN] to its [item i, ¬
					items (i + 1) thru -1]
				if x is in xN then set its item i to null
			end repeat
			
			classes & files & aliases & ¬
				booleans & dates & ¬
				strings & numbers
		end tell
	end unique
	
	
	on numberList from m : 1 to n : 20 by d : 1
		local m, n, d
		
		if (m > n) or (d < 1) then return {}
		
		script
			property array : {}
		end script
		
		tell the result's array
			repeat with i from m to n by d
				set its end to i
			end repeat
			
			it
		end tell
	end numberList
	on array(n as integer)
		numberList to n
	end array
	
	
	on everyNthItem of (L as list) from i as integer : 1 by n as integer : 2
		local L, i, n
		
		if (i > L's length) then return {}
		
		script
			property array : items i thru -1 of L
			property m : {}
		end script
		
		tell the result
			repeat with j from 1 to its array's length by n
				set end of its m to item j of its array
			end repeat
			
			its m
		end tell
	end everyNthItem
	
	
	to sum:(L as list)
		foldl(add, 0, L)
	end sum:
	
	
	on product:(L as list)
		foldl(multiply, 1, L)
	end product:
	------------------------------------------------------------------------
	###DATE & TIME HANDLERS
	#
	#
	to makeASdate given year:y, month:m, day:d ¬
		, hour:h : 0, min:mm : 0, sec:s : 0
		local y, m, d, h, mm, s
		
		tell (the current date) to set ¬
			[ASdate, year, its month, day, time] to ¬
			[it, y, m, d, hours * h + minutes * mm + s]
		
		ASdate
	end makeASdate
	
	
	on ISOdate for ASdate as date
		#using terms from application "Finder"
		ASdate as «class isot» as string
		#end using terms from
		return [text 1 thru 10, text 12 thru 19] of the result
		
		-- Alternative method:
		set [y, m, d, t] to [year, month, day, time string] of ASdate
		return [the contents of [y, ¬
			"-", text -1 thru -2 of ("0" & (m as integer)), ¬
			"-", text -1 thru -2 of ("0" & (d as integer))] ¬
			as text, t]
	end ISOdate
	
	
	on now() -- Unix time (in seconds)
		makeASdate given year:1970, month:January, day:1
		((current date) - result) as yards as string
	end now
	
	
	on AppleTimeToASDate(t as number)
		local t
		
		makeASdate given year:2001, month:January, day:1
		result + t
	end AppleTimeToASDate
	
	
	on timer()
		global __now__
		
		script timer
			property duration : 0
			
			on start()
				copy time of (current date) to __now__
				0
			end start
			
			on finish()
				set duration to (time of (current date)) - __now__
				set __now__ to null
			end finish
		end script
		
		try
			__now__
		on error
			return timer's start()
		end try
		
		if the result = null then return timer's start()
		
		tell timer to finish()
		get timer's duration
	end timer
	------------------------------------------------------------------------
	###SYSTEM INFORMATION HANDLERS
	#
	#
	on frontApp()
		_path to frontmost application
		{name:name of application named result, path:result}
	end frontApp
	
	
	on Screen()
		tell application "System Events" to tell process "Finder" to ¬
			return {width:item 1, height:item 2} ¬
				of (size of scroll area 1 as list)
	end Screen
	
	
	on Menubar()
		tell application "System Events" to tell process "Finder" to ¬
			return {width:item 1, height:item 2} ¬
				of (size of menu bar 1 as list)
	end Menubar
	
	(*
	to setProgress to x as integer : null out of N as integer : null ¬
		given text:t as string : null, info:s as string : null
		local done, total, title, status

		if x is not null then set progress completed steps to x
		if N is not null then set progress total steps to N
		if t is not null then set progress description to t
		if s is not null then set progress additional description to s
	end setProgress
	*)
	
	to showError(msg as text)
		display notification msg ¬
			with title my name ¬
			subtitle "⚠️ Error"
	end showError
	------------------------------------------------------------------------
	###NUMBER & LOGIC HANDLERS
	#
	#
	on bool:x
		-- Recurse through lists and sum their boolean values
		if x = {} then return false
		if x's class is list then return ¬
			bool_(x's first item) or ¬
			bool_(the rest of x)
		
		-- Handle file paths (test for existence)
		if class of x is alias then return true
		if class of x is «class furl» then try
			x as alias
			return true
		on error
			return false
		end try
		
		-- Script objects
		if class of x is script then return bool_(run x)
		
		x is not in ["", 0, no, false, null, missing value] and ¬
			class of x is in [¬
			string, text, ¬
			integer, real, number, ¬
			boolean, constant, ¬
			null, missing value]
	end bool:
end script
--------------------------------------------------------------------------------
script shell
	property parent : common
	------------------------------------------------------------------------
	###SCRIPT EXECUTION
	#
	#
	to do:sh
		tid_(space)
		set sh to sh as text
		tid_(0)
		
		do shell script sh
	end do:
	------------------------------------------------------------------------
	###DATE & TIME FUNCTIONS
	#
	#
	on ISOd()
		my do:"DATE +'%Y-%m-%d'"
	end ISOd
	
	
	on ISOt()
		my do:"DATE +'%H.%M'"
	end ISOt
	
	
	on UNIXtime()
		my do:"DATE +%s"
	end UNIXtime
	------------------------------------------------------------------------
	###STRING MANIPULATION
	#
	#
	on grep against pattern from input ¬
		given caseInsensitivity:i as boolean : true ¬
		, onlyMatching:o as boolean : false
		
		local pattern, input
		local i, o
		
		set [_i, _o] to ["-i", "-o"]
		set redirect to "<<<"
		
		if fRef(input) ≠ null then
			set redirect to "<"
			set input to _path to input
		end if
		
		if not i then set _i to ""
		if not o then set _o to ""
		
		my do:{"egrep", _i, _o, "-e", ¬
			the quoted(pattern), ¬
			the redirect, ¬
			the quoted(input)}
	end grep
	------------------------------------------------------------------------
	###FILE OPERATIONS
	#
	#
	on plutil from inf : "-" to outf : "-" into t ¬
		given formatting:pretty as boolean : false ¬
		, input:input : {}
		
		local inf, outf, format
		local pretty, s
		
		if t is not in ["xml1", "binary1", "json"] then ¬
			set t to "json"
		
		my do:{"plutil", "-convert", t, ¬
			q(inf), "-o", q(outf)}
	end plutil
	
	
	on cp from input to fp given subfolders:R as boolean : false
		set [input, fp] to [_path to input, _path to fp]
		set _R to ""
		if R then set _R to "-R"
		
		my do:{"cp", _R, q(input), q(fp)}
	end cp
	
	
	on mv from input to fp
		set [input, fp] to [_path to input, _path to fp]
		my do:{"mv", q(input), q(fp)}
	end mv
	
	
	on rm at fp given subfolders:R as boolean : false
		set fp to _path to fp
		set _R to ""
		if R then set _R to "-R"
		
		my do:{"rm", _R, q(fp)}
	end rm
end script
--------------------------------------------------------------------------------
script ASObjC
	use framework "AppKit"
	use framework "Foundation"
	use scripting additions
	------------------------------------------------------------------------
	property parent : shell
	------------------------------------------------------------------------
	property this : a reference to the current application
	property NSAirdrop : a reference to NSSharingServiceNameSendViaAirDrop of this
	property NSArray : a reference to NSArray of this
	property NSCalendar : a reference to NSCalendar of this
	property NSCharacterSet : a reference to NSCharacterSet of this
	property NSData : a reference to NSData of this
	property NSDate : a reference to NSDate of this
	property NSDictionary : a reference to NSDictionary of this
	property NSEvent : a reference to NSEvent of this
	property NSFileManager : a reference to NSFileManager of this
	property NSJSONSerialization : a reference to NSJSONSerialization of this
	property NSMutableArray : a reference to NSMutableArray of this
	property NSMutableDictionary : a reference to NSMutableDictionary of this
	property NSMutableOrderedSet : a reference to NSMutableOrderedSet of this
	property NSMutableSet : a reference to NSMutableSet of this
	property NSPredicate : a reference to NSPredicate of this
	property NSProcessInfo : a reference to NSProcessInfo of this
	property NSPropertyListSerialization : a reference to NSPropertyListSerialization of this
	property NSPropertyListXMLFormat_v1_0 : a reference to 100
	property NSRegularExpression : a reference to NSRegularExpression of this
	property NSRegularExpressionAnchorsMatchLines : a reference to 16
	property NSRegularExpressionCaseInsensitive : a reference to 1
	property NSRegularExpressionDotMatchesLineSeparators : a reference to 8
	property NSRunLoop : a reference to NSRunLoop of this
	property NSRunningApplication : a reference to NSRunningApplication of this
	property NSScreen : a reference to NSScreen of this
	property NSSet : a reference to NSSet of this
	property NSSharingService : a reference to NSSharingService of this
	property NSString : a reference to NSString of this
	property NSURL : a reference to NSURL of this
	property NSURLComponents : a reference to NSURLComponents of this
	property NSUTF8StringEncoding : a reference to 4
	property NSUTF16LEStringEncoding : a reference to NSUTF16LittleEndianStringEncoding of this
	property NSUTF16StringEncoding : a reference to 10
	property NSWorkspace : a reference to NSWorkspace of this
	------------------------------------------------------------------------
	###STRING MANIPULATION HANDLERS
	#
	#
	on REmatch against pattern from str given captureTemplate:fmt ¬
		, matchingCase:i as boolean : false ¬
		, anchorsMatchingLines:g as boolean : true ¬
		, dotMatchingLineSeparators:m as boolean : true
		local pattern, str, fmt
		local i, g, m
		
		set [i, g, m] to [i as integer, g as integer, m as integer]
		
		set options to ¬
			i * NSRegularExpressionCaseInsensitive + ¬
			g * NSRegularExpressionAnchorsMatchLines + ¬
			m * NSRegularExpressionDotMatchesLineSeparators
		
		set regex to NSRegularExpression's ¬
			regularExpressionWithPattern:pattern ¬
				options:options ¬
				|error|:(missing value)
		
		set matches to regex's matchesInString:str ¬
			options:0 range:{0, str's |length|()}
		
		set results to NSMutableArray's array()
		
		repeat with match in matches
			(results's addObject:(regex's ¬
				replacementStringForResult:match ¬
					inString:str ¬
					|offset|:0 ¬
					template:fmt))
		end repeat
		
		return the results as list
	end REmatch
	
	
	to URLencode(s)
		local str
		
		set allowed to NSCharacterSet's URLPathAllowedCharacterSet()
		set str to NSString's stringWithString:s
		str's stringByAddingPercentEncodingWithAllowedCharacters:allowed
		
		result as text
	end URLencode
	------------------------------------------------------------------------
	###SYSTEM INFORMATION HANDLERS
	#
	#
	on Screen() --> {width:real,height:real}
		NSDeviceSize ¬
			of deviceDescription() ¬
			of item 1 ¬
			of NSScreen's screens() ¬
			as record
	end Screen
	
	
	on Mouse() --> {x:real, y:real}
		-- Mouse position relative to bottom-left of screen
		NSEvent's mouseLocation as record
		-- Adjust mouse position coordinates to be relative
		-- to top-left of screen
		{x:result's x, y:(Screen()'s height) - (result's y)}
	end Mouse
	
	
	#on Menubar() --> {width:real,height:real}
	#	item 2 ¬
	#		of (visibleFrame ¬
	#		of item 1 ¬
	#		of NSScreen's screens() ¬
	#		as record)
	#
	#	{width:result's item 1 ¬
	#		, height:(Screen()'s height) ¬
	#		- (result's item 2)}
	#end Menubar
	
	
	on frontmostApplication()
		NSWorkspace's sharedWorkspace's frontmostApplication's ¬
			{|name|:localizedName() ¬
				, |path|:bundleURL() ¬
				, |id|:bundleIdentifier()}
		toAny(result)
	end frontmostApplication
	
	
	on runningApplications()
		NSWorkspace's sharedWorkspace's ¬
			runningApplications()'s bundleIdentifier as list
	end runningApplications
	------------------------------------------------------------------------
	###JSON HANDLERS
	#
	#
	on JSONtoRecord from input
		local input
		
		if fileExists at input then
			set JSONdata to NSData's dataWithContentsOfFile:input
		else
			set JSONstr to NSString's stringWithString:input
			set JSONdata to JSONstr's ¬
				dataUsingEncoding:NSUTF8StringEncoding
		end if
		
		set [x, E] to (NSJSONSerialization's ¬
			JSONObjectWithData:JSONdata ¬
				options:0 ¬
				|error|:(reference))
		
		if x's isKindOfClass:NSDictionary then return x as record
		
		x as list
	end JSONtoRecord
	on JSONtoAS from input
		JSONtoRecord from input
	end JSONtoAS
	
	
	on RecordToJSON from (ASrecord as record) to f : null ¬
		given formatting:pretty as boolean : false
		local ASrecord, pretty
		
		set JSONdata to NSJSONSerialization's ¬
			dataWithJSONObject:ASrecord ¬
				options:pretty ¬
				|error|:(missing value)
		
		if f is null then
			(NSString's alloc()'s initWithData:JSONdata ¬
				encoding:NSUTF8StringEncoding) as text
		else
			(JSONdata's writeToFile:f atomically:true) as boolean
		end if
	end RecordToJSON
	on AStoJSON from ASdata to f : null ¬
		given formatting:pretty as boolean : false
		RecordToJSON from ASdata to f given formatting:pretty
	end AStoJSON
	------------------------------------------------------------------------
	###PLIST HANDLERS
	#
	#
	on AStoPlist from ASdata to f : null
		set [x, E] to NSPropertyListSerialization's ¬
			dataWithPropertyList:ASdata ¬
				format:NSPropertyListXMLFormat_v1_0 ¬
				options:0 |error|:(reference)
		
		if x is missing value then ¬
			error (E's localizedDescription() as text) number -10000
		
		if f is null then
			(NSString's alloc()'s initWithData:x ¬
				encoding:NSUTF8StringEncoding) as text
		else
			(x's writeToFile:f atomically:true) as boolean
		end if
	end AStoPlist
	
	
	on PlistToAS from input
		if fileExists at input then
			set x to NSData's dataWithContentsOfFile:input
		else
			set x to (NSString's stringWithString:input)'s ¬
				dataUsingEncoding:NSUTF8StringEncoding
		end if
		
		set [obj, E] to NSPropertyListSerialization's ¬
			propertyListWithData:x ¬
				options:0 ¬
				format:(missing value) ¬
				|error|:(reference)
		
		if obj is missing value then ¬
			error (E's localizedDescription() as text) number -10000
		
		set L to NSArray's arrayWithObject:obj
		return item 1 of (L as list)
	end PlistToAS
	------------------------------------------------------------------------
	###PLIST ⇌ JSON HANDLERS
	#
	#
	on PlistToJSON from input to f : null ¬
		given formatting:pretty as boolean : false
		
		PlistToAS from input
		AStoJSON from the result to f given formatting:pretty
	end PlistToJSON
	
	
	on JSONtoPlist from input to f : null
		JSONtoAS from input
		AStoPlist from the result to f
	end JSONtoPlist
	------------------------------------------------------------------------
	###DATE CONVERSION HANDLERS
	#
	#
	on ASDateToNSDate from ASdate as date
		set [y, m, d, s] to the ASdate's [year, month, day, time]
		set y to abs(y)
		
		NSCalendar's currentCalendar()'s dateWithEra:(y ≥ 0) ¬
			|year|:y |month|:(m as integer) |day|:d ¬
			hour:0 minute:0 |second|:s nanosecond:0
	end ASDateToNSDate
	
	
	on NSDateToASDate from NSDate
		set [y, m, d, h, mm, s] to (NSCalendar's currentCalendar()'s ¬
			componentsInTimeZone:(missing value) ¬
				fromDate:NSDate)'s [¬
			|year|(), |month|(), |day|(), ¬
			hour(), minute(), |second|()]
		
		tell the (current date) to set ¬
			[ASdate, year, day, its month, day, time] to ¬
			[it, y, 1, m, d, h * hours + mm * minutes + s]
		
		ASdate
	end NSDateToASDate
	
	
	to makeNSDate:{year:y, month:m, day:d, hours:h, minutes:mm, seconds:s}
		local y, m, d, h, mm, s
		
		NSCalendar's currentCalendar()'s dateWithEra:(y ≥ 0) ¬
			|year|:y |month|:m |day|:d ¬
			hour:h minute:mm |second|:s nanosecond:0
	end makeNSDate:
	
	
	on microtime() -- Unix Time in milliseconds
		(NSDate's |date|()'s timeIntervalSince1970()) * 1000000
	end microtime
	------------------------------------------------------------------------
	###DICTIONARY DATA HANDLERS
	#
	#
	to makeNSDictionary from ASdata for keys : null
		if keys = null then -- ASdata is a record
			if the class of ASdata is not record then return null
			NSDictionary's dictionaryWithDictionary:ASdata
		else -- ASdata is a list of values
			if the class of ASdata is not list then return null
			NSDictionary's dictionaryWithObjects:(NSArray's ¬
				arrayWithArray:ASdata) ¬
				forKeys:(NSArray's arrayWithArray:keys)
		end if
	end makeNSDictionary
	on AStoNSDictionary from ASdata for keys : null
		makeNSDictionary from ASdata for keys
	end AStoNSDictionary
	
	
	on NSDictionaryToRecord from NSDict
		(NSArray's arrayWithArray:{NSDict}) as list
		item 1 of the result
	end NSDictionaryToRecord
	on NSDictionaryToAS from NSDict
		NSDictionaryToRecord from NSDict
	end NSDictionaryToAS
	
	
	to setValue of NSDict to v for k
		NSDict's setValue:v forKey:k
	end setValue
	
	
	to getValue of NSDict for k
		NStoASObject from (NSDict's valueForKey:k)
	end getValue
	
	
	to getAllKeys from object
		if the object's class is record then
			makeNSDictionary from the object
		else
			the object
		end if
		
		the result's allKeys() as list
	end getAllKeys
	on everyKey from obj
		getAllKeys from obj
	end everyKey
	
	
	to getAllValues from object
		if the object's class is record then
			makeNSDictionary from the object
		else
			the object
		end if
		
		the result's allValues() as list
	end getAllValues
	on everyValue from obj
		getAllValues from obj
	end everyValue
	------------------------------------------------------------------------
	###FILE HANDLERS
	#
	#
	to getPath to f as text : "" for g as text : ""
		(NSString's stringWithString:(f & g))'s ¬
			stringByStandardizingPath() as text
		#	stringByExpandingTildeInPath as text
	end getPath
	
	
	on isDir:(f as text)
		NSURL's fileURLWithPath:(NSString's ¬
			stringWithString:(getPath to f))
		try
			(the result as text) ends with ":"
		on error -- likely path does not exist
			null
		end try
	end isDir:
	
	
	to getBasename for f
		(NSString's stringWithString:f)'s ¬
			lastPathComponent()'s ¬
			stringByDeletingPathExtension() as text
	end getBasename
	
	
	to getDirectory for f
		(NSString's stringWithString:f)'s ¬
			stringByDeletingLastPathComponent() as text
	end getDirectory
	
	
	to getExtension for f
		(NSString's stringWithString:f)'s ¬
			lastPathComponent()'s ¬
			pathExtension() as text
	end getExtension
	
	
	to getPathComponents for f
		(NSString's stringWithString:f)'s ¬
			pathComponents() as list
	end getPathComponents
	
	
	on fileExists at (f as text)
		NSFileManager's alloc()'s fileExistsAtPath:(getPath for f)
	end fileExists
	------------------------------------------------------------------------
	###URL HANDLERS
	#
	#
	to getURLComponents for www : "" from wwww : ""
		tell (NSURL's URLWithString:(wwww & www)) to set ¬
			URLComponents to NSDictionary's ¬
			dictionaryWithDictionary:{|scheme|:its |scheme|() ¬
				, |host|:its |host|() ¬
				, |port|:its |port|() ¬
				, |path|:its |path|() ¬
				, lastPathComponent:its lastPathComponent ¬
				, extension:its pathExtension() ¬
				, parameters:its parameterString() ¬
				, query:its query() ¬
				, fragment:its fragment()}
		
		URLComponents as record
	end getURLComponents
	
	
	to joinURLQueryItems from queryItems as list to www
		set |URL| to NSURLComponents's componentsWithString:www
		|URL|'s setQueryItems:(NSArray's ¬
			arrayWithObjects:queryItems)
		
		|URL|'s queryItems() as text
	end joinURLQueryItems
	------------------------------------------------------------------------
	###LIST & SET HANDLERS
	#
	#
	to sortListByItemLength(L as list)
		((NSArray's arrayWithArray:L)'s sortedArrayUsingDescriptors:{¬
			NSSortDescriptor's ¬
			sortDescriptorWithKey:"length" ascending:true}) ¬
			as list
	end sortListByItemLength
	
	
	on isSubset(W as list, Z as list)
		local W, Z
		
		(NSSet's setWithArray:W)'s isSubsetOfSet:(NSSet's setWithArray:Z)
	end isSubset
	
	
	on inBoth(W as list, Z as list)
		local W, Z
		
		set S1 to NSMutableSet's setWithArray:W
		set S2 to NSSet's setWithArray:Z
		
		S1's intersectSet:S2
		S1's allObjects() as list
	end inBoth
	to intersect(W, Z)
		inBoth(W, Z)
	end intersect
	
	
	to merge(W as list, Z as list)
		local W, Z
		
		set S1 to NSMutableSet's setWithArray:W
		set S2 to NSSet's setWithArray:Z
		
		S1's unionSet:S2
		S1's allObjects() as list
	end merge
	
	
	to minus(W as list, Z as list)
		local W, Z
		
		set S1 to NSMutableOrderedSet's orderedSetWithArray:W
		set S2 to NSSet's setWithArray:Z
		
		S1's minusSet:S2
		S1's allObjects() as list
	end minus
	------------------------------------------------------------------------
	###MISCELLANEOUS HANDLERS
	#
	#
	on NStoASObject from NSObject
		(NSArray's arrayWithObject:NSObject) as list
		item 1 of the result
	end NStoASObject
	on toAny(NSObj)
		NStoASObject from NSObj
	end toAny
	
	
	to airdrop:(input as list)
		local input
		
		-- The list of verified file URLs to share
		set fURLs to NSMutableArray's arrayWithCapacity:(count input)
		
		repeat with f in the input
			if isDir_(f) = false then
				(NSString's stringWithString:(getPath to f))
				(fURLs's addObject:(|NSURL|'s ¬
					fileURLWithPath:result))
			end if
		end repeat
		
		if (count fURLs) = 0 then return "No files to process."
		
		set AirdropService to a reference to (NSSharingService's ¬
			sharingServiceNamed:NSAirdrop)
		
		if (AirdropService's canPerformWithItems:fURLs) then
			tell the AirdropService to performWithItems:fURLs
			
			NSRunLoop's currentRunLoop's ¬
				runUntilDate:(NSDate's |date|())
			
			return 1
		end if
		
		0
	end airdrop:
end script
--------------------------------------------------------------------------------
script Maths
	property parent : ASObjC
	------------------------------------------------------------------------
	on even(x)
		x mod 2 is 0
	end even
	on odd(x)
		not even(x)
	end odd
	
	
	to add(a, b)
		a + b
	end add
	
	
	to multiply(a, b)
		a * b
	end multiply
	
	
	on abs(x)
		if x < 0 then set x to -x
		x
	end abs
	
	
	on floor(x)
		x - 0.5 as integer
	end floor
	
	
	on sqrt(x)
		x ^ 0.5
	end sqrt
	
	
	to approx of x to n
		set SixteenZeroes to "0000000000000000"
		set x to x as miles as text
		
		if the length of x ≤ n then return x as number
		
		if x does not contain "." then -- significant figures
			set m to the length of x
			set x to the contents of {¬
				text 1 thru n of x, ¬
				text 1 thru (m - n) of SixteenZeroes} ¬
				as text
		else -- decimal places
			set the text item delimiters to "."
			
			set x to the contents of {¬
				text item 1, ¬
				text 1 thru n of text item 2} ¬
				of ([x, SixteenZeroes] as text) ¬
				as text
			
			set the text item delimiters to {}
			#set d to 10 ^ n
			#(round (x * d)) / d
		end if
		
		x as number
	end approx
	
	
	on prime(x)
		local x
		
		x = end of primes(x)
	end prime
	
	
	on primes(n)
		local n
		
		
		if n < 2 then return {}
		
		script P -- The list of integers to be sieved
			property L : rest of array(n)
		end script
		
		tell P to repeat with i from 1 to sqrt(n)
			set d to item i of its L
			
			if d ≠ null then repeat with j from ¬
				(i + d) to the length of its L by d
				
				set item j of its L to null
			end repeat
		end repeat
		
		numbers of P's L
	end primes
	
	
	to getNextPrime(x)
		local x
		
		if x < 2 then return 2
		
		script
			property P : primes(x)
			
			on isPrime(n)
				local n
				
				set lim to sqrt(n)
				
				repeat with p0 in P
					if (n mod p0) = 0 then return false
					if p0 > lim then exit repeat
				end repeat
				
				true
			end isPrime
		end script
		
		tell the result
			set x to the end of its P
			repeat
				set x to x + 1
				if isPrime(x) then exit repeat
			end repeat
		end tell
		
		x
	end getNextPrime
	
	
	to factorise(x)
		script
			property lim : sqrt(x)
			property P : primes(lim) & getNextPrime(lim)
			property L : {}
		end script
		
		tell the result
			repeat with p0 in its P
				repeat until (x mod p0) ≠ 0
					set end of its L to p0
					set x to x / p0
				end repeat
				if x = 1 then exit repeat
			end repeat
			
			if x ≠ 1 then set end of its L to x as integer
			
			contents of its L
		end tell
	end factorise
	
	
	on fibonacci(x, a, b)
		local x, a, b
		
		script
			property L : {a, b}
			
			to add(x, y)
				local x, y
				
				x + y
			end add
		end script
		
		tell the result
			repeat (x - 2) times
				set [x0, x1] to [item -1, item -2] of its L
				set end of its L to add(x0, x1)
			end repeat
			
			its L
		end tell
	end fibonacci
end script
--------------------------------------------------------------------------------
script Finder
	use Finder : application "Finder"
	using terms from application "Finder"
		property nil : null
	end using terms from
	------------------------------------------------------------------------
	property parent : common
	------------------------------------------------------------------------
	-- Tags (label index)
	property unset : 0
	property orange : 1
	property red : 2
	property yellow : 3
	property blue : 4
	property purple : 5
	property green : 6
	property grey : 7
	------------------------------------------------------------------------
	to tag(f, i as integer)
		local f
		
		set f to fRef(f)
		if f = nil then return nil
		
		set f's label index to i
	end tag
	
	
	to show:f
		local f
		
		set f to fRef(f)
		if f = nil then return nil
		
		reveal f
		activate Finder
		
		_path to f
	end show:
	
	
	to remove:f
		rm(f)
	end remove:
end script
--------------------------------------------------------------------------------
script plist
	property parent : Maths
	
	property PathTo : missing value
	property WxH : missing value
	
	
	POSIX path of («event earsffdr» me)
	getDirectory for the result
	getDirectory for the result
	set fol to getPath to [result, "/data"]
	
	set PathTo to PlistToAS from (fol & "/PathTo.plist")
	set WxH to PlistToAS from (fol & "/WxH.plist")
end script
--------------------------------------------------------------------------------
script _
	property parent : plist
end script
---------------------------------------------------------------------------❮END❯
