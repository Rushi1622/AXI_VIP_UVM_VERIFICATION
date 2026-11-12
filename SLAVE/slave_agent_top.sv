class slave_agent_top extends uvm_env;
	`uvm_component_utils(slave_agent_top)
	
	slave_agent_config sa_cfg;
	slave_agent s_agth;

	function new(string name = "slave_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",sa_cfg))
				`uvm_fatal(get_type_name(),"get method are failed from agent top ")
			
			s_agth = slave_agent::type_id::create("s_agth",this);
	endfunction

endclass
