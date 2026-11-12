class axi_sb extends uvm_scoreboard;
	`uvm_component_utils(axi_sb)
	int success,fail;
	int mast,slave;
	master_trans xtn1,xtn2;
	uvm_tlm_analysis_fifo #(master_trans) master2sb;
	uvm_tlm_analysis_fifo #(master_trans) slave2sb;

	bit[3:0]rresp;
	bit[31:0]Data;
	bit[31:0]RData;
	bit[3:0]strb;
	covergroup master_cov;
		araddr:coverpoint xtn1.ARADDR{bins low={[32'h0000:32'h00ffff]};
						bins mid={[32'h00ffff:32'hffff0000]};
						bins hid={[32'hffff0000:32'hffffffff]};}

	/*	arlen :coverpoint xtn1.ARLEN{bins low={[16'h0:16'h5]};
					bins mid={[16'h5:16'ha]};
					bins high={[16'ha:16'h10]};}*/
		arlen :coverpoint xtn1.ARLEN{bins low={[0:4]};
					bins mid={[5:9]};
					bins high={[10:15]};}


		arsize:coverpoint xtn1.ARSIZE{bins size[]={0,1,2};}
		arburst:coverpoint xtn1.ARBURST{bins burst[]={0,1,2};}

		awaddr:coverpoint xtn1.AWADDR{bins low={[32'h0000:32'h00ffff]};
						bins mid={[32'hfffffff:32'h0ffff0000]};
						bins hid={[32'hffff0000:32'hffffffff]};}
					

		awlen :coverpoint xtn1.AWLEN{bins low={[16'h0:16'h5]};
					bins mid={[16'h5:16'ha]};
					bins high={[16'ha:16'h10]};}

		awsize:coverpoint xtn1.AWSIZE{bins size[]={0,1,2};}

		awburst:coverpoint xtn1.AWBURST{bins burst[]={0,1,2};}

		wdat:coverpoint Data{bins low={[32'h0000:32'h00ffffff]};
				    bins mid={[32'h00ffffff:32'hffffffff]};
				    bins hid={[32'hffff0000:32'hffffffff]};}

		wstrb:coverpoint strb{bins low={1,2,4,8,3,12,14,15};}

/*		cross arlen, arsize;
cross arlen, arburst;
cross arsize, arburst;

cross awlen, awsize;
cross awlen, awburst;
cross awsize, awburst;

cross araddr, arburst;
cross awaddr, awburst;*/
	endgroup

	covergroup slave_cov;
	resp:coverpoint xtn2.BRESP{bins Resp={0};}
	rr:coverpoint rresp{bins RResp={0};}
	rdata:coverpoint RData{bins low={[32'h0000:32'h00ffff]};
				bins mid={[32'h00ffff:32'hffff0000]};
				bins hid={[32'hffff0000:32'hffffffff]};}

/*	  resp_rr_cross    : cross resp, rr;
  resp_rdata_cross : cross resp, rdata;
  rr_rdata_cross   : cross rr, rdata;*/
	endgroup
	
	function new(string name = "axi_sb",uvm_component parent);
		super.new(name,parent);
		master2sb = new("master2sb",this);
		slave2sb = new("slave2sb",this);
		master_cov=new();
		slave_cov=new();		
	endfunction

	task run_phase(uvm_phase phase);
		forever
		begin
			xtn1 = 	master_trans::type_id::create("xtn1");
			xtn2 = 	master_trans::type_id::create("xtn2");
			
			master2sb.get(xtn1);
			mast++;
			`uvm_info(get_type_name(),$sformatf("master2sb TRANSACTION SIGNALS :- %s",xtn1.sprint()),UVM_LOW)		
			
			slave2sb.get(xtn2);
			slave++;
			`uvm_info(get_type_name(),$sformatf("slave2sb TRANSACTION SIGNALS :- %s",xtn2.sprint()),UVM_LOW)

		
			
			if(xtn1.compare(xtn2))begin
				$display("AXI COMPARISION SUCCESSFUL");
				success++;
				
					foreach(xtn2.RDATA[i])
			begin
				rresp=xtn2.RRESP[i];
				RData=xtn2.RDATA[i];
				slave_cov.sample();
									
			end

			foreach(xtn1.WDATA[i])
			begin
				Data=xtn1.WDATA[i];
				strb=xtn1.WSTRB[i];
				master_cov.sample();		 
				
			end
				 $display("=========================COVERAGE)============================================ ");
                                        $display("Slave_Coverage = %0.2f", slave_cov.get_coverage());
                                        $display("=========================(COVERAGE DONE)============================================ ");


				$display("=========================COVERAGE)============================================ ");
                                        $display("Master_Coverage = %0.2f", master_cov.get_coverage());
                                        $display("=========================(COVERAGE DONE)============================================ ");


			
			end
			else begin
				$display("AXI COMPARISION FAILED");
				fail++;
			end
			
		end
			

	endtask

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);

		$display("success = %0d",success);
		$display("fail = %0d",fail);
		$display("master = %0d",mast);
		$display("slave = %0d",slave);

	endfunction
endclass

