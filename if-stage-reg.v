module IF_Stage_reg(
    input clk,
    input rst,
    input freeze,
    input flush,

    input [31:0] PC_in,
    input [31:0] Instruction_in,

    output reg[31:0] PC,
    output reg[31:0] Instruction
);
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            PC <= 0;
            Instruction <= 0;
        end
        else if (flush) begin
            PC <= 0;
            Instruction <= 0;
		  end
        else if(freeze) begin
            PC <= PC;
            Instruction <= Instruction;
        end
        else begin
            PC <= PC_in;
            Instruction <= Instruction_in;
        end
    end
endmodule
