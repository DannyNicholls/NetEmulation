// Recirmulation tx for speculative network(scheme 1)
// Assume a transmitter specific to speculative network
// Shiyun Liu 7/2013

`include "config.sv"

module tx_recirc (
  output  req_t                         req,
  output  packet_t                      dout,
  output  logic                         full_out,
  input   packet_t                      din,
  input   grant_t                       grant,
  input   logic                         clk,
  input   logic                         rst,
  input   logic                         full_in,
  input   logic                         nearly_full_in);
  
  /////////////////////////////////////////////////
  // Start definition of Virtual Channel Tx (not needed for recirc)
  /////////////////////////////////////////////////
/*  `ifdef VC  
  
  // Internal signals
  logic       [`PORTS-1:0]    full_int;
  packet_t    [`PORTS-1:0]    fifo_out;
  logic       [`PORTS-1:0]    empty;      // Empty signal not needed!?
  logic       [log2(`PORTS):0]      grant_buf;
  logic       [`PORTS-1:0]    we;
  logic       [`PORTS-1:0]    re;
  logic       [`PORTS-1:0]    nearly_full;
  
  // generate FIFOs for VC queues
  generate
      for (genvar h=0;h<`PORTS;h++) begin
          fifo_pkt #(`FIFO_DEPTH, 0) input_fifos (  // is 0 correct?
            .din(din),
            .wr_en(we[h]),
            .rd_en(re[h]),
            .dout(fifo_out[h]),
            .full(full_int[h]),
            .empty(empty[h]),          // Empty signal not needed!?
            .nearly_empty(),
            .nearly_full(nearly_full[h]),
            .clk(clk),
            .reset(rst));
      end
  endgenerate
  
  // FIFO Control Logic
  always_comb begin      
    we = 0;
    re = 0; 
    for (int k=0;k<`PORTS;k++) begin
      // FIFO write enable logic
      if (din.valid && (din.dest==k))// && (!full_int[din.dest])) begin
        we[k] = 1;
      // FIFO read enable logic
      if (grant_buf[log2(`PORTS)] && (grant_buf[log2(`PORTS)-1:0]==k))
        re[k] = 1;
    end 
  end
  
  // FIFO full control
   always_comb begin
      full_out = 0;
      if (full_int[din.dest])
        full_out = 1;
   end
  
  // Request Logic
  always_ff @(posedge clk)
    if (rst) 
      req <= 0;
    else
      req <= {(din.valid && (!full_int[din.dest])), din.dest};
  
  // Grant Logic
  always_ff @(posedge clk)
    if (rst) begin
      dout.data <= 0;
      dout.valid <= 0;
      dout.dest <= 0;
      dout.source <= 0;
    end else if (grant_buf[log2(`PORTS)]) begin
      dout <= fifo_out[grant_buf[log2(`PORTS)-1:0]];
      dout.valid <= 1;
    end else
      dout.valid <= 0; 
  
  // Buffer grant signal
  always_ff @(posedge clk)
    if (rst)
      grant_buf <= 0;
    else
      grant_buf <= grant;
*/  
  /////////////////////////////////////////////////
  // Start definition of Single FIFO Tx
  /////////////////////////////////////////////////
  //`else
  
  // Internal signals
  logic       full_int;
  logic       full_tx;
  packet_t    fifo_out;
  packet_t    dout_int;
  logic       empty;
  logic       empty_buf;
  grant_t     grant_buf;
  logic       re, we;
  logic [log2(`SLOT_SIZE):0] count;
  
   // Input FIFO
  fifo_pkt #(`FIFO_DEPTH, 0) input_fifo (
        .din(din),
        .wr_en(we),
        .rd_en(re),
        .dout(fifo_out),
        .full(full_int),
        .empty(empty),
        .nearly_empty(),
        .clk(clk),
        .reset(rst));
        
 //To make sure requests are sent under the interval of slot sizes  
     always_ff @(posedge clk)   
     if(rst) begin 
     count <= `SLOT_SIZE;
     end 
     else begin
       if(req.valid && (count == `SLOT_SIZE)) begin count <= 1; end
       else if(count!=`SLOT_SIZE) count<=count+1;
       else count <= count;
       end   
       
                
  // Register output data
  always_ff @(posedge clk)
    if (rst) begin
      dout.data <= 0;
      dout.valid <= 0;
      dout.dest <= 0;
      dout.source <= 0;
    end else begin
    if ((!empty)&&(count==`SPECULATIVE_DELAY)&&(!nearly_full_in)) begin
    dout <= fifo_out ;
    dout.valid <= 1;
    end 
    else
      dout.valid <= 0;  
    end
       
  // Shift register for data to simulate TOF
  //sr_packet #(`TOF+1) send_delay (dout, dout_int, clk);
  
  // Register full and grant signals
/*  always_ff @(posedge clk)
    if (rst) begin
      empty_buf  <= 0;
      //grant_buf <= 0;
    end else begin
      empty_buf  <= empty;
      //grant_buf <= grant[0];
    end */
  
  // Generate requests
  always_comb begin
    req.valid = ((!empty)&&(count==`SLOT_SIZE));
    req.port  = fifo_out.dest;
  end
        
  // Transfer internal to external signals
  assign full_out = full_int;
  assign re = (!empty)&&(count==`SPECULATIVE_DELAY)&&(!nearly_full_in);
  assign we = din.valid;  // && (!full_int); Don't think this is necessary!
  
//`endif  // End definition of single FIFO Tx

endmodule