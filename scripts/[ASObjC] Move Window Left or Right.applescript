#!/usr/bin/osascript
--------------------------------------------------------------------------------
###[ASObjC] Move Window Left or Right.applescript
#
#	Moves the currently focussed window left- or rightwards to align
#	itself with the contralateral edge of closest window in its path,
#	or to the edge of the screen if no windows remain. 
#
#  Input:
#	％|𝚫𝑥|％			A number whose sign determines the direction
#				of travel: left (-), right (+).
#
#  Result:
#	-			Window moves
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-08-08
#  Date Last Edited: 2018-09-05
--------------------------------------------------------------------------------
use sys : application "System Events"
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run |𝚫𝑥|
	if |𝚫𝑥|'s class = script then set |𝚫𝑥| to [-1]
	set [|𝚫𝑥|] to |𝚫𝑥|
	
	script visibleWindows
		property _P : a reference to every process
		property _V : a reference to (_P whose visible = true)
		property _F : a reference to (_P whose frontmost = true)
		property _D : a reference to scroll area 1 of process "Finder"
		property _W : a reference to windows of _V
		property displayPosition : _D's position
		property displaySize : _D's size
		property positions : a reference to _W's position
		property sizes : a reference to _W's size
		
		script frontWindow
			property W : a reference to item 1 of windows of _F
			property position : a reference to W's position
			property size : a reference to W's size
			
			to move to {X, Y}
				set W's position to [X, Y]
			end move
		end script
	end script
	
	set [limit] to visibleWindows's displaySize
	
	tell the visibleWindows's frontWindow to set ¬
		[[|left|, Y], [width, height]] to ¬
		contents of its [position, size]
	
	set |right| to |left| + width + 1
	set |left| to |left| - 1
	
	set Lx to contents of visibleWindows's positions
	set Px to {-1} & oddIndexValues(ASObjC's flatten(Lx)) & {limit + 1}
	
	if (|𝚫𝑥| < 0) then
		if |left| ≤ 0 then return
		
		set Lx to contents of visibleWindows's sizes
		set Sx to {0} & oddIndexValues(ASObjC's flatten(Lx)) & {0}
		
		set rightEdges to ASObjC's sortedSet(add(Px, Sx))
		ASObjC's greatestValueLessThan:(|left|) ¬
			FromSortedList:rightEdges
		
		set X to result + 1
	else
		if |right| ≥ limit then return
		
		set leftEdges to ASObjC's sortedSet(Px)
		ASObjC's smallestValueGreaterThan:(|right|) ¬
			FromSortedList:leftEdges
		
		set X to result - width - 1
	end if
	
	tell visibleWindows's frontWindow to move to {X, Y}
end run
--------------------------------------------------------------------------------
###LIST MANIPULATION HANDLERS
#
#
to add(a as list, b as list)
	script arrays
		property one : a
		property two : b
		property sum : {}
	end script
	
	tell the arrays to repeat until its one = {} and its two = {}
		if its one = {} then set its one to {0}
		if its two = {} then set its two to {0}
		
		set [[xA], [xB]] to its [one, two]
		set end of its sum to xA + xB
		set [its one, its two] to [rest of its one, rest of its two]
	end repeat
	
	sum of arrays
end add

on oddIndexValues(L as list)
	local L
	
	if L = {} then return {}
	
	script
		property array : L
	end script
	
	tell the result's array to repeat with i from 2 to its length by 2
		set its item i to null
	end repeat
	
	L's numbers
end oddIndexValues
--------------------------------------------------------------------------------
###ASObjC SCRIPT OBJECT AND HANDLERS
#
#
script ASObjC
	use framework "Foundation"
	
	property this : a reference to current application
	property parent : this
	property NSArray : a reference to NSArray of this
	property NSInsertionIndex : a reference to 1024
	property NSOrderedSet : a reference to NSOrderedSet of this
	property NSPredicate : a reference to NSPredicate of this
	property NSSet : a reference to NSSet of this
	
	on |NSArray|(L)
		local L
		
		if L's class = list then return NSArray's arrayWithArray:L
		
		L's allObjects()
	end |NSArray|
	
	on |NSSet|(L)
		local L
		
		NSOrderedSet's orderedSetWithArray:L
	end |NSSet|
	on unique(L)
		|NSSet|(L)
	end unique
	
	on |Any|(NSObj)
		local NSObj
		
		NSArray's arrayWithObject:(NSObj's allObjects())
		item 1 of (result as list)
	end |Any|
	
	on sortedSet(L)
		local L
		
		|NSArray|(L)'s sortedArrayUsingSelector:("compare:")
		|NSSet|(result)
	end sortedSet
	
	on unionOfArrays(L)
		local L
		
		|NSArray|(L)'s valueForKeyPath:"@unionOfArrays.self"
		result as list
	end unionOfArrays
	
	to flatten(L as list)
		local L
		
		if (count each list in L) = 0 then return L
		
		flatten(unionOfArrays(L))
	end flatten
	
	on greatestValueLessThan:k FromSortedList:L
		local L, k
		
		|NSArray|(L)'s filteredArrayUsingPredicate:(NSPredicate's ¬
			predicateWithFormat:"SELF < %@" argumentArray:{k})
		
		result's last item as integer
	end greatestValueLessThan:FromSortedList:
	
	on smallestValueGreaterThan:k FromSortedList:L
		local L, k
		
		|NSArray|(L)'s filteredArrayUsingPredicate:(NSPredicate's ¬
			predicateWithFormat:"SELF > %@" argumentArray:{k})
		
		result's first item as integer
	end smallestValueGreaterThan:FromSortedList:
end script
---------------------------------------------------------------------------❮END❯