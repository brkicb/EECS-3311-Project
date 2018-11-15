note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	TRACKER

inherit
	ANY
		redefine
			out
		end

create {TRACKER_ACCESS}
	make

feature -- Attributes

	error_status: STATUS
	operation_list: LINKED_LIST[OPERATION]
	current_status: STRING
	state_number: INTEGER
	phases: LINKED_LIST[PHASE]
	sorted_phases: LINKED_LIST[PHASE]
	containers: LINKED_LIST[MATERIAL_CONTAINER]
	sorted_containers: LINKED_LIST[MATERIAL_CONTAINER]
	maximum_phase_radiation: VALUE
	maximum_container_radiation: VALUE
	-- checks
	undo_unavailable: BOOLEAN
	redo_unavailable: BOOLEAN
	has_undo_occurred: BOOLEAN
	has_redo_occurred: BOOLEAN
	has_undo_redo_occurred: BOOLEAN
	error_at_start: BOOLEAN
	no_new_tracker: BOOLEAN

feature -- Constructor
	make
		do
			create error_status.make
			create current_status.make_from_string (error_status.ok_status)
			create phases.make
			create sorted_phases.make
			create containers.make
			create sorted_containers.make
			undo_unavailable := false
			redo_unavailable := false
			has_undo_occurred := false
			has_redo_occurred := false
			has_undo_redo_occurred := false
			error_at_start := false
			no_new_tracker := true
			state_number := 0
			create operation_list.make
			-- this is so that if someone runs commands straight away without creating a new tracker first, then
			-- there won't be any errors
			operation_list.extend (create {NEW_TRACKER_COMMAND}.make (Current, create {VALUE}.make_from_int (0), create {VALUE}.make_from_int (0)))
			operation_list.finish
		end

feature -- Queries

	using_tracker: BOOLEAN
		local
			total: INTEGER
		do
			if phases.count > 0 then
				total := 0
				across
					phases as phase
				loop
					total := total + phase.item.containers.count
				end
				if total = 0 then
					Result := false
				else
					Result := true
				end
			elseif phases.count = 0 then
				Result := false
			end
		end

	is_phase_present(pid: STRING): BOOLEAN
		do
			Result := false
			across phases as phase
			loop
				if phase.item.phase_id ~ pid then
					Result := true
				end
			end
		end

	is_container_present(cid: STRING): BOOLEAN
		do
			Result := false
			across containers as container
			loop
				if container.item.container_id ~ cid then
					Result := true
				end
			end
		end

	is_container_in_phase (cid: STRING pid: STRING): BOOLEAN
		do
			if get_phase (pid).is_container_present (cid) then
				Result := true
			else
				Result := false
			end
		end

	is_phase_full(pid: STRING): BOOLEAN
		do
			Result := false
			across phases as phase
			loop
				if phase.item.phase_id ~ pid then
					if phase.item.full then
						Result := true
					end
				end
			end
		end

	is_phase_radiation_exceeded(cid: STRING pid: STRING): BOOLEAN
		do
			if get_phase (pid).radiation + get_container (cid).radiation_amount > maximum_phase_radiation then
				Result := true
			else
				Result := false
			end
		end

	is_container_radiation_exceeded(radiation: VALUE pid: STRING): BOOLEAN
		do
			Result := false
			across phases as phase
			loop
				if phase.item.phase_id ~ pid then
					if radiation > maximum_phase_radiation - phase.item.radiation then
						Result := true
					end
				end
			end
		end

	is_material_present(pid: STRING mid: INTEGER): BOOLEAN
		do
			Result := false
			across phases as phase
			loop
				if phase.item.materials_list.has (mid) then
					Result := true
				end
			end
		end

	is_material_exists(cid: STRING): BOOLEAN
		do
			Result := false
			across containers as container
			loop
				if container.item.container_id ~ cid then
					Result := true
				end
			end
		end

	is_material_present_in_phase(cid: STRING pid: STRING): BOOLEAN
		do
			if get_phase (pid).materials_list.has (get_container (cid).material_id) then
				Result := true
			else
				Result := false
			end
		end

	is_container_in_one_phase (cid: STRING): BOOLEAN
		require
			material_with_cid_exists: is_material_exists (cid)
		local
			count: INTEGER
			i: INTEGER
		do
			count := 0

			across phases as phase
			loop
				from
					i := phase.item.containers.lower
				until
					i > phase.item.containers.count
				loop
					if phase.item.containers.at (i).container_id ~ cid then
						count := count + 1
					end
					i := i + 1
				end
			end
			if count = 0 or count = 1 then
				Result := true
			else
				Result := false
			end
		end

	do_all_phases_handle_correct_material: BOOLEAN
		local
			i: INTEGER
		do
			Result := true
			across phases as phase
			loop
				from
					i := phase.item.containers.lower
				until
					i > phase.item.containers.count
				loop
					if not phase.item.materials_list.has (phase.item.containers.at (i).material_id) then
						Result := false
					end
					i := i + 1
				end
			end
		end

	get_phase_id (cid: STRING): STRING
		do
			Result := ""
			across phases as phase
			loop
				across phase.item.containers as container
				loop
					if container.item.container_id ~ cid then
						Result := Result + phase.item.phase_id
					end
				end
			end
		end

	get_phase_with_cid (cid: STRING): detachable PHASE
		do
			Result := Void
			across phases as phase
			loop
				across phase.item.containers as container
				loop
					if container.item.container_id ~ cid then
						Result := phase.item
					end
				end
			end
		end

	get_phase (pid: STRING): PHASE
		local
			p: detachable PHASE
		do
			across phases as phase
			loop
				if phase.item.phase_id ~ pid then
					p := phase.item
				end
			end
			check attached p as tp then
				Result := p
			end
		end

	get_container (cid: STRING): MATERIAL_CONTAINER
		local
			c: detachable MATERIAL_CONTAINER
		do
			across phases as phase
			loop
				across phase.item.containers as container
				loop
					if container.item.container_id ~ cid then
						c := container.item
					end
				end
			end
			check attached c as cc then
				Result := c
			end
		end

	get_current_status: STRING
		do
			Result := current_status
		end

	get_state_number: INTEGER
		do
			Result := state_number
		end

