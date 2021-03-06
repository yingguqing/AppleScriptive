#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: MOVE WINDOW LEFT OR RIGHT
# nmxt: .applescript
# pDSC: Moves the currently focussed window left- or rightwards to align
#       itself with the contralateral edge of closest window in its path,
#       or to the edge of the screen if no windows remain. 

# plst: +|𝚫𝑥| : A number whose sign determines direction of travel,
#               left (-), right (+).

# rslt: -     : Window moves
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-08
# asmo: 2018-11-04
--------------------------------------------------------------------------------
use sys : application "System Events"
property _P : a reference to every process
property _V : a reference to (_P whose visible = true)
property _F : a reference to (_P whose frontmost = true)
property _D : a reference to scroll area 1 of process "Finder"
property _W : a reference to windows of _V
property displayPosition : a reference to _D's position
property displaySize : a reference to _D's size
property positions : a reference to _W's position
property sizes : a reference to _W's size
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run |𝚫𝑥|
	if |𝚫𝑥|'s class = script then set |𝚫𝑥| to [-1]
	set [|𝚫𝑥|] to |𝚫𝑥|
	
	script frontWindow
		property W : a reference to item 1 of windows of _F
		property position : a reference to W's position
		property size : a reference to W's size
		
		to move to {X, Y}
			set W's position to [X, Y]
		end move
	end script
	
	set [limit] to displaySize's contents
	
	tell the frontWindow to set [[|left|, Y], [width, height]] ¬
		to the contents of its [position, size]
	
	set |right| to |left| + width + 1
	set |left| to |left| - 1
	
	set Lx to contents of positions
	set Px to {-1} & oddIndexValues(ASObjC's flatten(Lx)) & {limit + 1}
	
	if (|𝚫𝑥| < 0) then
		if |left| ≤ 0 then return
		
		set Lx to contents of sizes
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
	
	move the frontWindow to {X, Y}
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
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


script ASObjC
	use framework "Foundation"
	
	property this : a reference to current application
	property parent : this
	property NSArray : a reference to NSArray of this
	property NSInsertionIndex : a reference to 1024
	property NSOrderedSet : a reference to NSOrderedSet of this
	property NSPredicate : a reference to NSPredicate of this
	property NSSet : a reference to NSSet of this
	
	to __NSArray__(L)
		local L
		
		if L's class = list then return NSArray's arrayWithArray:L
		
		L's allObjects()
	end __NSArray__
	
	to __NSSet__(L)
		local L
		
		NSOrderedSet's orderedSetWithArray:L
	end __NSSet__
	on unique(L)
		__NSSet__(L)
	end unique
	
	to __any__(NSObj)
		local NSObj
		
		NSArray's arrayWithObject:(NSObj's allObjects())
		item 1 of (result as list)
	end __any__
	
	on sortedSet(L)
		local L
		
		__NSArray__(L)'s sortedArrayUsingSelector:("compare:")
		__NSSet__(result)
	end sortedSet
	
	on unionOfArrays(L)
		local L
		
		__NSArray__(L)'s valueForKeyPath:"@unionOfArrays.self"
		result as list
	end unionOfArrays
	
	to flatten(L as list)
		local L
		
		if (count each list in L) = 0 then return L
		
		flatten(unionOfArrays(L))
	end flatten
	
	on greatestValueLessThan:k FromSortedList:L
		local L, k
		
		__NSArray__(L)'s filteredArrayUsingPredicate:(NSPredicate's ¬
			predicateWithFormat:"SELF < %@" argumentArray:{k})
		
		result's last item as integer
	end greatestValueLessThan:FromSortedList:
	
	on smallestValueGreaterThan:k FromSortedList:L
		local L, k
		
		__NSArray__(L)'s filteredArrayUsingPredicate:(NSPredicate's ¬
			predicateWithFormat:"SELF > %@" argumentArray:{k})
		
		result's first item as integer
	end smallestValueGreaterThan:FromSortedList:
end script
---------------------------------------------------------------------------❮END❯