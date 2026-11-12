class slave_driver extends uvm_driver#(master_trans);
	`uvm_component_utils(slave_driver)
	
	virtual axi_interface.SLAVE_DRV_MP s_vif;
	slave_agent_config sa_cfg;
	master_trans xtn;	
	semaphore w_address = new(1);//write address channel
	semaphore w_data = new(1);//write data channel
	semaphore r_address = new(1);//read address channel
	semaphore r_data = new(1);//read data channel
	semaphore w_rsp = new(1);//write response channel

	semaphore wadd2data = new();//write address channel to write data channel
	semaphore wadd2rsp = new();//read address channel to read data channel
	semaphore radd2data = new();//write address channel to write response channel

	master_trans q1[$],q2[$],q3[$],q4[$],q5[$];
	
	function new(string name = "slave_driver",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",sa_cfg))
				`uvm_fatal(get_type_name(),"get method are failed from slave driver")
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
			s_vif = sa_cfg.s_vif;
	endfunction
	task run_phase(uvm_phase phase);
	forever
		begin
			xtn = master_trans::type_id::create("xtn");
			q1.push_back(xtn);
			q2.push_back(xtn);
			q3.push_back(xtn);
			q4.push_back(xtn);
			send_to_dut();
			$display("*****************************************************************");
			//`uvm_info(get_type_name(),$sformatf("SLAVE DRIVER CLASS TRANSACTION SIGNALS :- %s",xtn.sprint()),UVM_LOW)
			$display("*****************************************************************");
		end
	endtask
	
	task send_to_dut();
		fork
			begin 
				//write address channel signal
				w_address.get(1);
				write_address(q1.pop_front());
				w_address.put(1);
				wadd2data.put(1);
				
			end
			begin
				//write data channel signal
				w_data.get(1);
				wadd2data.get(1);
				write_data(q2.pop_front());
				w_data.put(1);
				wadd2rsp.put(1);
				
			end
			begin
				//write response channel signal
				w_rsp.get(1);
				wadd2rsp.get(1);
				write_resp(q3.pop_front());
				w_rsp.put(1);
				
			end
			begin
				//read address channel signal
				r_address.get(1);
				read_address(q4.pop_front());
				r_address.put(1);
				radd2data.put(1);
				
			end
			begin
				//read data channel signal
				r_data.get(1);	
				radd2data.get(1);
				read_data(q5.pop_front());
				r_data.put(1);	
			end
		join_any 	
	endtask

	//write address channel signal
	task write_address(master_trans xtn);
		s_vif.slave_drv_cb.AWREADY<=1'b1;
		@(s_vif.slave_drv_cb);
		wait(s_vif.slave_drv_cb.AWVALID);
		xtn.AWID=s_vif.slave_drv_cb.AWID;
		xtn.AWADDR=s_vif.slave_drv_cb.AWADDR;
		xtn.AWSIZE=s_vif.slave_drv_cb.AWSIZE;
		xtn.AWLEN=s_vif.slave_drv_cb.AWLEN;
		xtn.AWBURST=s_vif.slave_drv_cb.AWBURST;
		s_vif.slave_drv_cb.AWREADY<=1'b0;
		repeat($urandom_range(1,5))
			@(s_vif.slave_drv_cb);	
		
	endtask

	//write data channel signal
	task write_data(master_trans xtn);
		for(int i=0;i<=xtn.AWLEN;i++)
   		begin
			s_vif.slave_drv_cb.WREADY<=1'b1;
			@(s_vif.slave_drv_cb);
			wait(s_vif.slave_drv_cb.WVALID);
			s_vif.slave_drv_cb.WREADY<=1'b0;
			repeat($urandom_range(1,5))
				@(s_vif.slave_drv_cb);
			
		end	
	endtask

	//write response channel signal
	task write_resp(master_trans xtn);
			s_vif.slave_drv_cb.BVALID<=1'b1;
			s_vif.slave_drv_cb.BID<=xtn.AWID;
			s_vif.slave_drv_cb.BRESP<=2'b00;
			@(s_vif.slave_drv_cb);
			wait(s_vif.slave_drv_cb.BREADY);
			s_vif.slave_drv_cb.BVALID<=1'b0;
			repeat($urandom_range(1,5))
				@(s_vif.slave_drv_cb);	
			
	endtask

	//read address channel signal
	task read_address(master_trans xtn);
			s_vif.slave_drv_cb.ARREADY<=1'b1;
			repeat($urandom_range(1,5))
			@(s_vif.slave_drv_cb);
			wait(s_vif.slave_drv_cb.ARVALID)
			xtn.ARID=s_vif.slave_drv_cb.ARID;
			xtn.ARADDR=s_vif.slave_drv_cb.ARADDR;
			xtn.ARSIZE=s_vif.slave_drv_cb.ARSIZE;
			xtn.ARLEN=s_vif.slave_drv_cb.ARLEN;
			xtn.ARBURST=s_vif.slave_drv_cb.ARBURST;
			s_vif.slave_drv_cb.ARREADY<=1'b0;
			repeat($urandom_range(1,5))
				@(s_vif.slave_drv_cb);
			q5.push_back(xtn);
				
	endtask

	//read data channel signal
	task read_data(master_trans xtn);
		xtn.RDATA=new[xtn.ARLEN+1];
		for(int i=0;i<=xtn.ARLEN;i++)
		begin
			s_vif.slave_drv_cb.RVALID<=1;
			s_vif.slave_drv_cb.RID<=xtn.ARID;
			xtn.RDATA[i] =$urandom;
			s_vif.slave_drv_cb.RDATA<=xtn.RDATA[i];
			s_vif.slave_drv_cb.RRESP<=2'b00;
			if(i==(xtn.ARLEN))
				s_vif.slave_drv_cb.RLAST<=1'b1;
      			else
				s_vif.slave_drv_cb.RLAST<=1'b0;
			@(s_vif.slave_drv_cb);
			wait(s_vif.slave_drv_cb.RREADY);
			s_vif.slave_drv_cb.RVALID<=1'b0;
			s_vif.slave_drv_cb.RLAST<=1'b0;
			repeat($urandom_range(1,5))
				@(s_vif.slave_drv_cb);
			
		end		

	endtask


endclass

