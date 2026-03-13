`timescale 1ns / 1ps
module write(
    input clk,
    input reset,
    input trigger,
    input WREADY,
    input AWREADY,
    input [4:0] length,
    input [31:0] destination_address,
    input BVALID,
    input fifo_empty,
    
    input [31:0] writedata_in,
    output reg [31:0] WDATA,
    output reg [31:0] AWADDR,
    output reg rd_en,
    output reg BREADY,
    output reg WVALID,
    output reg AWVALID
    
    
    
    );
    parameter s0=0,s1=1,s2=2,s3=3;
    reg [1:0] state,next_state;
    reg inc,init;
    reg [4:0] count;
    always @(negedge clk)
    begin
        if(reset) begin
//            count<=0;
//            rdata_out <=0;
//            ARADDR<=0;
//            RREADY<=0;

            state<=s0;
        end
        else
            state<=next_state;
    end
    always @(*)
    begin
        case (state)
            s0: begin 
                if(!reset && trigger) next_state = s1;
                else next_state = s0;
                
            end
            s1 : begin
                if(AWREADY&&rd_en)
                    next_state = s2;
                    else next_state = s1;
            end
            s2 : begin
                if(count == (length/4) -1) next_state = s3;
                  else if(WREADY) next_state = s1;
                  else next_state = s2;
            end
            s3 : 
                begin
                    next_state = s3;
                end
            default: 
                next_state = s0;
            endcase
                    
    end
    always @(negedge clk)
    begin
        if(init) count <=0;
        else if(inc) count<=count +1;
    end
    always @(*) begin
        case (state) 
            s0 :    begin
                    WDATA = 0;
                    AWADDR = 0;
                    rd_en = 0;
                    BREADY = 0;
                    WVALID = 0;
                    AWVALID = 0;
                    init = 1;
                    inc =0;
                    end
            s1 : begin
                    AWVALID = 1;
                    WVALID=0;
                    AWADDR = destination_address + count ;
                    init =0;
                    inc =0;
                    if(!fifo_empty) begin 
                        rd_en = 1;
                        end
                    end
            s2 : begin
                    WVALID = 1;
                    if(WREADY) begin
                        WDATA = writedata_in;
                        inc = 1;
                        rd_en = 0;
                    end
                 end
             s3 :begin
                    inc =0;
                    init = 0;
                    rd_en = 0;
                    WVALID = 0;
                    AWVALID = 0;
                
             end 
             endcase 
                  
    end
endmodule