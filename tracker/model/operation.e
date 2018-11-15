note
	description: "Summary description for {OPERATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	OPERATION

feature -- Attributes

	state_number: INTEGER
	error_present: BOOLEAN
	tracker_state_number: INTEGER

feature

	execute
		deferred
		end

	undo
		deferred
		end

	redo
		deferred
		end

end
