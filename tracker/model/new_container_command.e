note
	description: "Summary description for {NEW_CONTAINER_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_CONTAINER_COMMAND

inherit
	OPERATION

create
	make

feature -- Attributes

	tracker: TRACKER
	container_id: STRING
	container_tuple: TUPLE[m_id: INTEGER rad: VALUE]
	material_id: INTEGER
	radiation_amount: VALUE
	phase_id: STRING
	old_status: STRING
	is_empty: BOOLEAN

feature -- Constructor

	make(trkr: TRACKER cid: STRING con_t: TUPLE[mid: INTEGER radiation: VALUE] pid: STRING)
		do
			tracker := trkr
			container_tuple := con_t
			container_id := cid
			material_id := con_t.mid
			radiation_amount := con_t.radiation
			phase_id := pid
			error_present := false
			old_status := ""
			is_empty := false
		end

--   possible errors
--   e5: identifiers/names must start with A-Z, a-z or 0..9
--   e10: this container identifier already in tracker
--   e5: identifiers/names must start with A-Z, a-z or 0..9
--   e9: phase identifier not in the system
--   e18: this container radiation must not be negative
--   e11: this container will exceed phase capacity
--   e14: container radiation capacity exceeded
--   e12: this container will exceed phase safe radiation
--   e13: phase does not expect this container material

	execute
		local
			container: MATERIAL_CONTAINER
		do
			tracker_state_number := tracker.get_state_number
			old_status := tracker.current_status
			is_empty := tracker.error_status.get_is_empty
			if phase_id.is_empty or not (('a' <= container_id.at (1) and container_id.at (1) <= 'z') or ('A' <= container_id.at (1) and container_id.at (1) <= 'Z') or ('0' <= container_id.at (1) and container_id.at (1) <= '9')) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e5)
			elseif across tracker.phases as tp some tp.item.is_container_present (container_id) end then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e10)
			elseif phase_id.is_empty or not (('a' <= phase_id.at (1) and phase_id.at (1) <= 'z') or ('A' <= phase_id.at (1) and phase_id.at (1) <= 'Z') or ('0' <= phase_id.at (1) and phase_id.at (1) <= '9')) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e5)
			elseif not tracker.is_phase_present (phase_id) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e9)
			elseif radiation_amount < 0.0 then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e18)
			elseif tracker.is_phase_full (phase_id) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e11)
			elseif radiation_amount > tracker.maximum_container_radiation then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e14)
			elseif tracker.is_container_radiation_exceeded (radiation_amount, phase_id) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e12)
			elseif not tracker.is_material_present (phase_id, material_id) then
				error_present := true
				tracker.error_status.set_is_empty (false)
				tracker.set_current_status (tracker.error_status.e13)
			else
				error_present := false
				tracker.error_status.set_is_empty (true)
				tracker.set_current_status (tracker.error_status.ok_status)
				create container.make (container_id, material_id, radiation_amount)
				if material_id = 1 then
					container.set_material ("glass")
				elseif material_id = 2 then
					container.set_material ("metal")
				elseif material_id = 3 then
					container.set_material ("plastic")
				elseif material_id = 4 then
					container.set_material ("liquid")
				end
				tracker.add_container (container, phase_id)
				tracker.containers.extend (container)
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
				tracker.remove_containers_element (container_id)
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
