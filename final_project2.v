`timescale 1ns/1ps
module find_MAX(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire valid,
    input wire [7:0] Data_A,
    input wire [7:0] Data_B,
    input wire one_left,
    input wire [2:0] instruction,
    output reg [7:0] maximum,
    output reg finish
);
    wire [7:0] result;

    // Functional_Unit instantiation
    Functional_Unit fu(
        .instruction(instruction), 
        .A(Data_A),
        .B(Data_B),
        .F(result)
    );

    //TODO: write your design below
    //You cannot modify anything above
    //state declaration
    parameter STATE_0 = 2'b00;
    parameter STATE_1 = 2'b01;
    parameter STATE_2 = 2'b10;

    reg [1:0] state, next_state;
    wire o_finish;
    reg [7:0] o_maximum;

    //state update
    always @(posedge clk) begin
        if (~rst_n)
            state <= STATE_0;
        else
            state <= next_state;
    end
    //next state logic
    always @(posedge clk) begin
        case(state)
            STATE_0: begin
                if (start == 1)
                    next_state = STATE_1;
                else
                    next_state = STATE_0;
            end
            STATE_1: begin
                if (one_left == 1)
                    next_state = STATE_2;
                else
                    next_state = STATE_1;
            end
            STATE_2: begin
                if (valid == 1)
                    next_state = STATE_0;
                else
                    next_state = STATE_2;
            end
        default: next_state = STATE_0;
        endcase
    end
    //output logic
    assign o_finish = (state == STATE_2 && valid == 1) ? 1 : 0;

    //decide max logic
    always @(*) begin
        case(state)
            STATE_1, STATE_2: begin
                if (valid == 1)
                    if (result > maximum)
                        o_maximum = result;
                    else
                        o_maximum = maximum;
                else
                    o_maximum = maximum;
            end
            default: o_maximum = 1'b0; 
        endcase
    end
    //output FFs
    always @(posedge clk) begin
        maximum <= o_maximum;
        if (~rst_n) begin
            maximum <= 1'b0;
            finish <= 1'b0;
        end
        else begin
            if (o_finish)
                finish <= 1'b1;
            else
                finish <= 1'b0;
        end
    end
endmodule