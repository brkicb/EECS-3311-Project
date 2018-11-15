note
	description: "Summary description for {NEW_PHASE_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_PHASE_COMMAND

inherit
	OPERATION

create
	make

feature -- Attributes

	tracker: TRACKER
	phase_id: STRING
	phase_name: STRING
	max_containers: INTEGER
	materials_list: ARRAY[INTEGER]
	old_status: STRING
	is_empty: BOOLEAN

feature -- Constructor

	make(trkr: TRACKER pid: STRING p_name: STRING max: INTEGER mat_list: ARRAY[INTEGER])
		do
			tracker := trkr
			phase_id := pid
			phase_name := p_name
			max_containers := max
			materials_list := mat_list
			error_present := false
			old_status := ""
			is_empty := false
		end

--   possible errors
--   e1: current tracker is in use
--   e5: identifiers/names must start with A-Z, a-z or 0..9
--   e6: phase identifier already exists
--   e5: identifiers/names must start with A-Z, a-z or 0..9
--   e7: phase capacity must be a positive integer
--   e8: there must be at least one expected material for this phase

	execute
		local
			phase: PHASE
		do
			tracker_state_number := tracker.get_state_number
			old_status := tracker.current_status
			is_empty := tracker.error_status.get_is_empty
			if tracker.using_tracker then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e1)
			elseif phase_id.is_empty or not (('a' <= phase_id.at (1) and phase_id.at (1) <= 'z') or ('A' <= phase_id.at (1) and phase_id.at (1) <= 'Z') or ('0' <= phase_id.at (1) and phase_id.at (1) <= '9')) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e5)
			elseif across tracker.phases as tp some tp.item.phase_id ~ phase_id end then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e6)
			elseif phase_id.is_empty or not (('a' <= phase_name.at (1) and phase_name.at (1) <= 'z') or ('A' <= phase_name.at (1) and phase_name.at (1) <= 'Z') or ('0' <= phase_name.at (1) and phase_name.at (1) <= '9')) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e5)
			elseif max_containers <= 0 then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e7)
			elseif materials_list.count = 0 then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e8)
			else
				error_present := false
				tracker.error_status.set_is_empty (true)
				tracker.set_current_status (tracker.error_status.ok_status)
				create phase.make (phase_id, phase_name, max_containers, materials_list)
				tracker.phases.extend (phase)
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
				tracker.remove_phases_element (phase_id)
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