feature -- Commands

	increase_state_number
		do
			state_number := state_number + 1
		end

	set_maximum_phase_radiation(mpr: VALUE)
		do
			maximum_phase_radiation := mpr
		end

	set_maximum_container_radiation(mcr: VALUE)
		do
			maximum_container_radiation := mcr
		end

	set_current_status(s: STRING)
		do
			current_status := s
		end

	clear_operation_list
		do
			create operation_list.make
		end

	add_container(container: MATERIAL_CONTAINER pid: STRING)
		do
			across phases as phase
			loop
				if phase.item.phase_id ~ pid then
					phase.item.add_container (container)
				end
			end
		end

	add_container_element(container: MATERIAL_CONTAINER p: PHASE)
		do
			across phases as phase
			loop
				if phase.item.phase_id ~ p.phase_id then
					phase.item.add_container (container)
				end
			end
		end

	remove_phases_element (pid: STRING)
		local
			i: INTEGER
			new_list: LINKED_LIST[PHASE]
		do
			create new_list.make
			from
				i := phases.lower
			until
				i > phases.count
			loop
				if phases[i].phase_id /~ pid then
					new_list.extend (phases[i])
				end
				i := i + 1
			end
			clear_phases
			phases := new_list
		end

	remove_containers_element (cid: STRING)
		local
			i: INTEGER
			new_list: LINKED_LIST[MATERIAL_CONTAINER]
		do
			create new_list.make
			from
				i := containers.lower
			until
				i > containers.count
			loop
				if containers[i].container_id /~ cid then
					new_list.extend (containers[i])
				end
				i := i + 1
			end
			clear_containers
			containers := new_list
			across phases as phase
			loop
				phase.item.remove_container (cid)
			end
		end

