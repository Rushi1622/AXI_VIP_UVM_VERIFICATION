class axi_env extends uvm_env;
	`uvm_component_utils(axi_env)
	
	axi_env_config ae_cfg;
	master_agent_top ma_top;
	slave_agent_top sa_top;
	axi_sb sbh;

	function new(string name = "axi_env",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",ae_cfg))
				`uvm_fatal(get_type_name(),"get method are failed from env ")
			if(ae_cfg.has_master_agent)
			begin
				ma_top = master_agent_top::type_id::create("ma_top",this);
			end

			if(ae_cfg.has_slave_agent)
			begin
				sa_top = slave_agent_top::type_id::create("sa_top",this);
			end
			if(ae_cfg.has_scoreboard)
			begin
				sbh = axi_sb::type_id::create("sbh",this);
			end

	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		ma_top.m_agth.mmonh.mast2sb.connect(this.sbh.master2sb.analysis_export);
		sa_top.s_agth.smonh.slave2sb.connect(this.sbh.slave2sb.analysis_export);
	
	endfunction	
endclass

