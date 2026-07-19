`timescale 1ns/1ps
`include "top.v" 
`include "memory.v" 
module tb;
reg clk,reset, trigger;
reg [4:0] length;
reg [31:0] source_address, destination_address;
wire done;
wire ARREADY,RVALID, AWREADY,WREADY,BVALID, ARVALID,RREADY,AWVALID,WVALID,BREADY;
wire [31:0]  RDATA, ARADDR,AWADDR, WDATA,stARADDR,stAWADDR;
wire [3:0] WSTRB;
assign stARADDR=ARADDR;
assign stAWADDR = AWADDR;
top tm(clk,reset,trigger,length, source_address,destination_address,done, ARREADY,RDATA,RVALID,AWREADY,WREADY, BVALID, ARADDR, ARVALID, RREADY, AWADDR,AWVALID, WDATA,WVALID, BREADY,WSTRB);
memory mem( ARREADY, RDATA, RVALID, AWREADY, WREADY, BVALID, stARADDR, ARVALID, RREADY, stAWADDR, AWVALID, WDATA,WVALID, BREADY,WSTRB);
integer i;
initial begin
    for(i=0;i<=64;i=i+4) begin
          mem.mem[i]=i;
          mem.mem[i+1]=i+1;
          mem.mem[i+2]=i+2;
          mem.mem[i+3]=i+3;
    end
end
initial begin
    clk =0;
    reset = 1;
    trigger = 0;
    source_address = 17;
    destination_address = 33;
    length = 14;
end
always #5 clk =~clk;
initial begin

    $monitor($time," %0d |%0d |%0d |%0d |%0d |%0d |%0d |%0d",tm.zizo.mem[0],tm.zizo.mem[1],tm.zizo.mem[2],tm.zizo.mem[3],mem.mem[8],mem.mem[9],mem.mem[10],mem.mem[11]);
    $dumpfile("zizo.vcd");
    $dumpvars(0,tb);
   #500 $finish;
end
initial begin 
    #12 reset = 0;
    #12 trigger = 1; 
end
endmodule
