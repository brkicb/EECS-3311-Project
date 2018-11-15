note
	description: "Summary description for {REMOVE_CONTAINER_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REMOVE_CONTAINER_COMMAND

inherit
	OPERATION

create
	make

feature -- Attributes

	tracker: TRACKER
	container_id: STRING
	old_status: STRING
	is_empty: BOOLEAN
	removed_container: detachable MATERIAL_CONTAINER
	phase: detachable PHASE

feature -- Constructor

	make(trkr: TRACKER cid: STRING)
		do
			tracker := trkr
			container_id := cid
			error_present := false
			is_empty := false
			old_status := ""
			removed_container := Void
			phase := Void
		end

--   possible error
--   e15: this container identifier not in tracker

	execute
		do
			tracker_state_number := tracker.get_state_number
			old_status := tracker.current_status
			is_empty := tracker.error_status.get_is_empty
			if not tracker.is_container_present (container_id) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e15)
			else
				error_present := false
				tracker.error_status.set_is_empty (true)
				tracker.set_current_status (tracker.error_status.ok_status)
				removed_container := tracker.get_container (container_id)
				phase := tracker.get_phase_with_cid (container_id)
				tracker.remove_containers_element (container_id)
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
				check attached removed_container as rc then
					check attached phase as p then
						tracker.add_container_element (rc, p)
						tracker.containers.extend (rc)
					end
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
