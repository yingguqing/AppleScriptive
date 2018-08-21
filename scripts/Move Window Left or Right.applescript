#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Move Window Left or Right.applescript
#
#	Shifts the currently focussed window left- or rightwards to align
#	itself with the contralateral edge of closest window in its path,
#	or to the edge of the screen if no windows remain. 
#
#  Input:
#	％dx％			A number whose sign determines the direction
#				of travel: left (-), right (+).
#
#  Result:
#	-			Window moves
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-02-26
#  Date Last Edited: 2018-08-20
--------------------------------------------------------------------------------
use application "System Events"
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run dx
	if (count dx) = 0 then set dx to [1]
	set [dx] to dx
	
	moveWindow(dx)
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
to moveWindow(dx as integer)
	script frames
		property _P : a reference to every process
		property _Q : a reference to (_P whose visible = true)
		property _W : a reference to every window of _Q
		property W : item 1 of windows of (_P whose frontmost = true)
		
		property D : item 1 ¬
			of (size ¬
			of scroll area 1 ¬
			of process "Finder" as list)
		
		property xs : (everyNthItem of (flatten(_W's position)) by 2)
		property ws : (everyNthItem of (flatten(_W's size)) by 2)
		
		property frame : {|left|:sort(unique(xs)) & D ¬
			, |right|:-1 & sort(unique(add(xs, ws)))}
	end script
	
	tell frames
		set W to a reference to its W
		
		set [[|left|, top], [width, height]] to W's [position, size]
		set |right| to |left| + width + 1
		set |left| to |left| - 1
		
		if (dx < 0) then
			if |left| ≤ 0 then return
			
			repeat with x in its frame's |right|'s reverse
				if x < |left| then exit repeat
			end repeat
			
			set x to x + 1
		else
			if (|left| + width + 1) ≥ its D then return
			
			repeat with x in its frame's |left|
				if x > |right| then exit repeat
			end repeat
			
			set x to x - width - 1
		end if
		
		set W's position to [x, top]
	end tell
end moveWindow
--------------------------------------------------------------------------------
###LIST MANIPULATION HANDLERS
#
#
to add(A as list, B as list)
	if A = {} and B = {} then return {}
	if A = {} then set A to {0}
	if B = {} then set B to {0}
	
	script
		property Array1 : A
		property Array2 : B
	end script
	
	tell the result
		set x to (item 1 of its Array1) + (item 1 of its Array2)
		{x} & add(rest of its Array1, rest of its Array2)
	end tell
end add

to flatten(L)
	local L
	
	if L = {} then return {}
	if L's class ≠ list then return {L}
	
	script
		property Array : L
	end script
	
	tell the result to set [x, xN] to ¬
		[first item, rest] of its Array
	
	flatten(x) & flatten(xN)
end flatten

on everyNthItem of (L as list) from i as integer : 1 by n as integer : 2
	local L, i, n
	
	if (i > L's length) then return {}
	
	script
		property Array : items i thru -1 of L
		property m : {}
	end script
	
	tell the result
		repeat with j from 1 to its Array's length by n
			set end of its m to item j of its Array
		end repeat
		
		its m
	end tell
end everyNthItem

on unique(L as list)
	local L
	
	if L = {} then return {}
	
	script
		property Array : L's contents
	end script
	
	tell the result's Array
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

to sort(L as list)
	local L
	
	if L = {} then return {}
	if L's length = 1 then return L
	
	script
		property Array : L
	end script
	
	tell the result's Array
		set [x, xN, i] to [¬
			a reference to its first item, ¬
			a reference to the rest of it, ¬
			(my lastIndexOf(my minimum(it), it))]
		my swap(it, 1, i)
	end tell
	
	{x's contents} & sort(xN's contents)
end sort

on minimum(L as list)
	local L
	
	if L = {} then return {}
	if L's length = 1 then return L's first item
	if (numbers of L ≠ L) and (strings of L ≠ L) then return
	
	script
		property Array : L
	end script
	
	tell the result's Array to set [x, xN] to [¬
		(its first item), the rest of it]
	
	tell minimum(xN) to if it < x then return it
	return x
end minimum

on lastIndexOf(x, L)
	local x, L
	
	if L = {} or (x is not in L) then return 0
	if L's class = text then set L to L's characters
	
	script
		property Array : reverse of L
	end script
	
	tell the result's Array to repeat with i from 1 to its length
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
---------------------------------------------------------------------------❮END❯