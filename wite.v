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
    output reg AWVALID,
    output reg [3:0] WSTRB,
    output reg done
    );
    parameter s0=0,s1=1,s2=2,s3=3,s4=4,s5=5;
    reg [2:0] state,next_state;
    reg inc,init;
    reg [4:0] count;
    reg[4:0]inter_len;
    reg[31:0] R1,R2;
    reg[2:0] trackR1,trackR2,needed;
    reg[31:0] wru;
    integer i;

    always @(negedge clk)
    begin
        if(reset) begin
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
                if(^R1 === 1'bx) next_state=s4;
                else next_state=s3;
            end
            s3 : 
                begin
                    next_state = s4;
                end
           s4 : begin
            if(^R1 === 1'bx || ~|inter_len) next_state=s5;
            else if((length%4 == 0 && inter_len<=3)) next_state = s2;
            else if(trackR1==0) next_state = s1;
            else next_state=s2;
            
           end
            s5 : begin
                next_state=s5;
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
                    R2=32'bx;
                     wru= (destination_address>>2) <<2;
                     trackR1 = 4;
                     trackR2 = 4;
                     WSTRB = 0;
                     done =0;
                     inter_len= length;
                    end
            s1 : begin
                    AWVALID = 1;
                    WVALID=0;
                    AWADDR = wru + count*4 ;
                    inc =0;
                    trackR1=4;
                    if(!fifo_empty) begin 
                        rd_en = 1;
                        end
                    end
            s2 : begin
                WVALID = 0;
                    R1 = writedata_in;        
                    rd_en=0;
                 end
             s3 :begin
                if(init)  needed= 4-(destination_address-wru);
                else needed = trackR1>trackR2?trackR2:trackR1;
                  
              
                    inc =0;
                    rd_en = 0;
                    if(init) begin
                        case(needed)
                          1 : begin
                               R2[7 -: 8 ] = R1[trackR1*8-1 -: 8];
                               trackR1 = trackR1 -1;
                               trackR2 = trackR2 -1;
                               inter_len = inter_len - needed;
                             end
                        2 : begin
                               R2[15 -: 16 ] = R1[trackR1*8-1 -: 16];
                               trackR1 = trackR1 -2;
                               trackR2 = trackR2 -2;
                               inter_len = inter_len - needed;
                             end
                        3 : begin
                               R2[23 -: 24 ] = R1[trackR1*8-1 -: 24];
                               trackR1 = trackR1 -3;
                               trackR2 = trackR2 -3;
                               inter_len = inter_len - needed;
                             end
                        4 : begin
                               R2[31 -: 32 ] = R1[trackR1*8-1 -: 32];
                               trackR1 = trackR1 -4;
                               trackR2 = trackR2 -4;
                               inter_len = inter_len - needed;
                             end
                        endcase
                    end
                    else
                    begin
                        case(needed)
                          1 : begin
                               R2[trackR2*8 -1 -: 8 ] = R1[trackR1*8-1 -: 8];
                               trackR1 = trackR1 -1;
                               trackR2 = trackR2 -1;
                               inter_len = inter_len - needed;
                             end
                        2 : begin
                               R2[trackR2*8 -1 -: 16 ] = R1[trackR1*8-1 -: 16];
                               trackR1 = trackR1 -2;
                               trackR2 = trackR2 -2;
                               inter_len = inter_len - needed;
                             end
                        3 : begin
                               R2[trackR2*8 -1 -: 24 ] = R1[trackR1*8-1 -: 24];
                               trackR1 = trackR1 -3;
                               trackR2 = trackR2 -3;
                               inter_len = inter_len - needed;
                             end
                        4 : begin
                               R2[trackR2*8 -1 -: 32 ] = R1[trackR1*8-1 -: 32];
                               trackR1 = trackR1 -4;
                               trackR2 = trackR2 -4;
                               inter_len = inter_len - needed;
                             end
                        endcase
                    end
                    // R2[(init==1?needed*8-1 : trackR2*8 -1 )-: needed*8] = R1[trackR1*8-1 :- needed*8];
                    // trackR1=trackR1-needed;
                    // trackR2 = trackR2-needed;   
             end 
             s4 : 
             begin

               if(init == 1) begin
                    WDATA = R2;
                    for(i = needed-1;i>=0;i=i-1) begin
                            WSTRB[i] = 1'b1;
                    end
                    init = 0;
                    trackR2=4;
                    WVALID = 1;
               end
               
               else begin
                  if(^R1 === 1'bx) begin
                        WSTRB = 0;
                        WDATA = R2;
                        for(i=3;i>=trackR2;i=i-1)   WSTRB[i] = 1'b1;
                       WVALID = 1;
                       BREADY = 1;
                       end 

                 else begin 
                            if(trackR1==0) inc = 1;

                            if(trackR2 == 0 || ~|inter_len) begin
                                 WSTRB = 4'b1111;
                                 WDATA = R2;
                                 trackR2=4;
                                 R2=32'bx;
                                 WVALID = 1;
                            end
                       end
               end
             end
              s5 : begin
                WVALID = 0;
                AWVALID = 0;
                done =1;
                WSTRB = 0;
              end
             endcase 
                  
    end
endmodule



