module axi_top;
	import uvm_pkg::*;
	import axi_pkg::*;
	`include "uvm_macros.svh"
	bit ACLK;
	always
		#5 ACLK = ~ACLK;

	axi_interface AXI_IF(ACLK);

	initial
	begin
		uvm_config_db #(virtual axi_interface)::set(null,"*","axi_interface",AXI_IF);
		run_test("axi_test_base");
	end

	
endmodule
