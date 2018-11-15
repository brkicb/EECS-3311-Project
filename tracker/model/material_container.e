note
	description: "Summary description for {MATERIAL_CONTAINER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MATERIAL_CONTAINER

create
	make

feature -- Attributes

	container_id: STRING
	material_id: INTEGER
	material: STRING
	radiation_amount: VALUE

feature -- Constructor

	make(cid: STRING mid: INTEGER radiation: VALUE)
		do
			container_id := cid
			material_id := mid
			radiation_amount := radiation
			material := ""
		end

feature -- Command

	set_material(s: STRING)
		do
			material := s
		end

end