feature -- Sorting Commands

	sort_phases
		local
			i : INTEGER
			j : INTEGER
			-- SORTED_TWO_WAY_LIST has a sort command that can easily sort the phase ids
			phase_id_list : SORTED_TWO_WAY_LIST[STRING]
		do
			clear_sorted_phases
			create phase_id_list.make
			from
				i := phases.lower
			until
				i > phases.count
			loop
				phase_id_list.extend (phases[i].phase_id)
				i := i + 1
			end
			phase_id_list.sort
			from
				i := 1
			until
				i > phase_id_list.count
			loop
				from
					j := phases.lower
				until
					j > phases.count
				loop
					if phase_id_list[i] ~ phases[j].phase_id then
						sorted_phases.extend (phases[j])
					end
					j := j + 1
				end
				i := i + 1
			end
		end

	sort_containers
		local
			i : INTEGER
			j : INTEGER
			-- SORTED_TWO_WAY_LIST has a sort command that can easily sort the container ids
			container_id_list : SORTED_TWO_WAY_LIST[STRING]
		do
			clear_sorted_containers
			create container_id_list.make
			from
				i := containers.lower
			until
				i > containers.count
			loop
				container_id_list.extend(containers[i].container_id)
				i := i + 1
			end
			container_id_list.sort
			-- now we can use the sorted container ids
			from
				i := 1
			until
				i > container_id_list.count
			loop
				from
					j := containers.lower
				until
					j > containers.count
				loop
					if container_id_list[i] ~ containers[j].container_id then
						sorted_containers.extend (containers[j])
					end
					j := j + 1
				end
				i := i + 1
			end
		end

	print_phases: STRING
		local
			phase: PHASE
		do
			sort_phases
			Result := ""
			across sorted_phases as sp
			loop
				phase := sp.item
				Result := Result + "    " + phase.phase_id + "->" + phase.phase_name + ":" +
					phase.max_containers.out + "," + phase.containers.count.out + "," + phase.radiation.out + "," + "{" + phase.mats + "}" + "%N"
			end
		end

	print_containers: STRING
		local
			container: MATERIAL_CONTAINER
		do
			sort_containers
			Result := ""
			across sorted_containers as sc
			loop
				container := sc.item
				Result := Result + "    " + container.container_id + "->" + get_phase_id (container.container_id) + "->" + container.material + "," +
					container.radiation_amount.out + "%N"
			end
		end

	clear_phases
		do
			phases.wipe_out
		end

	clear_sorted_phases
		do
			sorted_phases.wipe_out
		end

	clear_containers
		do
			containers.wipe_out
		end

	clear_sorted_containers
		do
			sorted_containers.wipe_out
		end

feature -- Model Commands

	new_tracker(max_phase_radiation: VALUE max_container_radiation: VALUE)
		local
			new_tracker_command: NEW_TRACKER_COMMAND
		do
			create new_tracker_command.make (Current, max_phase_radiation, max_container_radiation)
			new_tracker_command.execute
			if new_tracker_command.error_present then
				if no_new_tracker then
					error_at_start := true
				else
					error_at_start := false
				end
				if not (operation_list.before or operation_list.islast) then
					from

					until
						operation_list.islast
					loop
						operation_list.remove_right
					end
				end
				operation_list.extend (new_tracker_command)
				operation_list.finish
			else
				if no_new_tracker then
					no_new_tracker := false
				end
				clear_operation_list
				operation_list.extend (new_tracker_command)
				operation_list.finish
			end
			undo_unavailable := false
			redo_unavailable := false
			has_undo_redo_occurred := false
		end

	new_phase(phase_id: STRING phase_name: STRING max_containers: INTEGER materials_list: ARRAY[INTEGER])
		local
			new_phase_command: NEW_PHASE_COMMAND
		do
			create new_phase_command.make (Current, phase_id, phase_name, max_containers, materials_list)
			new_phase_command.execute
			if not (operation_list.before or operation_list.islast) then
				from

				until
					operation_list.islast
				loop
					operation_list.remove_right
				end
			end
			operation_list.extend (new_phase_command)
			operation_list.finish

			undo_unavailable := false
			redo_unavailable := false
			has_undo_redo_occurred := false
		end

	remove_phase(phase_id: STRING)
		local
			remove_phase_command: REMOVE_PHASE_COMMAND
		do
			create remove_phase_command.make (Current, phase_id)
			remove_phase_command.execute
			if not (operation_list.before or operation_list.islast) then
				from

				until
					operation_list.islast
				loop
					operation_list.remove_right
				end
			end
			operation_list.extend (remove_phase_command)
			operation_list.finish

			undo_unavailable := false
			redo_unavailable := false
			has_undo_redo_occurred := false
		end

	new_container(container_id: STRING container_tuple: TUPLE[material_id: INTEGER radiation_amount: VALUE] phase_id: STRING)
		local
			new_container_command: NEW_CONTAINER_COMMAND
		do
			create new_container_command.make (Current, container_id, container_tuple, phase_id)
			new_container_command.execute
			if not (operation_list.before or operation_list.islast) then
				from

				until
					operation_list.islast
				loop
					operation_list.remove_right
				end
			end
			operation_list.extend (new_container_command)
			operation_list.finish

			undo_unavailable := false
			redo_unavailable := false
			has_undo_redo_occurred := false
		end

	move_container(container_id: STRING phase_id_one: STRING phase_id_two: STRING)
		local
			move_container_command: MOVE_CONTAINER_COMMAND
		do
			create move_container_command.make (Current, container_id, phase_id_one, phase_id_two)
			move_container_command.execute
			if not (operation_list.before or operation_list.islast) then
				from

				until
					operation_list.islast
				loop
					operation_list.remove_right
				end
			end
			operation_list.extend (move_container_command)
			operation_list.finish

			undo_unavailable := false
			redo_unavailable := false
			has_undo_redo_occurred := false
		end

	remove_container(container_id: STRING)
		local
			remove_container_command: REMOVE_CONTAINER_COMMAND
		do
			create remove_container_command.make (Current, container_id)
			remove_container_command.execute
			if not (operation_list.before or operation_list.islast) then
				from

				until
					operation_list.islast
				loop
					operation_list.remove_right
				end
			end
			operation_list.extend (remove_container_command)
			operation_list.finish

			undo_unavailable := false
			redo_unavailable := false
			has_undo_redo_occurred := false
		end

	undo
		local
			operation: OPERATION
		do
			if operation_list.isfirst then
				undo_unavailable := true
				redo_unavailable := false
				has_undo_occurred := false
				has_redo_occurred := false
				has_undo_redo_occurred := false
				increase_state_number
			else
				operation := operation_list.item
				operation.undo
				operation_list.back
				undo_unavailable := false
				redo_unavailable := false
				has_undo_occurred := true
				has_redo_occurred := false
				has_undo_redo_occurred := true
			end
		end

	redo
		local
			operation: OPERATION
		do
			if operation_list.islast then
				undo_unavailable := false
				redo_unavailable := true
				has_undo_occurred := false
				has_redo_occurred := false
				has_undo_redo_occurred := false
				increase_state_number
			else
				operation_list.forth
				operation := operation_list.item
				operation.redo
				undo_unavailable := false
				redo_unavailable := false
				has_undo_occurred := false
				has_redo_occurred := true
				has_undo_redo_occurred := true
			end
		end

