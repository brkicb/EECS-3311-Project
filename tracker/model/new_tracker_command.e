note
	description: "Summary description for {NEW_TRACKER_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_TRACKER_COMMAND

inherit
	OPERATION

create
	make

feature -- Attributes

	tracker: TRACKER
	max_phase_radiation: VALUE
	max_container_radiation: VALUE
	old_max_phase_radiation: VALUE
	old_max_container_radiation: VALUE
	old_status: STRING
	is_empty: BOOLEAN

feature -- Constructor

	make (trkr: TRACKER mpr: VALUE mcr: VALUE)
		do
			tracker := trkr
			max_phase_radiation := mpr
			max_container_radiation := mcr
			error_present := false
			is_empty := false
			old_status := ""
		end

--   possible errors
--   e1: current tracker is in use
--   e2: max phase radiation must be non-negative value
--   e3: max container radiation must be non-negative value
--   e4: max container must not be more than max phase radiation

	execute
		do
			tracker_state_number := tracker.get_state_number
			old_status := tracker.current_status
			is_empty := tracker.error_status.get_is_empty
			if tracker.using_tracker then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e1)
			elseif max_phase_radiation < 0.00 then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e2)
			elseif max_container_radiation < 0.00 then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e3)
			elseif max_phase_radiation < max_container_radiation then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e4)
			else
				error_present := false
				tracker.error_status.set_is_empty (true)
				tracker.set_current_status (tracker.error_status.ok_status)
				old_max_phase_radiation := tracker.maximum_phase_radiation
				tracker.set_maximum_phase_radiation (max_phase_radiation)
				old_max_container_radiation := tracker.maximum_container_radiation
				tracker.set_maximum_container_radiation (max_container_radiation)
			end
			tracker.increase_state_number
		end

	undo
		do
			if error_present then
				tracker.set_current_status (old_status)
				tracker.error_status.set_is_empty (is_empty)
			else
				tracker.set_current_status (old_status)
				tracker.error_status.set_is_empty (is_empty)
				tracker.set_maximum_phase_radiation (old_max_phase_radiation)
				tracker.set_maximum_container_radiation (old_max_container_radiation)
			end
			tracker.increase_state_number
		end

	redo
		local
			old_tracker_state_number: INTEGER
		do
			old_tracker_state_number := tracker_state_number
			execute
			tracker_state_number := old_tracker_state_number
		end

end
