class axi_test_base extends uvm_test;
	`uvm_component_utils(axi_test_base)

	axi_env_config ae_cfg;
	master_agent_config ma_cfg;
	slave_agent_config sa_cfg;
	axi_env envh;
	

	function new (string name = "axi_test_base",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			ae_cfg = axi_env_config::type_id::create("ae_cfg");

			if(ae_cfg.has_master_agent)
			begin
				ma_cfg = master_agent_config::type_id::create("ma_cfg");
				if(!uvm_config_db #(virtual axi_interface)::get(this,"","axi_interface",ma_cfg.m_vif))
					`uvm_fatal(get_type_name(),"get method of master interface are failed")

				uvm_config_db #(master_agent_config)::set(this,"*","master_agent_config",ma_cfg);
			end

			if(ae_cfg.has_slave_agent)
			begin
				sa_cfg = slave_agent_config::type_id::create("sa_cfg");
				if(!uvm_config_db #(virtual axi_interface)::get(this,"","axi_interface",sa_cfg.s_vif))
					`uvm_fatal(get_type_name(),"get method of slave interface are failed")

				uvm_config_db #(slave_agent_config)::set(this,"*","slave_agent_config",sa_cfg);
			end
			
			uvm_config_db #(axi_env_config)::set(this,"*","axi_env_config",ae_cfg);	
			envh = axi_env::type_id::create("envh",this);	
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
			uvm_top.print_topology();
	endfunction
endclass

class fixed_burst_test extends axi_test_base;
	`uvm_component_utils(fixed_burst_test)
	fixed_burst seq;
	function new (string name = "fixed_burst_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq = fixed_burst::type_id::create("seq");
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq.start(envh.ma_top.m_agth.mseqrh);
			#1005000;
		phase.drop_objection(this);
	endtask
endclass

class incr_burst_test extends axi_test_base;
	`uvm_component_utils(incr_burst_test)
	incr_burst seq;
	function new (string name = "incr_burst_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq = incr_burst::type_id::create("seq");
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq.start(envh.ma_top.m_agth.mseqrh);
			#1005000;
		phase.drop_objection(this);
	endtask
endclass


class wrap_burst_test extends axi_test_base;
	`uvm_component_utils(wrap_burst_test)
	wrap_burst seq;
	function new (string name = "wrap_burst_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq = wrap_burst::type_id::create("seq");
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq.start(envh.ma_top.m_agth.mseqrh);
			#1005000;
		phase.drop_objection(this);
	endtask
endclass

class unaligned_addr_test extends axi_test_base;
	`uvm_component_utils(unaligned_addr_test)
	unaligned_addr seq;
	function new (string name = "unaligned_addr",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq = unaligned_addr::type_id::create("seq");
	endfunction
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq.start(envh.ma_top.m_agth.mseqrh);
			#1005000;
		phase.drop_objection(this);
	endtask
endclass







