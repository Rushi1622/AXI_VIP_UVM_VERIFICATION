class slave_monitor extends uvm_monitor;
	`uvm_component_utils(slave_monitor)
	
	virtual axi_interface.SLAVE_MON_MP s_vif;
	slave_agent_config sa_cfg;
	
	uvm_analysis_port #(master_trans) slave2sb;
	master_trans xtn;
	semaphore w_address = new(1);//write address channel
	semaphore w_data = new(1);//write data channel
	semaphore r_address = new(1);//read address channel
	semaphore r_data = new(1);//read data channel
	semaphore w_rsp = new(1);//write response channel

	semaphore wadd2data = new();//write address channel to write data channel
	semaphore wadd2rsp = new();//read address channel to read data channel
	semaphore radd2data = new();//write address channel to write response channel

	master_trans q1[$],q2[$],q3[$];

	function new(string name = "slave_monitor",uvm_component parent);
		super.new(name,parent);
		slave2sb = new("slave2sb",this);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",sa_cfg))
				`uvm_fatal(get_type_name(),"get method are failed from slave monitor")
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
			s_vif = sa_cfg.s_vif;
	endfunction

		task run_phase(uvm_phase phase);
		forever
			begin
				xtn = master_trans::type_id::create("xtn");
				collect_data();
				$display("*****************************************************************");
				//`uvm_info(get_type_name(),$sformatf("SLAVE MONITOR CLASS TRANSACTION SIGNALS :- %s",xtn.sprint()),UVM_LOW)
				$display("*****************************************************************");
			end
	endtask

	task collect_data();
		fork
			begin 
				//write address channel signal
				w_address.get(1);
				write_address();
				w_address.put(1);
				wadd2data.put(1);
			end
			begin
				//write data channel signal
				w_data.get(1);
				wadd2data.get(1);
				write_data(q1.pop_front());
				w_data.put(1);
				wadd2rsp.put(1);
			end
			begin
				//write response channel signal
				w_rsp.get(1);
				wadd2rsp.get(1);
				write_resp(q2.pop_front());
				w_rsp.put(1);
			end
			begin
				//read address channel signal
				r_address.get(1);
				read_address();
				r_address.put(1);
				radd2data.put(1);
			end
			begin
				//read data channel signal
				
				r_data.get(1);	
				radd2data.get(1);
				read_data(q3.pop_front());
				r_data.put(1);
				
			end
		join_any
	endtask

	//write address channel signal
	task write_address();
		@(s_vif.slave_mon_cb);

		wait(s_vif.slave_mon_cb.AWREADY && s_vif.slave_mon_cb.AWVALID);
		xtn.AWID=s_vif.slave_mon_cb.AWID;
		xtn.AWADDR=s_vif.slave_mon_cb.AWADDR;
		xtn.AWSIZE=s_vif.slave_mon_cb.AWSIZE;
		xtn.AWLEN=s_vif.slave_mon_cb.AWLEN;
		xtn.AWBURST=s_vif.slave_mon_cb.AWBURST;
		xtn.AWVALID=s_vif.slave_mon_cb.AWVALID;
		xtn.AWREADY=s_vif.slave_mon_cb.AWREADY;
		q1.push_back(xtn);
		//slave2sb.write(xtn);
		@(s_vif.slave_mon_cb);
	endtask

	//write data channel signal
	task write_data(master_trans xtn);
		xtn.WDATA = new[xtn.AWLEN +1];
		xtn.WSTRB = new[xtn.AWLEN +1];
		foreach(xtn.WDATA[i])
		begin
			@(s_vif.slave_mon_cb);	
			wait(s_vif.slave_mon_cb.WREADY && s_vif.slave_mon_cb.WVALID);
			xtn.WID=s_vif.slave_mon_cb.WID;
			xtn.WSTRB[i] =s_vif.slave_mon_cb.WSTRB;
			if(xtn.WSTRB[i] == 4'b0001)
				xtn.WDATA[i] = {s_vif.slave_mon_cb.WDATA[7:0]};
			else if(xtn.WSTRB[i] == 4'b0010)
				xtn.WDATA[i] = {s_vif.slave_mon_cb.WDATA[15:8]};
			else if(xtn.WSTRB[i] == 4'b0100)
				xtn.WDATA[i] = {s_vif.slave_mon_cb.WDATA[23:16]};
			else if(xtn.WSTRB[i] == 4'b1000)
				xtn.WDATA[i] = {s_vif.slave_mon_cb.WDATA[31:24]};
			else if(xtn.WSTRB[i] == 4'b0011)
				xtn.WDATA[i] = {s_vif.slave_mon_cb.WDATA[15:0]};
			else if(xtn.WSTRB[i] == 4'b1100)
				xtn.WDATA[i] = {s_vif.slave_mon_cb.WDATA[31:16]};
			else if(xtn.WSTRB[i] == 4'b1111)
				xtn.WDATA[i] = {s_vif.slave_mon_cb.WDATA[31:0]};

			xtn.WLAST=s_vif.slave_mon_cb.WLAST;
			xtn.WVALID=s_vif.slave_mon_cb.WVALID;
			xtn.WREADY=s_vif.slave_mon_cb.WREADY;
			q2.push_back(xtn);
			//slave2sb.write(xtn);
			@(s_vif.slave_mon_cb);
		end
	endtask	

	//write response channel signal
	task write_resp(master_trans xtn);
		@(s_vif.slave_mon_cb);
		wait(s_vif.slave_mon_cb.BREADY && s_vif.slave_mon_cb.BVALID);
			xtn.BID=s_vif.slave_mon_cb.BID;
			xtn.BRESP=s_vif.slave_mon_cb.BRESP;
			xtn.BVALID=s_vif.slave_mon_cb.BVALID;
			xtn.BREADY=s_vif.slave_mon_cb.BREADY;
		slave2sb.write(xtn);
		@(s_vif.slave_mon_cb);	
	endtask

	//Read address channel signal
	task read_address();
		@(s_vif.slave_mon_cb);
		wait(s_vif.slave_mon_cb.ARREADY && s_vif.slave_mon_cb.ARVALID);
		xtn.ARID=s_vif.slave_mon_cb.ARID;
		xtn.ARADDR=s_vif.slave_mon_cb.ARADDR;
		xtn.ARSIZE=s_vif.slave_mon_cb.ARSIZE;
		xtn.ARLEN=s_vif.slave_mon_cb.ARLEN;
		xtn.ARBURST=s_vif.slave_mon_cb.ARBURST;
		xtn.ARVALID=s_vif.slave_mon_cb.ARVALID;
		xtn.ARREADY=s_vif.slave_mon_cb.ARREADY;
		q3.push_back(xtn);
		//slave2sb.write(xtn);
		@(s_vif.slave_mon_cb);
	endtask

	//read data channel signal
	task read_data(master_trans req);
		xtn.RDATA = new[xtn.ARLEN +1];
		xtn.RRESP = new[xtn.ARLEN +1];
		for(int i=0;i<=req.ARLEN;i++)
		begin
			@(s_vif.slave_mon_cb);
			wait(s_vif.slave_mon_cb.RREADY && s_vif.slave_mon_cb.RVALID);
			xtn.WID=s_vif.slave_mon_cb.WID;
			xtn.RDATA[i]=s_vif.slave_mon_cb.RDATA;
			xtn.RRESP[i]=s_vif.slave_mon_cb.RRESP;
			xtn.RLAST=s_vif.slave_mon_cb.RLAST;
			xtn.RVALID=s_vif.slave_mon_cb.RVALID;
			xtn.RREADY=s_vif.slave_mon_cb.RREADY;	
					@(s_vif.slave_mon_cb);
		end
	slave2sb.write(xtn);

	endtask


endclass

