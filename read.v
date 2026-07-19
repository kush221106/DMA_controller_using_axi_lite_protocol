
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
    
    parameter s0=0,s1=1,s2=2,s3=3,s4=4,s5=5;
    reg [4:0] count;
    reg [2:0] state,next_state;
    reg init, inc;
    reg [4:0] inter_len;
    reg [2:0] trackR1,trackR2,needed;
    reg [31:0] R1,R2;
    reg [31:0] srcu;
  
    always @(posedge clk)
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
                if(ARREADY)
                    next_state = s2;
                    else next_state = s1;
            end
            s2 : begin
                if(RVALID)
                next_state = s3;
                else
                next_state = s2;
            end
            
            s3 : 
                begin
                    next_state = s4;
                end
            s4 : begin
                if(inter_len == 0) next_state = s5;
                else if(trackR1 == 0) next_state = s1;
                else next_state = s3;
            end
            s5 : next_state = s5;
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
                    trackR1 = 4;
                    trackR2 = 4;
                    inter_len = length;
                    R1 = 0;
                    R2 = 32'bx;
                    needed=0;
                    srcu=(source_address>>2)<<2;
                    end
            s1 : begin
                    ARVALID = 1;
                    RREADY=0;
                    ARADDR = srcu+count*4;
                    inc =0;
                    trackR1 = 4;
                    wr_en = 0;
                    end
            s2 : begin
                wr_en=0;
                    RREADY = 1;
                    if(RVALID) begin
                       R1 = RDATA;
                    end
                 end
             s3 :begin
             if(init) begin
                   trackR1 = 4-(source_address-srcu);
                end

                wr_en =0;
                inc=0;
                RREADY = 0;
                ARVALID = 0;
                needed = (trackR1>trackR2?(inter_len>trackR2?trackR2:inter_len):(inter_len>trackR1?trackR1:inter_len));
              // R2[trackR2 * 8 - 1 -:(needed*8)] = R1[trackR1*8 - 1 -:needed*8];
              //  trackR1 = trackR1 - needed;
              //  trackR2 = trackR2 - needed;
            //  inter_len = inter_len - needed;
            case(needed)
             1   : begin
                 R2[trackR2*8-1 -: 8] = R1[trackR1*8-1 -: 8];
                   trackR1 = trackR1 - 1;
                trackR2 = trackR2 - 1;
                inter_len = inter_len - 1;
             end
                2 : begin
                 R2[trackR2*8-1 -: 16] = R1[trackR1*8-1 -: 16];
                   trackR1 = trackR1 - 2;
                trackR2 = trackR2 - 2;
                inter_len = inter_len - 2;
                end
               3 : begin
                 R2[trackR2*8-1 -: 24] = R1[trackR1*8-1 -: 24];
                   trackR1 = trackR1 - 3;
                trackR2 = trackR2 - 3;
                inter_len = inter_len - 3;
                end
              4 : begin
                 R2[trackR2*8-1 -: 32] = R1[trackR1*8-1 -: 32];
                   trackR1 = trackR1 - 4;
                  trackR2 = trackR2 - 4;
                inter_len = inter_len - 4;
                end
            endcase
             end 

             s4: begin
                   init = 0;
                   wr_en = 0;
                    if(trackR2 == 0 || inter_len==0) begin
                            wr_en = 1;
                            rdata_out = R2;
                          R2 = 32'bx;
                          trackR2 = 4;
                    end
                       if(trackR1==0)
                                inc = 1;                      
             end

             s5 : begin
                rdata_out=32'bx;
                wr_en = 0;
             end
             endcase            
    end
endmodule
