`include "mycpu.h"

module exe_stage(
    input                            clk            ,
    input                            reset          ,
    //allowin
    input                           ms_allowin     ,
    output                          es_allowin     ,
    //from ds
    input                           ds_to_es_valid ,
    input  [`DS_TO_ES_BUS_WD -1:0]  ds_to_es_bus   ,
    //to ms
    output                          es_to_ms_valid ,
    output [`ES_TO_MS_BUS_WD -1:0]  es_to_ms_bus   ,
    // data sram interface
    output                          data_sram_en   ,
    output  [3:0]                   data_sram_wen  ,
    output  [31:0]                  data_sram_addr ,
    output  [31:0]                  data_sram_wdata
);

reg         es_valid   ;
wire        es_ready_go;

reg [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus_r;//对ds_to_es_bus数据进行缓存，当数据有效且允许接收时进行更新。

//获取ds_to_es_bus 数据

wire [11:0] alu_op;
wire        load_op;
wire        src1_is_pc;
wire        src2_is_imm;
wire        gr_we;
wire        mem_we;
wire [4: 0] dest;
wire [31:0] rj_value;
wire [31:0] rkd_value;
wire [31:0] ds_imm;
wire [31:0] ds_pc;
wire [31:0] alu_src1;
wire [31:0] alu_src2;
wire [31:0] alu_result;
wire [31:0] es_pc;
assign {alu_op      ,  //149:138
        load_op     ,  //137:137
        src1_is_pc  ,  //136:136
        src2_is_imm ,  //135:135
        gr_we       ,  //134:134
        mem_we      ,  //133:133
        dest        ,  //132:128
        ds_imm      ,  //127:96
        rj_value    ,  //95 :64
        rkd_value   ,  //63 :32
        ds_pc          //31 :0
        } = ds_to_es_bus_r;
//执行、运算
assign alu_src1 = src1_is_pc  ? ds_pc[31:0] : rj_value;
assign alu_src2 = src2_is_imm ? ds_imm : rkd_value;

alu u_alu(
    .alu_op     (alu_op    ),
    .alu_src1   (alu_src1  ),
    .alu_src2   (alu_src2  ),
    .alu_result (alu_result)
    );

assign data_sram_en = ds_to_es_valid && es_allowin;//判断写入存储器的值是否有效
assign data_sram_wen    = {4{mem_we}};//存储器的写使能，只有全一和全零两个值，全一时进行写操作
assign data_sram_addr  = alu_result;
assign data_sram_wdata = rkd_value;

//流水线获取缓存数据
assign es_ready_go    = 1'b1;
assign es_allowin     = !es_valid || es_ready_go && ms_allowin;
assign es_to_ms_valid = es_valid && es_ready_go;
always @(posedge clk) begin
    if (reset) begin     
        es_valid <= 1'b0;
    end
    else if (es_allowin) begin 
        es_valid <= ds_to_es_valid;
    end 
    if (ds_to_es_valid && es_allowin) begin
        ds_to_es_bus_r <= ds_to_es_bus;
    end
end
//发送数据
assign es_pc = ds_pc;
assign es_to_ms_bus = {load_op     ,  //70:70
                       gr_we       ,  //69:69
                       dest        ,  //68:64
                       alu_result  ,  //63:32
                       es_pc          //31 :0
                      };

endmodule
