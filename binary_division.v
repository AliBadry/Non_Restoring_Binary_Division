module binary_division #(
    parameter   INTEGER_SIZE = 16,
                FRACT_SIZE = 16
) (
    input   wire                                            clk, rst, start_div,
    input   wire signed[INTEGER_SIZE+FRACT_SIZE-1:0]        dividend, divisor,
    output  reg  signed[INTEGER_SIZE+FRACT_SIZE-1:0]        Q_output,       //Q is the quotient
    output  reg                                             end_div
);
localparam NO_ITERATIONS = INTEGER_SIZE+2*FRACT_SIZE;
localparam  IDLE = 0,
            SHIFT_A = 1,
            //Q_LSB = 3,
            END_OPERATION = 2;

reg  signed [NO_ITERATIONS-1:0]             Q_comb, Q_reg;
reg         [NO_ITERATIONS-1:0]             A_comb, A_reg;
reg  signed [INTEGER_SIZE+FRACT_SIZE-1:0]   M_comb, M_reg;
reg         [$clog2(NO_ITERATIONS):0]       counter, counter_seq;
reg         [1:0]                           current_state, next_state;
reg                                         sign_comb, sign_seq;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        Q_reg <= 'b0;
        M_reg <= 'b0;
        A_reg <= 'b0;
        counter_seq <= 'b0;
        current_state <= 'b0;
        sign_seq <= 1'b0;
    end
    else begin
        Q_reg <= Q_comb;
        M_reg <= M_comb;
        A_reg <= A_comb;
        counter_seq <= counter;
        current_state <= next_state;
        sign_seq <= sign_comb;
    end
end

always @(*) begin
    Q_output = 'b0;
    end_div = 'b0;
    Q_comb = 'b0;
    M_comb = 'b0;
    A_comb = 'b0;
    counter = 'b0;
    next_state = IDLE;
    sign_comb = 1'b0;

    case (current_state)
    //=====================================//
    IDLE: begin
        if(start_div) begin
            next_state = SHIFT_A;
            sign_comb = dividend[INTEGER_SIZE+FRACT_SIZE-1] ^ divisor[INTEGER_SIZE+FRACT_SIZE-1];
            if(dividend[INTEGER_SIZE+FRACT_SIZE-1]) begin
                Q_comb = (-dividend)<<FRACT_SIZE;
            end
            else begin
                Q_comb = (dividend)<<FRACT_SIZE;
            end
            if(divisor[INTEGER_SIZE+FRACT_SIZE-1]) begin
                M_comb = -divisor;
            end
            else begin
                M_comb = divisor;
            end
            A_comb = 'b0;
        end
        else begin
            next_state = IDLE;
        end
    end 
    //=====================================//
    SHIFT_A: begin
        //Q_comb = Q_reg;
        M_comb = M_reg;
        //counter = counter_seq;
        sign_comb = sign_seq;
        if(A_reg[NO_ITERATIONS-1]) begin
            A_comb = {A_reg[NO_ITERATIONS-2:0],Q_reg[NO_ITERATIONS-1]} + M_reg;
        end
        else begin
            A_comb = {A_reg[NO_ITERATIONS-2:0],Q_reg[NO_ITERATIONS-1]} - M_reg;
        end

        if(A_comb[NO_ITERATIONS-1]) begin
            Q_comb = (Q_reg<<1);
        end
        else begin
            Q_comb = (Q_reg<<1) + 1'b1;
        end
        counter = counter_seq + 1'b1;

        if(counter == NO_ITERATIONS) begin
            next_state = END_OPERATION;
        end 
        else begin
            next_state = SHIFT_A;
        end
    end
    //=====================================//
    /*Q_LSB: begin
        A_comb = A_reg;
        M_comb = M_reg;
        sign_comb = sign_seq;
        if(A_reg[NO_ITERATIONS-1]) begin
            Q_comb = (Q_reg<<1);
        end
        else begin
            Q_comb = (Q_reg<<1) + 1'b1;
        end
        counter = counter_seq + 1'b1;

        if(counter == NO_ITERATIONS) begin
            next_state = END_OPERATION;
        end 
        else begin
            next_state = SHIFT_A;
        end
    end*/
    //=====================================//
    END_OPERATION: begin
        if(sign_seq) begin
            //Q_output = (-Q_reg)>>FRACT_SIZE;
            Q_output = -Q_reg[NO_ITERATIONS-1:0];
        end
        else begin
            //Q_output = (Q_reg)>>FRACT_SIZE;
            Q_output = Q_reg[NO_ITERATIONS-1:0];
        end
        end_div = 1'b1;
        next_state = IDLE;
    end
    endcase
end

endmodule