note
	description: "Summary description for {STATUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STATUS

create
	make

feature -- Attributes

	is_empty: BOOLEAN
	ok_status: STRING = "ok"
	e1: STRING = "e1: current tracker is in use"
	e2: STRING = "e2: max phase radiation must be non-negative value"
	e3: STRING = "e3: max container radiation must be non-negative value"
	e4: STRING = "e4: max container must not be more than max phase radiation"
	e5: STRING = "e5: identifiers/names must start with A-Z, a-z or 0..9"
	e6: STRING = "e6: phase identifier already exists"
	e7: STRING = "e7: phase capacity must be a positive integer"
	e8: STRING = "e8: there must be at least one expected material for this phase"
	e9: STRING = "e9: phase identifier not in the system"
	e10: STRING = "e10: this container identifier already in tracker"
	e11: STRING = "e11: this container will exceed phase capacity"
	e12: STRING = "e12: this container will exceed phase safe radiation"
	e13: STRING = "e13: phase does not expect this container material"
	e14: STRING = "e14: container radiation capacity exceeded"
	e15: STRING = "e15: this container identifier not in tracker"
	e16: STRING = "e16: source and target phase identifier must be different"
	e17: STRING = "e17: this container identifier is not in the source phase"
	e18: STRING = "e18: this container radiation must not be negative"
	e19: STRING = "e19: there is no more to undo"
	e20: STRING = "e20: there is no more to redo"

feature
	make
		do
			is_empty := true
		end

feature -- Commands

	set_is_empty(e:BOOLEAN)
		do
			is_empty := e
		end

	get_is_empty: BOOLEAN
		do
			Result := is_empty
		end

end
