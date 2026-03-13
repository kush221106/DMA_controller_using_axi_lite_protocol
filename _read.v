module read(
    input clk,
    input reset,
    input trigger,
    input RVALID,
    input [4:0] length,
    input [31:0] source_address,
    input [31:0] RDATA,
    input ARREADY,
    output reg [31:0] rdata_out,
    output reg [31:0] ARADDR,
    output reg RREADY,
    output reg ARVALID,
    output reg wr_en
    );
    parameter s0=0,s1=1,s2=2,s3=3;
    reg [4:0] count;
    reg [1:0] state,next_state;
    reg init, inc;
  
    always @(posedge clk)
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
                if(ARREADY)
                    next_state = s2;
                    else next_state = s1;
            end
            s2 : begin
                if(count == (length/4) -1) next_state = s3;
                  else if(RVALID) next_state = s1;
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
    always @(posedge clk)
    begin
        if(init) count <=0;
        else if(inc) count<=count +1;
    end
    always @(*) begin
        case (state) 
            s0 :    begin
                    rdata_out = 0;
                    ARADDR = 0;
                    RREADY = 0;
                    ARVALID = 0;
                    wr_en = 0;
                    init = 1;
                    inc =0;
                    end
            s1 : begin
                    ARVALID = 1;
                    RREADY=0;
                    ARADDR = source_address + count;
                    init =0;
                    inc =0;
                    wr_en = 0;
                    end
            s2 : begin
                    RREADY = 1;
                    if(RVALID) begin
                        wr_en = 1;
                       rdata_out = RDATA;
                        inc = 1;
                    end
                 end
             s3 :begin
                wr_en =0;
                inc=0;
                RREADY =0;
                ARVALID =0;
             end 
             endcase 
                  
    end
    
    
endmodule