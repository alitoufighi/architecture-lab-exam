module ID_Stage(
    input clk,
    input rst,

    input [31: 0] Instruction,
    input WB_Write_Enable,
    input [4:0] WB_Dest,
    input [31:0] WB_Data,
    input hazard_detected,

    output [4:0] Dest,
    output [31:0] Reg2,
    output [31:0] Val2,
    output [31:0] Val1,
    output [1:0] Br_type,
    output [3:0] EXE_CMD,
    output MEM_R_EN,
    output MEM_W_EN,
    output WB_EN,
    output freeze,
    output single_src,
    output is_swp
);
    wire is_imm;
    wire [31:0] RegF1, RegF2;
    wire [31:0] sign_extended;

    wire [3:0] _EXE_CMD;
    wire _MEM_R_EN, _MEM_W_EN, _WB_EN, _is_imm, _single_src;
    wire [1:0] _Br_type;

    wire [1:0] swp_sel, _swp_sel;
    wire [4:0] _Dest;
    wire _freeze, _is_swp;

    Control_unit cu(
            .opcode(Instruction[31:26]),
            .clk(clk),
            .freeze(_freeze),
            .swp_sel(_swp_sel),
            .exec_cmd(_EXE_CMD),
            .mem_r_en(_MEM_R_EN),
            .mem_w_en(_MEM_W_EN),
            .wb_en(_WB_EN),
            .is_imm(_is_imm),
            .branch_type(_Br_type),
            .single_src(_single_src),
            .is_swp(_is_swp)
    );

    assign {EXE_CMD, MEM_R_EN, MEM_W_EN, WB_EN, is_imm, Br_type, single_src, freeze, swp_sel, is_swp} = (hazard_detected) ? 14'b0 : 
                                                                        {_EXE_CMD, _MEM_R_EN, _MEM_W_EN, _WB_EN, _is_imm, _Br_type, _single_src, _freeze, _swp_sel, _is_swp};

    Registers_file reg_file(
            .clk(clk),
            .rst(rst),
            .src1(Instruction[25:21]),
            .src2(Instruction[20:16]),
            .dest(WB_Dest),
            .Write_Val(WB_Data),
            .Write_EN(WB_Write_Enable),
            .out1(RegF1),
            .out2(RegF2)
    );

    SignExtend sign_extend(
            .in(Instruction[15:0]),
            .out(sign_extended)
    );

    assign Val2 = is_imm ? sign_extended : RegF2;
    assign Val1 = RegF1;
    assign Reg2 = RegF2;
    assign _Dest = is_imm ? Instruction[20:16] : Instruction[15:11];
    assign Dest = (swp_sel==0) ? _Dest : ((swp_sel == 1) ? Instruction[25:21] : Instruction[20:16]);
endmodule
