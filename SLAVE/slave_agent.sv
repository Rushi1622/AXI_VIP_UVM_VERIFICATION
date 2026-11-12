class slave_agent extends uvm_agent;
	`uvm_component_utils(slave_agent)

	slave_agent_config sa_cfg;
	slave_driver sdrvh;
	slave_monitor smonh;
	slave_sequencer sseqrh;
	
	function new(string name = "slave_agent",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",sa_cfg))
				`uvm_fatal(get_type_name(),"Get method are failed from agent")
			smonh = slave_monitor::type_id::create("smonh",this);
			if(sa_cfg.is_active == UVM_ACTIVE)
				begin
					sdrvh = slave_driver::type_id::create("sdrvh",this);
					sseqrh = slave_sequencer::type_id::create("sseqrh",this);	
				end
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(sa_cfg.is_active == UVM_ACTIVE)
			sdrvh.seq_item_port.connect(sseqrh.seq_item_export);
	endfunction
endclass

