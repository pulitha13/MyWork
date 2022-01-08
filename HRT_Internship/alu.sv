`default_nettype none
`timescale 1ns/1ns
`define OR_       4'h0
`define XOR_      4'h1
`define AND_      4'h2
`define NOT_      4'h3
`define LSHIFT_   4'h4
`define RSHIFT_   4'h5
`define ARSHIFT_  4'h6
`define ADD_      4'h7
`define ADDC_     4'h8
`define SUB_      4'h9
`define LOADLO_   4'hA
`define LOADHI_   4'hB
`define OUT_      4'hC
`define HALT_     4'hD

module alu
  #(parameter int data_width = 12,
    parameter int instruction_width = 12)
   (// A rising edge should trigger clocked logic
    input wire clk,

    // Active high reset
    input wire                         rst,

    // Instructions for the ALU to perform, a new instruction will be
    // given each clock cycle.
    input wire [instruction_width-1:0] instruction,

    // Data output from the ALU, its value is considered undefined if
    // out_valid is deasserted.
    output logic [data_width-1:0]      out_data,
    output logic                       out_valid,

    // Stop execution if asserted
    output logic                       halt);

    // The ALU should have four 12 bits general purpose register.
    localparam int num_registers = 4;

    // Your code here...
    localparam int op_msb = 11; //op-code bits of instruction
    localparam int op_lsb = 8;
    localparam int rd_msb = 7;  //Rd (Result Reg) bits of instruction
    localparam int rd_lsb = 6;
    localparam int rx_msb = 5;  //Rx (Operand1 Reg) bits of instruction
    localparam int rx_lsb = 4;
    localparam int ry_msb = 3;  //Ry (Operand2 Reg) bits of instruction
    localparam int ry_lsb = 2;
    localparam int imm_msb = 5; //Immediate bits of instruction
    localparam int imm_lsb = 0;

    localparam int imm_width = imm_msb-imm_lsb + 1;         //# of bits used to rep imm
    localparam int reg_sel_width = rx_msb-rx_lsb + 1;   //# of bits used to rep registers
    localparam int op_width = op_msb-op_lsb + 1;         //# of bits used to rep operation

    reg [data_width-1:0] registers [num_registers-1:0]; // [0] = R0 ... [3] = R3

    reg [data_width:0] result_reg;   //temp storage of output for operation before loading reg + extra bit for carry
    reg [reg_sel_width-1:0] rd_reg;  //temp storage of location to store output
    reg [op_width-1:0] op_reg;       //temp storage of last operation
    reg valid_reg;                   //temp storage of output_valid 
    reg halt_reg;                    //temp storage of output_valid

    wire [op_width-1:0] op_code = instruction[op_msb:op_lsb]; 
    wire [reg_sel_width-1:0] rd = instruction[rd_msb:rd_lsb];
    wire [reg_sel_width-1:0] rx = instruction[rx_msb:rx_lsb];
    wire [reg_sel_width-1:0] ry = instruction[ry_msb:ry_lsb];
    wire [imm_width-1:0] imm = instruction[imm_msb:imm_lsb];

    
    wire [data_width-1:0] t_operand1; //operands and destinations based on rx,ry,rd
    wire [data_width-1:0] t_operand2;
    wire [data_width-1:0] t_dest;
    wire [data_width-1:0] operand1;  //actual operands and destinations after fwd circuits (checking if last op altered the operands/destinations)
    wire [data_width-1:0] operand2;
    wire [data_width-1:0] dest;

    register_mux op1 (.registers(registers), .sel(rx), .out(t_operand1));
    register_mux op2 (.registers(registers), .sel(ry), .out(t_operand2));
    register_mux d (.registers(registers), .sel(rd), .out(t_dest));

    fwd_c fwd_op1 (.from_reg(t_operand1), .from_result(result_reg[data_width-1:0]), .input_reg(rx), .old_output_reg(rd_reg), .old_opcode(op_reg), .out(operand1));
    fwd_c fwd_op2 (.from_reg(t_operand2), .from_result(result_reg[data_width-1:0]), .input_reg(ry), .old_output_reg(rd_reg), .old_opcode(op_reg), .out(operand2));
    fwd_c fwd_dest (.from_reg(t_dest), .from_result(result_reg[data_width-1:0]), .input_reg(rd), .old_output_reg(rd_reg), .old_opcode(op_reg), .out(dest));

    always @(posedge clk, posedge rst)
    begin

      if (rst) 
      begin
        //Default reset every register to zero
        registers [0] <= {data_width{1'b0}};
        registers [1] <= {data_width{1'b0}};
        registers [2] <= {data_width{1'b0}};
        registers [3] <= {data_width{1'b0}};
        result_reg <= {(data_width+1){1'b0}};
        valid_reg <= 0;
        halt_reg <= 0;  
        rd_reg <= {reg_sel_width{1'b0}};
        op_reg <= {op_width{1'b0}};

      end else
      begin
        
        //Update temp rd/op registers
        rd_reg <= rd;
        op_reg <= op_code;

        //Update temporary result register and carry
        case (op_code)
          `OR_      : result_reg[data_width-1:0] <= operand1 | operand2;  
          `XOR_     : result_reg[data_width-1:0] <= operand1 ^ operand2; 
          `AND_     : result_reg[data_width-1:0] <= operand1 & operand2; 
          `NOT_     : result_reg[data_width-1:0] <= ~operand1;
          `LSHIFT_  : result_reg[data_width-1:0] <= operand1 << 1;
          `RSHIFT_  : result_reg[data_width-1:0] <= operand1 >> 1;
          `ARSHIFT_ : result_reg[data_width-1:0] <= $signed(operand1) >>> 1;
          `ADD_     : result_reg <= {1'b0, operand1} + {1'b0, operand2};
          `ADDC_    : result_reg <= {1'b0, operand1} + {1'b0, operand2} + result_reg[data_width];
          `SUB_     : result_reg[data_width-1:0] <= operand1 - operand2; 
          `LOADLO_  : result_reg[data_width-1:0] <= {dest[data_width-1:data_width-imm_width], imm};
          `LOADHI_  : result_reg[data_width-1:0] <= {imm, dest[imm_width-1:0]};
          `OUT_     : result_reg[data_width-1:0] <= operand1; 
          `HALT_    : result_reg[data_width-1:0] <= operand1; 
        endcase

        //Update the temp valid/halt registers
        case (op_code)
          `OUT_:    begin valid_reg <= 1'b1; halt_reg <= 1'b0; end
          `HALT_:   begin valid_reg <= 1'b1; halt_reg <= 1'b1; end
          default:  begin valid_reg <= 1'b0; halt_reg <= 1'b0; end
        endcase

        //Update final register based on prev rd/opcode stored in rd_reg/op_reg
        case (op_reg)
          `OUT_ : out_data <= result_reg[data_width-1:0];
          `HALT_: out_data <= result_reg[data_width-1:0];
          default: begin
            case (rd_reg)
              2'b00: registers[0] <= result_reg[data_width-1:0];
              2'b01: registers[1] <= result_reg[data_width-1:0];
              2'b10: registers[2] <= result_reg[data_width-1:0];
              2'b11: registers[3] <= result_reg[data_width-1:0]; 
            endcase   
          end
        endcase

        //Update final valid/halt outputs based on valid_reg/halt_reg
        case (op_reg)
          `OUT_:    begin out_valid <= valid_reg; halt <= halt_reg; end
          `HALT_:   begin out_valid <= valid_reg; halt <= halt_reg; end 
          default:  begin out_valid <= valid_reg; halt <= halt_reg; end
        endcase

      end

    end

endmodule

/*
Output is data from selected register
Input is data from all registers and select line
*/
module register_mux #(
  parameter data_width = 12,
  parameter num_registers = 4,
  parameter reg_sel_width = 2
) (
  input wire [data_width-1:0] registers [num_registers-1:0],
  input wire [reg_sel_width-1:0] sel,
  output wire [data_width-1:0] out);

  assign out = sel[1] ? (sel[0] ? registers[3] : registers[2]) : (sel[0] ? registers[1] : registers[0]);
  
endmodule
/*
//Output is proper operand based on whether we have data dependecy hazard
//Input is data from register (data), data from last result calculated (data), input register for current operation (reg),
            last output destination (reg), and last operation code (operation) 
*/           
module fwd_c #(
  parameter data_width = 12,
  parameter op_width = 4,
  parameter reg_sel_width = 2
) (
  input wire [data_width-1:0] from_reg,
  input wire [data_width-1:0] from_result,
  input wire [reg_sel_width-1:0] input_reg,
  input wire [reg_sel_width-1:0] old_output_reg,
  input wire [op_width-1:0] old_opcode,
  output wire [data_width-1:0] out
);
  
  assign out = ((old_opcode != `OUT_) && (old_opcode != `HALT_) && (old_output_reg == input_reg)) ? from_result : from_reg;

endmodule

//Joshua Mathew 
//Icarus Verilog version 10.3 (stable) ()

/*

Question 1: There are no NOP (don’t change any register values) or CLEAR (set a register to 0) instructions specified, how can
we perform these operations with the instructions we have available to us?

Ans: For the NOP we can use an OR operation and perform RX = RX OR RX which will "update" RX to whatever RX already had, thus effectively not
changing any register values. We actually see this in the instruction set given by test.hex where the first four instructions are NOPS doing this 
OR operation on each register. For a CLEAR operation on desired register RX we can perform RX = RX XOR RX which will set RX to 12'b0.

Question 2: How did you test your design?

Ans: To test I first tested the output of the design using instructions from test.hex and compared it to the test_reference output. Once they matched, I
then created a single stage ALU design which I also tested with instructions from test.hex. I then compared the outputs of my single stage ALU to the outputs
of my two stage ALU based of instructions from secret.hex. Once these two matched I ended testing. 

Note: I also used Quartus/Modelsim instead of Icarus/GTKWave for most of my testing since I already had Quartus installed, but I compiled and ran the ALU
(two stage) on Icarus and it seemed to work fine on my end.

*/
// DO NOT REMOVE THE FOLLOWING LINES OR PUT ANY CODE/COMMENTS AFTER THIS LINE
// hw_intern_test-20211014.zip
// f8bca07d96076ae1722bbdd9fb32c5aef1860677
