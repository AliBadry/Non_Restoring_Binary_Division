`timescale 1ns/1ps
module binary_division_tb #(
    parameter   INTEGER_SIZE = 16,
                FRACT_SIZE = 16
) ();
localparam  HALF_CYCLE = 5,
            CLK_CYLCE = 2*HALF_CYCLE;
reg                                                 clk_tb, rst_tb;
reg                                                 start_div_tb;
reg     signed  [INTEGER_SIZE+FRACT_SIZE-1:0]       dividend_tb, divisor_tb;
wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]       Q_output_tb;
wire                                                end_div_tb;

//integer i1/*, i2*/;

//===============clock driver==============//

initial begin
    clk_tb = 1'b1;
    forever begin
        #HALF_CYCLE clk_tb = !clk_tb;
    end
end

//===============reset driver==============//

initial begin
    rst_tb = 1'b0;
    #(CLK_CYLCE*2) rst_tb = 1'b1;
end

//===============reading the serial input data==============//

/*reg [DATA_WIDTH-1:0] MEM_in_r [0:NO_SAMPLES-1] ;
reg [DATA_WIDTH-1:0] MEM_in_i [0:NO_SAMPLES-1] ;
initial begin
        $readmemh("IFFT_out_hex_real.txt",MEM_in_r);
        $readmemh("IFFT_out_hex_imag.txt",MEM_in_i);
end*/

//===============writing the output external file ==============//

/*integer fileID1, fileID2;
initial begin
    fileID1 = $fopen("FFT_out_r.txt","w");
    fileID2 = $fopen("FFT_out_i.txt","w");
end*/
//===============main driver==============//

initial begin
    //--------initializing the input ports---------//
    start_div_tb = 1'b0;
    dividend_tb = 1'b0;
    divisor_tb = 1'b0;
    //----------starting the operation------//
    #(CLK_CYLCE+1)
    /*#(CLK_CYLCE*2+1)*/@(posedge clk_tb) start_div_tb = 1'b1;
    //-------injecting the input------------//
    //dividend_tb = 'h001d51eb;
    dividend_tb = 'h00c8a147;
    divisor_tb =  'hfff97ae1;
    @(posedge clk_tb) 
    start_div_tb = 1'b0;
    dividend_tb = 1'b0;
    divisor_tb =  1'b0;
#(CLK_CYLCE*100) $stop;
end

//===============DUT instantiation==============//
binary_division #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE)) DUT (
    .clk(clk_tb),
    .rst(rst_tb),
    .start_div(start_div_tb),
    .dividend(dividend_tb),
    .divisor(divisor_tb),
    .Q_output(Q_output_tb),
    .end_div(end_div_tb)
);
endmodule