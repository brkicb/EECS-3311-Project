note
	description: "Summary description for {MOVE_CONTAINER_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MOVE_CONTAINER_COMMAND

inherit
	OPERATION

create
	make

feature -- Attributes

	tracker: TRACKER
	container_id: STRING
	phase_id_one: STRING
	phase_id_two: STRING
	old_status: STRING
	is_empty: BOOLEAN
	moved_container: detachable MATERIAL_CONTAINER

feature -- Constructor

	make(trkr: TRACKER cid: STRING pid_one: STRING pid_two: STRING)
		do
			tracker := trkr
			container_id := cid
			phase_id_one := pid_one
			phase_id_two := pid_two
			error_present := false
			old_status := ""
			moved_container := Void
			is_empty := false
		end

--   possible errors
--   e15: this container identifier not in tracker
--   e16: source and target phase identifier must be different
--   e9: phase identifier not in the system
--   e17: this container identifier is not in the source phase
--   e11: this container will exceed phase capacity
--   e12: this container will exceed phase safe radiation
--   e13: phase does not expect this container material

	execute
		do
			tracker_state_number := tracker.get_state_number
			old_status := tracker.current_status
			is_empty := tracker.error_status.get_is_empty
			if not tracker.is_container_present (container_id) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e15)
			elseif phase_id_one ~ phase_id_two then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e16)
			elseif not tracker.is_phase_present (phase_id_one) or not tracker.is_phase_present (phase_id_two) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e9)
			elseif not tracker.is_container_in_phase (container_id, phase_id_one) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e17)
			elseif tracker.is_phase_full (phase_id_two) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e11)
			elseif tracker.is_phase_radiation_exceeded (container_id, phase_id_two) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e12)
			elseif not tracker.is_material_present_in_phase (container_id, phase_id_two) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e13)
			else
				error_present := false
				tracker.error_status.set_is_empty (true)
				tracker.set_current_status (tracker.error_status.ok_status)
				moved_container := tracker.get_container (container_id)
				tracker.get_phase (phase_id_one).remove_container (container_id)
				check attached moved_container as mc then
					tracker.get_phase (phase_id_two).add_container (mc)
				end
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
				tracker.get_phase (phase_id_two).remove_container (container_id)
				check attached moved_container as mc then
					tracker.get_phase (phase_id_one).add_container (mc)
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
