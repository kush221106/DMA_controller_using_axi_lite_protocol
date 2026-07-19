module memory(output ARREADY,output reg [31:0] RDATA,output RVALID,output AWREADY,output WREADY,output reg BVALID,input [31:0] ARADDR,input ARVALID,input RREADY,input [31:0] AWADDR,input AWVALID,input [31:0] WDATA,input WVALID,input BREADY,input [3:0] WSTRB);
reg[7:0]mem[0:999];
assign ARREADY = 1'b1;
assign RVALID = 1'b1;
assign WREADY = 1'b1;
assign AWREADY = 1'b1;
integer i;
wire wst;
assign wst = |WSTRB;

always @(*) begin
    if(ARVALID && RVALID) begin
        RDATA = {mem[ARADDR],mem[ARADDR+1],mem[ARADDR+2],mem[ARADDR+3]};
    end

    if(AWVALID && WVALID) begin
        for(i=0;i<=3;i=i+1) begin
            if(WSTRB[i]) begin
                mem[AWADDR+i] = WDATA[8*i+7 -:8];
            end
        end
    end
end

always @(negedge wst) 
    BVALID = 1;
endmodule
