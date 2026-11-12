class axi_env_config extends uvm_object;
	`uvm_object_utils(axi_env_config)
	
	bit has_master_agent = 1;
	bit has_slave_agent = 1;
	bit has_scoreboard = 1;
	
	bit no_of_master_agent = 1;
	bit no_of_slave_agent = 1;	
	function new(string name = "axi_env_config");
		super.new(name);
	endfunction
endclass

