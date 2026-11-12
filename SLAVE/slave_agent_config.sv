class slave_agent_config extends uvm_object;
	`uvm_object_utils(slave_agent_config)
	
	virtual axi_interface s_vif;
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	
	function new(string name = "slave_agent_config");
		super.new(name);
	endfunction
endclass

