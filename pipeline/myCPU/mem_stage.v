`include "mycpu.h"

module mem_stage(
    input                            clk            ,
    input                            reset          ,
    //allowin
    input                           ws_allowin     ,
    output                          ms_allowin     ,
    //from es
    input                           es_to_ms_valid ,
    input  [`ES_TO_MS_BUS_WD -1:0]  es_to_ms_bus   ,
    //to ws
    output                          ms_to_ws_valid ,
    output [`MS_TO_WS_BUS_WD -1:0]  ms_to_ws_bus   ,
    // from data-sram
    input  [31:0]                  data_sram_rdata
);
reg         ms_valid   ;
wire        ms_ready_go;

reg [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus_r;//对es_to_ms_bus数据进行缓存，当数据有效且允许接收时进行更新。

wire load_op;//判断最终结果来自存储器还是运算器
wire gr_we;
wire rf_we;
wire [4: 0] dest;
wire [31:0] alu_result;
wire [31:0] mem_result;
wire [31:0] final_result;
wire [31:0] es_pc;
wire [31:0] ms_pc;
assign {load_op     ,
        gr_we       ,
        dest        , 
        alu_result  , 
        es_pc} = es_to_ms_bus_r;

assign rf_we    = gr_we;//寄存器堆的写使能
assign mem_result   = data_sram_rdata;//存储器读出的结果
assign final_result = load_op ? mem_result : alu_result;
assign ms_pc = es_pc;

assign ms_ready_go    = 1'b1;
assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_ws_valid = ms_valid && ms_ready_go;
always @(posedge clk) begin
    if (reset) begin     
        ms_valid <= 1'b0;
    end
    else if (ms_allowin) begin 
        ms_valid <= es_to_ms_valid;

    end 
    if (es_to_ms_valid && ms_allowin) begin
        es_to_ms_bus_r <= es_to_ms_bus;
    end
end

assign ms_to_ws_bus = {rf_we        ,//69:69
                       dest         ,//68:64
                       final_result ,//63:32
                       ms_pc         //31:0
                      };

endmodule