`include "ctrl_encode_def.v"

module ctrl_unit(  // p176
    output reg [1:0] RegDst,
    output reg [1:0] ToReg,  // What write into Reg
    output reg [1:0] ALUSrc,
    output reg RFWr,
    output reg [3:0] NPCOp,
    output reg EXTOp,
    output reg ALUSrc0,  // select for A
    input      [5:0] op,    //31:26
    input      [5:0] funct,  // 5:0
    input      [4:0] bgez_bltz,  // 20:16
    output reg [4:0] ALUOp,
    output reg [1:0] DMWr,
    output reg [2:0] DMRe);

    always @(*) begin
        NPCOp = `NPC_PLUS4;  
        RegDst = `RD_RT;  // x
        ALUSrc = `ALUSRC_ZERO;  // x
        ToReg = `DM2REG;  // x
        RFWr = 1'b0;  
        DMRe = `DMRE_NOP; 
        DMWr = `DMWR_NOP; 
        ALUOp = `ALU_NOP; 
        ALUSrc0 = 1'b0;
        EXTOp = 1'b1;
        case (op)
            `R_TYPE:  begin
                // R-type
                NPCOp = `NPC_PLUS4;
                RegDst = `RD_RD;  // write into rd
                ToReg = `ALU2REG;
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                
                // ALU control unit
                case (funct)
                    `ADD:   begin   
                        ALUOp = `ALU_ADD;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `ADDU:  begin 
                        ALUOp = `ALU_ADDU;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `AND:   begin 
                        ALUOp = `ALU_AND;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `NOR:   begin 
                        ALUOp = `ALU_NOR;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `OR:    begin 
                        ALUOp = `ALU_OR;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `SLL:   begin 
                        ALUOp = `ALU_SLL;
                        ALUSrc = `ALUSRC_SHA;
                        ALUSrc0 = 1'b1;
                        EXTOp = 1'b0;
                    end
                    `SLLV:  begin 
                        ALUOp = `ALU_SLLV;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `SLT:   begin 
                        ALUOp = `ALU_SLT;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `SLTU:  begin 
                        ALUOp = `ALU_SLTU;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `SRA:   begin 
                        ALUOp = `ALU_SRA;
                        ALUSrc = `ALUSRC_SHA;
                        ALUSrc0 = 1'b1;
                        EXTOp = 1'b0;
                    end
                    `SRAV:  begin 
                        ALUOp = `ALU_SRAV;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `SRL:   begin 
                        ALUOp = `ALU_SRL;
                        ALUSrc = `ALUSRC_SHA;
                        ALUSrc0 = 1'b1;
                        EXTOp = 1'b0;
                    end
                    `SRLV:  begin 
                        ALUOp = `ALU_SRLV;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `SUB:   begin 
                        ALUOp = `ALU_SUB;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `SUBU:  begin 
                        ALUOp = `ALU_SUBU;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `XOR:   begin 
                        ALUOp = `ALU_XOR;
                        ALUSrc = `ALUSRC_REG;
                    end
                    `JALR:  begin
                        NPCOp = `NPC_JUMPR; 
                        RegDst = `RD_RA;  // if JALR then write into rd
                        ALUSrc = `ALUSRC_ZERO; // x
                        ToReg = `NPC2REG;  // Next PC write into rd
                        RFWr = 1'b1; 
                        DMRe = `DMRE_NOP; 
                        DMWr = `DMWR_NOP; 
                        ALUOp = `ALU_NOP;
                    end
                    `JR:    begin
                        NPCOp = `NPC_JUMPR; 
                        RegDst = `RD_RA;  // if JALR then write into rd
                        ALUSrc = `ALUSRC_ZERO; // x
                        ToReg = `NPC2REG;  // Next PC write into rd
                        RFWr = 1'b0;  
                        DMRe = `DMRE_NOP; 
                        DMWr = `DMWR_NOP; 
                        ALUOp = `ALU_NOP;
                    end
                endcase
            end
            `ADDI:  begin
                // ADDI
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // imm
                ToReg = `ALU2REG;  
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b1;
                ALUOp = `ALU_ADD;
            end
            `ADDIU:  begin
                // ADDIU
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM; // imm
                ToReg = `ALU2REG; 
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b0;
                ALUOp = `ALU_ADDU;
            end
            `ANDI:  begin
                // ANDI
                NPCOp = `NPC_PLUS4;
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // imm
                ToReg = `ALU2REG; 
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b0;
                ALUOp = `ALU_AND;
            end
            `LUI:  begin
                // LUI
                NPCOp = `NPC_PLUS4;  
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // imm
                ToReg = `ALU2REG;  
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b0;
                ALUOp = `ALU_LUI;
            end
            `ORI:  begin
                // ORI
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // imm
                ToReg = `ALU2REG;  
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b0;
                ALUOp = `ALU_OR;
            end
            `SLTI:  begin
                // SLTI
                NPCOp = `NPC_PLUS4;  
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // imm
                ToReg = `ALU2REG;  
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b1;
                ALUOp = `ALU_SLT;
            end
            `SLTIU:  begin
                // SLTIU
                NPCOp = `NPC_PLUS4;  
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM; // imm
                ToReg = `ALU2REG;  
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b0;
                ALUOp = `ALU_SLTU;
            end
            `XORI:  begin
                // XORI
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM; // imm
                ToReg = `ALU2REG; 
                RFWr = 1'b1;
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b0;
                ALUOp = `ALU_XOR;
            end
            `BEQ:  begin
                // BEQ
                NPCOp = `NPC_BRANCH_BEQ; 
                RegDst = `RD_RT; // x
                ALUSrc = `ALUSRC_REG;  // ALU do sub operation
                ToReg = `ALU2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b1;
                ALUOp = `ALU_SUB;
            end
            `BGTZ:  begin
                // BGTZ
                NPCOp = `NPC_BRANCH_BGTZ; 
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_ZERO;  // zero
                ToReg = `ALU2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP;
                EXTOp = 1'b1; 
                ALUOp = `ALU_SUB;
            end
            `BLEZ:  begin
                // BLEZ
                NPCOp = `NPC_BRANCH_BLEZ;  
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_ZERO;  // zero
                ToReg = `ALU2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b1;
                ALUOp = `ALU_SUB;
            end
            `BNE:  begin
                // BNE
                NPCOp = `NPC_BRANCH_BNE; 
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_REG;  // reg
                ToReg = `ALU2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b1;
                ALUOp = `ALU_SUB;
            end
            `BLTZ_BGEZ:  begin
                // BLTZ and BGEZ
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_ZERO;  // zero
                ToReg = `ALU2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                EXTOp = 1'b1;
                ALUOp = `ALU_SUB;
                if (bgez_bltz == 5'b00000) begin
                    NPCOp = `NPC_BRANCH_BLTZ; 
                end else begin
                    NPCOp = `NPC_BRANCH_BGEZ; 
                end
            end
            `J:  begin
                // J
                NPCOp = `NPC_JUMP; 
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_ZERO;  // x
                ToReg = `ALU2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_NOP;
            end
            `JAL:  begin
                // JAL
                NPCOp = `NPC_JUMP; 
                RegDst = `RD_RA;  // write into %ra
                ALUSrc = `ALUSRC_ZERO;  // x
                ToReg = `NPC2REG;  // Next PC write into %ra
                RFWr = 1'b1;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_NOP;
            end
            `LB:  begin
                // LB
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // load data from DM into reg
                RFWr = 1'b1;  
                DMRe = `DMRE_LB; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            `LBU:  begin
                // LBU
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // load data from DM into reg
                RFWr = 1'b1;  
                DMRe = `DMRE_LBU; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            `LH:  begin
                // LH
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // load data from DM into reg
                RFWr = 1'b1;  
                DMRe = `DMRE_LH; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            `LHU:  begin
                // LHU
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // load data from DM into reg
                RFWr = 1'b1;  
                DMRe = `DMRE_LHU; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            `LW:  begin
                // LW
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // write into rt
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // load data from DM into reg
                RFWr = 1'b1;  
                DMRe = `DMRE_LW; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            `SB:  begin
                // SB
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_SB; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            `SH:  begin
                // SH
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_SH; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            `SW:  begin
                // SW
                NPCOp = `NPC_PLUS4; 
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_IMM;  // offset
                ToReg = `DM2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_SW; 
                ALUOp = `ALU_ADD;  // caculate address
            end
            default:    begin
                // NOP
                $display("over");
                NPCOp = `NPC_NOP;  
                RegDst = `RD_RT;  // x
                ALUSrc = `ALUSRC_ZERO;  // x
                ToReg = `DM2REG;  // x
                RFWr = 1'b0;  
                DMRe = `DMRE_NOP; 
                DMWr = `DMWR_NOP; 
                ALUOp = `ALU_NOP; 
                ALUSrc0 = 1'b0;
            end
        endcase
    end

endmodule