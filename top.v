`include "read.v"
`include "write.v"
`include "fifo.v" 

module top(input clk,input reset,input trigger,input [4:0]length,input [31:0] source_address,input [31:0] destination_address,output done,input ARREADY,input [31:0] RDATA,input RVALID,input AWREADY,input WREADY,input BVALID,output [31:0] ARADDR,output ARVALID,output RREADY,output [31:0] AWADDR,output AWVALID,output [31:0] WDATA,output WVALID,output BREADY,output [3:0] WSTRB);
wire [31:0] rdata_out,writedata_in;
wire wr_en,rd_en,fifo_empty;
read r(clk,
    reset,
    trigger,
    RVALID,
    length,
    source_address,
    RDATA,
    ARREADY,
    rdata_out,
    ARADDR,
    RREADY,
    ARVALID,
    wr_en);
write w( clk,
     reset,
     trigger,
     WREADY,
     AWREADY,
     length,
     destination_address,
     BVALID,
     fifo_empty,    
     writedata_in,
      WDATA,
     AWADDR,
     rd_en,
     BREADY,
     WVALID,
     AWVALID,
     WSTRB,
     done);
fifo zizo(clk,
    reset,
    wr_en,
    rdata_out,
    rd_en,
    writedata_in,
    fifo_empty);
endmodule
