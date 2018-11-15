note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_PHASE
inherit
	ETF_NEW_PHASE_INTERFACE
		redefine new_phase end
create
	make
feature -- command
	new_phase(pid: STRING ; phase_name: STRING ; capacity: INTEGER_64 ; expected_materials: ARRAY[INTEGER_64])
		require else
			new_phase_precond(pid, phase_name, capacity, expected_materials)
		local
			materials_list: SEQ[INTEGER]
    	do
    		create materials_list.make_empty
    		across expected_materials as em loop materials_list.append (em.item.as_integer_32) end
			model.new_phase (pid, phase_name, capacity.as_integer_32, materials_list.as_array)
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
