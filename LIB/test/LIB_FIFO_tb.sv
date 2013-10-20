module LIB_FIFO_tb;
  
  logic clk;
  logic reset_n;

  logic [3:0] o_data;
  logic       o_data_val;
  logic       o_en;
  logic       o_empty;
  logic       o_full;
  
  logic [3:0] i_data;
  logic       i_data_val;
  logic       i_en;
  
  LIB_FIFO #(.WIDTH(4),.DEPTH(4)) INST_LIB_FIFO (.*);
  
  initial begin
    clk = 0;
    forever #100ps clk = ~clk;
  end
  
  initial begin
    reset_n = 0;
    i_data = 4'hD;
    i_data_val = 1;
    i_en = 0;
    // Lift the reset before clk 2 so, 
    #205ps 
    reset_n = 1;
    #100ps // D is written to memory, wr_ptr increments, empty flag drops
    i_data = 4'hE;
    i_data_val = 1;
    i_en = 0;
    #200ps // E is written to memory, wr_ptr increments
    i_data = 4'hA;
    i_data_val = 1;
    i_en = 0;
    #200ps // A is written to memory, wr_ptr increments
    i_data = 4'hD;
    i_data_val = 1;
    i_en = 0;
    #200ps // D is written to memory, wr_ptr wraps, full flag lifts
    i_data = 4'hB;
    i_data_val = 1;
    i_en = 0;
    #200ps // Buffer still full, no change
    i_data = 4'hB;
    i_data_val = 1;
    i_en = 1;
    // Enable is high indicating D was read, rd_ptr increments, ouput changes to E, full flag stays high
    // because B was written to memory, wr_ptr increments, 
    #200ps 
    i_data = 4'hE;
    i_data_val = 1;
    i_en = 1;
    // Enable is high indicating E was read, rd_ptr increments, ouput changes to A, full flag stays high
    // because E was written to memory, wr_ptr increments, 
    #200ps    
    i_data = 4'hE;
    i_data_val = 1;
    i_en = 1;
    // Enable is high indicating A was read, rd_ptr increments, ouput changes to D, full flag stays high
    // because E was written to memory, wr_ptr increments, 
    #200ps    
    i_data = 4'hF;
    i_data_val = 1;
    i_en = 1;
    // Enable is high indicating D was read, rd_ptr increments, ouput changes to B, full flag stays high
    // because F was written to memory, wr_ptr increments, 
    #200ps    
    i_data = 4'h0;
    i_data_val = 0;
    i_en = 1;
    // Enable is high indicating B was read, rd_ptr increments, ouput changes to E, full flag drops
    #200ps    
    i_data = 4'h0;
    i_data_val = 1;
    i_en = 0;
    // Enable is low, valid is high, 0 is written to buffer, write pointer increments, full flag lifts
    #200ps    
    i_data = 4'h0;
    i_data_val = 0;
    i_en = 1;
    // Read E
    i_data = 4'h0;
    i_data_val = 0;
    i_en = 1;
    // Read E
    i_data = 4'h0;
    i_data_val = 0;
    i_en = 1;
    // Read F
    i_data = 4'h0;
    i_data_val = 0;
    i_en = 1;
    // Read 0
    i_data = 4'h0;
    i_data_val = 0;
    i_en = 1;
    // EMPTY!
  end
  
endmodule
  
  