feature -- model operations

	default_update
			-- Perform update to the model state.
		do
		end

	reset
			-- Reset model state.
		do
			make
		end

feature
	out : STRING
		do
			if has_undo_redo_occurred then
				if no_new_tracker then
					if error_at_start then
						if operation_list.isfirst then
							if has_undo_occurred then
								Result := "  state " + state_number.out + " (to " + operation_list.item.tracker_state_number.out + ") "
							elseif has_redo_occurred then
								Result := "  state " + state_number.out + " (to " + (operation_list.item.tracker_state_number + 1).out + ") "
							else
								Result := "  state " + state_number.out + " (to " + (operation_list.item.tracker_state_number + 1).out + ") "
							end
						else
							Result := "  state " + state_number.out + " (to " + (operation_list.item.tracker_state_number + 1).out + ") "
						end
					else
						Result := "  state " + state_number.out + " (to " + (operation_list.item.tracker_state_number + 1).out + ") "
					end
				else
					Result := "  state " + state_number.out + " (to " + (operation_list.item.tracker_state_number + 1).out + ") "
				end
			else
				Result := "  state " + state_number.out + " "
			end
			if undo_unavailable then
				Result := Result + error_status.e19
			elseif redo_unavailable then
				Result := Result + error_status.e20
			elseif error_status.get_is_empty /= true then
				Result := Result + current_status
				if current_status ~ error_status.ok_status.out then
					Result := Result + "%N  " + "max_phase_radiation: " + maximum_phase_radiation.out + ", " + "max_container_radiation: " + maximum_container_radiation.out + "%N"
					Result := Result + "  " + "phases: pid->name:capacity,count,radiation%N"
					Result := Result + print_phases
					Result := Result + "  " + "containers: cid->pid->material,radioactivity%N"
					Result := Result + print_containers
					Result.remove (Result.count)
				end
			else
				Result := Result + error_status.ok_status.out + "%N"
				Result := Result + "  " + "max_phase_radiation: " + maximum_phase_radiation.out + ", " + "max_container_radiation: " + maximum_container_radiation.out + "%N"
				Result := Result + "  " + "phases: pid->name:capacity,count,radiation%N"
				Result := Result + print_phases
				Result := Result + "  " + "containers: cid->pid->material,radioactivity%N"
				Result := Result + print_containers
				Result.remove (Result.count)
			end
		end

invariant
	phase_radiation_not_greater_than_max_allowable: across phases as phase all phase.item.radiation <= maximum_phase_radiation end
	container_radiation_not_greater_than_max_allowable: across containers as container all container.item.radiation_amount <= maximum_container_radiation end
	container_amount_in_phase_not_greater_than_max_allowable: across phases as phase all phase.item.containers.count <= phase.item.max_containers end
	phase_does_not_handle_unexpected_material: do_all_phases_handle_correct_material
	container_resides_in_one_phase_only: across containers as container all is_container_in_one_phase (container.item.container_id) end

end
