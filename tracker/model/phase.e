note
	description: "Summary description for {PHASE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PHASE

create
	make

feature -- Attributes

	phase_id: STRING
	phase_name: STRING
	max_containers: INTEGER
	materials_list: ARRAY[INTEGER]
	materials: ARRAY[STRING]
	mats: STRING
	containers: LINKED_LIST[MATERIAL_CONTAINER]

feature -- Constructor

	make(pid: STRING pn: STRING max: INTEGER mat_list: ARRAY[INTEGER])
		local
			i: INTEGER
		do
			phase_id := pid
			phase_name := pn
			max_containers := max
			materials_list := mat_list
			create containers.make
			create materials.make_empty
			from
				i := materials_list.lower
			until
				i > materials_list.upper
			loop
				if materials_list[i] = 1 then
					materials.force ("glass",i)
				elseif materials_list[i] = 2 then
					materials.force ("metal",i)
				elseif materials_list[i] = 3 then
					materials.force ("plastic",i)
				elseif materials_list[i] = 4 then
					materials.force ("liquid",i)
				end
				i := i + 1
			end
			create mats.make_from_string("")
			from
				i := materials.lower
			until
				i > materials.upper
			loop
				if i = materials.upper then
					mats.append(materials[i])
				else
					mats.append(materials[i] + ",")
				end
				i := i + 1
			end
		end

feature -- Queries

	radiation: VALUE
		local
			total_radiation: VALUE
		do
			create total_radiation.make_from_int (0)
			across containers
				 as container
			loop
				total_radiation := total_radiation.plus (container.item.radiation_amount)
			end
			Result := total_radiation
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

	full: BOOLEAN
		do
			Result := max_containers = containers.count
		end

feature -- Commands

	add_container(new_container: MATERIAL_CONTAINER)
		do
			containers.extend (new_container)
		end

	remove_container(cid: STRING)
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
		end

	clear_containers
		do
			containers.wipe_out
		end

invariant
	max_containers_not_exceeded: containers.count <= max_containers

end
