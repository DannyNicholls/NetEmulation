// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : Router
// Module name : MESH_Router
// Description : Connects various modules together to create a 5 port, input buffered router
// Uses        : config.sv, LIB_PKTFIFO.sv, MESH_RouteCalculator.sv, MESH_Switch.sv, MESH_SwitchControl.sv
// Notes       : Uses the packet_t typedef from config.sv.  packet_t contains node destination information as a single
//             : number encoded as logic.  If `PORTS is a function of 2^n this will not cause problems as the logic
//             : can simply be split in two, each half representing either the X or Y direction.  This will not work
//             : otherwise.
//             : Untested.
// --------------------------------------------------------------------------------------------------------------------

`include "config.sv"

module MESH_Router

#(parameter X_NODES,
  parameter Y_NODES,
  parameter X_LOC,
  parameter Y_LOC)
 
 (input logic clk, reset_n,
  
  // Upstream Bus.
  // ------------------------------------------------------------------------------------------------------------------
  input  packet_t i_data     [0:4], // Input data from upstream [core, north, east, south, west]
  input  logic    i_data_val [0:4], // Validates data from upstream [core, north, east, south, west]
  output logic    o_en       [0:4], // Enables data from upstream [core, north, east, south, west]
  
  // Downstream Bus
  // ------------------------------------------------------------------------------------------------------------------
  output packet_t o_data     [0:4],  // Outputs data to downstream [core, north, east, south, west]
  output logic    o_data_val [0:4],  // Validates output data to downstream [core, north, east, south, west]
  input  logic    i_en       [0:4]); // Enables output to downstream [core, north, east, south, west]
  
  // Local
  // ------------------------------------------------------------------------------------------------------------------
         logic          l_en         [0:4]; // Connects switch control enable output to FIFO
         logic    [2:0] l_sel        [0:4]; // Connects switch control switch selection to switch
         packet_t       l_data       [0:4]; // Connects FIFO data outputs to switch
         logic          l_data_val   [0:4]; // Connects FIFO valid output to the route calculator
         logic    [0:4] l_output_req [0:4]; // Connects the output request of the Route Calculation to switch control
         
  // Five input FIFOs and Route Calculators, Switch and Switch Control.
  // ------------------------------------------------------------------------------------------------------------------
  generate
    for (genvar i=0; i<5; i++) begin
      LIB_pktFIFO #(.DEPTH(`FIFO_DEPTH))
        gen_LIB_pktFIFO (.clk,
                         .reset_n,
                         .i_data(i_data[i]),         // From the upstream routers
                         .i_data_val(i_data_val[i]), // From the upstream routers
                         .i_en(l_en[i]),             // From the SwitchControl
                         .o_data(l_data[i]),         // To the Switch
                         .o_data_val(l_data_val[i]), // To the route calculator
                         .o_en(o_en[i]),             // To the upstream routers
                         .o_full(),                  // Not connected
                         .o_empty(),                 // Not connected
                         .o_near_empty());           // Not connected
    end
  endgenerate
  
  generate
    for (genvar i=0; i<5; i++) begin    
      MESH_RouteCalculator #(.X_NODES(X_NODES), .Y_NODES(Y_NODES), .X_LOC(X_LOC), .Y_LOC(Y_LOC)) 
        gen_MESH_RouteCalculator (.i_x_dest(l_data[i].dest[(log2(X_NODES*Y_NODES)/2)-1:0]),           
                                  .i_y_dest(l_data[i].dest[log2(X_NODES*Y_NODES)-1:(log2(X_NODES*Y_NODES)/2)]),
                                  .i_val(l_data_val[i]),                                      // From local FIFO
                                  .o_output_req(l_output_req[i]));                            // To Switch Control
    end
  endgenerate
  
  MESH_Switch 
    inst_MESH_Switch (.i_sel(l_sel),     // From the Switch Control
                      .i_data(l_data),   // From the local FIFOs
                      .o_data(o_data));  // To the downstream routers
                                    
  MESH_SwitchControl 
    inst_MESH_SwitchControl (.clk,
                             .reset_n,
                             .i_en(i_en),                    // From the downstream router
                             .i_output_req(l_output_req),    // From the route calculator
                             .o_sel(l_sel),                  // To the Switch
                             .o_en(l_en),                    // To the local FIFOs
                             .o_val(o_data_val));            // To the downstream router

endmodule
