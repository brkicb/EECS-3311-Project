note
	description: "Summary description for {REMOVE_PHASE_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REMOVE_PHASE_COMMAND

inherit
	OPERATION

create
	make

feature -- Attributes

	tracker: TRACKER
	phase_id: STRING
	old_status: STRING
	is_empty: BOOLEAN
	old_phase: detachable PHASE
	removed_phase: detachable PHASE

feature -- Constructor

	make(trkr: TRACKER pid: STRING)
		do
			tracker := trkr
			phase_id := pid
			error_present := false
			is_empty := false
			old_status := ""
			old_phase := Void
			removed_phase := Void
		end

--   possible errors
--   e1: current tracker is in use
--   e9: phase identifier not in the system

	execute
		do
			tracker_state_number := tracker.get_state_number
			old_status := tracker.current_status
			is_empty := tracker.error_status.get_is_empty
			if tracker.using_tracker then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e1)
			elseif not tracker.is_phase_present (phase_id) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e9)
			else
				error_present := false
				tracker.error_status.set_is_empty (true)
				tracker.set_current_status (tracker.error_status.ok_status)
				removed_phase := tracker.get_phase (phase_id)
				old_phase := tracker.get_phase (phase_id)
				tracker.remove_phases_element (phase_id)
			end
			tracker.increase_state_number
		end

	undo
		do
			if error_present then
				tracker.increase_state_number
				tracker.set_current_status (old_status)
				tracker.error_status.set_is_empty (is_empty)
			else
				tracker.increase_state_number
				tracker.set_current_status (old_status)
				tracker.error_status.set_is_empty (is_empty)
				check attached removed_phase as rp then
					tracker.phases.extend (rp)
				end
			end
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
