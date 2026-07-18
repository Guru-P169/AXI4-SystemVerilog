package axi4_pkg;

typedef enum logic [1:0] {
    RESP_OKAY   = 2'b00,
    RESP_EXOKAY = 2'b01,
    RESP_SLVERR = 2'b10,
    RESP_DECERR = 2'b11
} axi_resp_t;


typedef enum logic [1:0] {
    BURST_FIXED     = 2'b00,
    BURST_INCR      = 2'b01,
    BURST_WRAP      = 2'b10,
} axi_burst_t;

typedef enum logic [3:0]{
    CACHE_DEVICE_NON = 4'b0000,
    CACHE_DEVICE_BUF = 4'b0001,
    CACHE_NORMAL_NCNB = 4'b0010,
    CACHE_NORMAL_NCB = 4'b0011,
    CACHE_NORMAL_WT = 4'b0110,
    CACHE_NORMAL_WB = 4'b01110
    } axi_cache_t;

typedef struct packed {
    logic privileged;
    logic secure;
    logic instruction;
} axi_prot_t;

typedef struct packed{
    logic [3:0] cache;
    axi_cache_t port;
    logic [3:0] qos;
    logic [3:0] region;
    logic exclusive;
} axi_atop_t;

typedef struct packed #(parameter int AW = 32, parameter int IW = 4) {
    logic [AW-1:0] id;
    logic [AW-1:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    axi_burst_t burst;
    logic lock;
    axi_atop_t atop;
}axi_aw_chan_t;

typedef struct packed #(parameter int AW = 32 , parameter int IW = 4) {
    logic [AW-1:0] id;
    logic [AW-1:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    axi_burst_t burst;
    logic lock;
    axi_atop_t atop;
}axi_ar_chan_t;

typedef struct packed #(parameter int DW = 32, parameter int IW = 4) {
    logic [DW-1:0] data;
    logic [DW/8-1:0] strb;
    logic [IW-1:0] id;
    logic last;
    logic user;
}axi_w_chan_t;

typedef struct packed #(parameter int DW = 32 , parameter int IW = 4){
    logic [IW-1:0] id;
    logic [DW-1:0] data;
    axi_resp_t resp;
    logic last;
    logic user;
}axi_r_chan_t;

function automatic int unsigned burst_length_bytes(input logic [7:0] len, input logic [2:0] size);
   return (len + 1) * (1 << size);
endfunction

function automatic int unsigned burst_beats(input logic [7:0] len);
    return = len + 1;
endfunction

function automatic logic is_aligned (input logic [31:0] addr, input logic [2:0] size);
    return (addr & ((1 << size) - 1)) == '0;
endfunction

function automatic logic [63:0] wrap_adress(input logic [63:0] addr, input logic [63:0] start_addr,input logic [7:0] len, input logic[2:0] size);


    num_bytes = burst_length_bytes(len, size);
    wrap_boundary = (start_addr + num_bytes)*num_bytes;

    if(addr >= (warp_boundary +num_bytes)) begin
        return warp_boundary + (addr % num_bytes);
    end else begin
        return addr;
    end
endfunction

endpackage axi4_pkg;

