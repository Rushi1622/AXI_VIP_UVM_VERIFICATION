interface axi_interface(input bit ACLK);
	bit ARESET;

	//Write address channel signals
	logic [3:0]AWID;
	logic [31:0]AWADDR;
	logic [3:0]AWLEN;
	logic [2:0]AWSIZE;
	logic [1:0]AWBURST;
	logic AWVALID;
	logic AWREADY;
	
	//Write data channel signals
	logic [3:0]WID; 
	logic [31:0]WDATA;
	logic [3:0]WSTRB;
	logic WLAST;
	logic WVALID;
	logic WREADY;

	//Write response channel signals
	logic[3:0]BID;
	logic BRESP;
	logic BVALID;
	logic BREADY;

	//Read address channel signals
	logic [3:0]ARID;
	logic [31:0]ARADDR;
	logic [3:0]ARLEN;
	logic [2:0]ARSIZE;
	logic [1:0]ARBURST;
	logic ARVALID;
	logic ARREADY;
	
	//Read data channel signals
	logic [3:0]RID; 
	logic [31:0]RDATA;
	logic [3:0]RRESP;
	logic RLAST;
	logic RVALID;
	logic RREADY;

//---------------------------------------------------------------------------------------
//===============================MASTER CLOCKING BLOCK & MODPORT=========================
//---------------------------------------------------------------------------------------
	clocking master_drv_cb@(posedge ACLK);
		default input #1 output #1;
		//Write address channel signals
		output AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID,ARESET;
		input AWREADY;
	
		//Write data channel signals
		output WID,WDATA,WSTRB,WLAST,WVALID;
		input WREADY;

		//Write response channel signals
		input BID,BRESP,BVALID;
		output BREADY;

		//Read address channel signals
		output ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
		input ARREADY;
	
		//Read data channel signals
		input RID,RDATA,RRESP,RLAST,RVALID;
		output RREADY;
	endclocking

	clocking master_mon_cb@(posedge ACLK);
		default input #1 output #1;
		//Write address channel signals
		input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
		input AWREADY;
	
		//Write data channel signals
		input WID,WDATA,WSTRB,WLAST,WVALID;
		input WREADY;

		//Write response channel signals
		input BID,BRESP,BVALID;
		input BREADY;

		//Read address channel signals
		input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
		input ARREADY;
	
		//Read data channel signals
		input RID,RDATA,RRESP,RLAST,RVALID;
		input RREADY;
	endclocking

	modport MASTER_DRV_MP(clocking master_drv_cb);
	
	modport MASTER_MON_MP(clocking master_mon_cb);


//---------------------------------------------------------------------------------------
//===============================SLAVE CLOCKING BLOCK & MODPORT=========================
//---------------------------------------------------------------------------------------

	clocking slave_drv_cb@(posedge ACLK);
		default input #1 output #1;
		//Write address channel signals
		input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
		output AWREADY;
	
		//Write data channel signals
		input WID,WDATA,WSTRB,WLAST,WVALID;
		output WREADY;

		//Write response channel signals
		output BID,BRESP,BVALID;
		input BREADY;

		//Read address channel signals
		input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
		output ARREADY;
	
		//Read data channel signals
		output RID,RDATA,RRESP,RLAST,RVALID;
		input RREADY;
	endclocking

	clocking slave_mon_cb@(posedge ACLK);
		default input #1 output #1;
		//Write address channel signals
		input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
		input AWREADY;
	
		//Write data channel signals
		input WID,WDATA,WSTRB,WLAST,WVALID;
		input WREADY;

		//Write response channel signals
		input BID,BRESP,BVALID;
		input BREADY;

		//Read address channel signals
		input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
		input ARREADY;
	
		//Read data channel signals
		input RID,RDATA,RRESP,RLAST,RVALID;
		input RREADY;
	endclocking

	
	modport SLAVE_DRV_MP(clocking slave_drv_cb);
	
	modport SLAVE_MON_MP(clocking slave_mon_cb);

//---------------------------------------------------------------------------------------
//===============================MASTER & SLAVE ASSERTION PROPERTIES=========================
//---------------------------------------------------------------------------------------

endinterface

