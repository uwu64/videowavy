`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2021 12:23:45 PM
// Design Name: 
// Module Name: videowavy
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module videowavy(
	input extclk,
	output vr,
	output vb,
	output vg,
	output hs,
	output vs
);

wire pxClock;

clk_wiz_0 TIME123 (
	.clk_in1(extclk),
	.clk_out1(pxClock)
);

// VGA videogen sandbox 
// tim@csw.cx 2021 03 
// all rights reserved 

// 1920 1080 60 
parameter hFrontPx = 88;
parameter hActivePx = 1920;
parameter hBackPx = 148;
parameter hSyncPx = 44;
parameter vFrontLn = 4;
parameter vActiveLn = 1080;
parameter vBackLn = 36;
parameter vSyncLn = 5;

/* 
//640 480 60
parameter hFrontPx = 16;
parameter hActivePx = 640;
parameter hBackPx = 48;
parameter hSyncPx = 96;
parameter vFrontLn = 11;
parameter vActiveLn = 480;
parameter vBackLn = 31;
parameter vSyncLn = 2;
*/

parameter hTotalPx = hFrontPx+hActivePx+hBackPx+hSyncPx;
parameter vTotalLn = vFrontLn+vActiveLn+vBackLn+vSyncLn;

reg [15:0] hPositionPx; 
reg [15:0] vPositionLn; 

reg [15:0] hImagePx; 
reg [15:0] vImageLn; 

wire hPxOutBound = (hPositionPx >= hTotalPx);
wire vLnOutBound = (vPositionLn >= vTotalLn);

wire hImagePxOutBound = (hPositionPx > (hTotalPx - hSyncPx - hFrontPx));
wire hImagePxPreBound = (hPositionPx <= (hBackPx));
wire vImageLnOutBound = (vPositionLn > (vTotalLn - vSyncLn - vFrontLn));
wire vImageLnPreBound = (vPositionLn <= vBackLn);

// image generation stuff 
reg [8:0] konnichiwa; // how many frames elapsed 
reg [8:0] secs_daisuki; // how many seconds elapsed 
wire konniBound = (konnichiwa >= 60); // fps 
wire secsBound = (secs_daisuki >= 9); // loop duration in seconds 

always @ (posedge pxClock) 
if (hPxOutBound) begin 
	hPositionPx = 0; 					// horizontal bound 
	if (vLnOutBound) begin 
		vPositionLn = 0; 				// vertical bound 
		if (konniBound) begin 
			konnichiwa = 0;
			if (secsBound) begin 
				secs_daisuki = 0;
			end else 
				secs_daisuki = secs_daisuki + 1;
		end else 
			konnichiwa = konnichiwa + 1;
	end else 
		vPositionLn = vPositionLn + 1; 	// vertical increment 
end else 
	hPositionPx = hPositionPx + 1; 		// horizontal increment 

wire hSyncActive = (hPositionPx >= (hTotalPx - hSyncPx)); // horizontal sync 
wire vSyncActive = (vPositionLn >= (vTotalLn - vSyncLn)); // vertical sync 

wire hImageValid = (!hImagePxPreBound && !hImagePxOutBound);
wire vImageValid = (!vImageLnPreBound && !vImageLnOutBound);
wire imageValid = vImageValid && hImageValid;

always @ (posedge pxClock) 
if (!hImageValid) begin
	hImagePx = 0;
	if (!vImageValid) begin 
		vImageLn = 0;
	end else  
		vImageLn = vImageLn + 1;
end else 
	hImagePx = hImagePx + 1;

assign hs = ~hSyncActive;
assign vs = ~vSyncActive;

reg [2:0] redd;
reg [2:0] bluee;
reg [2:0] greenn;

assign vr = (redd && imageValid);
assign vg = (greenn && imageValid);
assign vb = (bluee && imageValid);

// image generation

always @ (posedge pxClock) begin
	case (secs_daisuki)
		0, 1: begin // color bars
			redd = (hImagePx % 200) < 100;
			greenn = (hImagePx % 400 < 200);
			bluee = (hImagePx % 800) < 400;
		end 
		2, 3: begin // super tight pattern 
			redd = ((hImagePx % 2) == 1);
			greenn = ((hImagePx % 2) == 1);
			bluee = ((hImagePx % 2) == 1);
		end 
		4, 5: begin 
			redd = ~((vImageLn % 10) && (hImagePx % 10));
			greenn = ~((vImageLn % 10) && (hImagePx % 10));
			bluee = ~((vImageLn % 10) && (hImagePx % 10));
		end 
		6, 7: begin 
			redd = ((hImagePx + vImageLn) % 10) < 5;
			greenn = ((hImagePx + vImageLn) % 10) < 5;
			bluee = ((hImagePx + vImageLn) % 10) < 5;
		end 
		8, 9: begin 
			redd = ((hImagePx > 300) && (hImagePx < 600) && (vImageLn > 300) && (vImageLn < 600));
			greenn = ((hImagePx > 300) && (hImagePx < 600) && (vImageLn > 300) && (vImageLn < 600));
			bluee = ((hImagePx > 300) && (hImagePx < 600) && (vImageLn > 300) && (vImageLn < 600));
		end 
	endcase 
end




/* take 1 this shit didnt work lmao 

`define hPxBackP 48 
`define hPxActive 640
`define hPxFrontP 16
`define hPxSync 2

`define vPxBackP 33 
`define vPxActive 480
`define vPxFrontP 10
`define vPxSync 2

reg [15:0] hPos;
reg [15:0] vPos;

reg [15:0] hImage;
reg [15:0] vImage;

wire localPxClk = extclk; // pixel clock 25.175 MHz 

wire hBlankingActive = ((hPos <= `hPxBackP) || (hPos > `hPxBackP+`hPxActive)); // active during horizontal blanking 
wire vBlankingActive = ((hPos <= `vPxBackP) || (hPos > `vPxBackP+`vPxActive)); // active during vertical blanking 

wire hImageActive = ((vPos > `vPxBackP) || (vPos <= `vPxBackP+`vPxActive)); // active during horizontal image 
wire vImageActive = ((hPos > `vPxBackP) || (hPos <= `vPxBackP+`vPxActive)); // active during vertical image 

wire hSyncActive = (hPos > (`hPxBackP+`hPxActive+`hPxFrontP)); // active after beginning of sync 
wire vSyncActive = (vPos > (`vPxBackP+`vPxActive+`vPxFrontP)); 

wire hOutBound = (hPos > (`hPxBackP+`hPxActive+`hPxFrontP+`hPxSync)); // active past horizontal line 
wire vOutBound = (vPos > (`vPxBackP+`vPxActive+`vPxFrontP+`vPxSync)); // active past vertical line 

wire hImageInBound = (hPos > (`hPxBackP) && hPos < (`hPxBackP+`hPxActive)); // active during horizontal image 
wire vImageInBound = (vPos > (`vPxBackP) && vPos < (`vPxBackP+`vPxActive)); // active during vertical image 

always @ (posedge localPxClk) // horizontal position bound and vertical increment and horizontal increment 
if (hOutBound) begin
	hPos = 0;
	vPos = vPos + 1;
end else 
	hPos = hPos + 1; 

always @ (posedge localPxClk) if (vOutBound) vPos = 0; // vertical position bound 

always @ (posedge localPxClk) if (hImageInBound) hImage = hImage + 1; // horizontal image increment 
always @ (posedge localPxClk) if (hImage>`hPxActive) begin hImage = 0; vImage = vImage + 1; end // horizontal image bound and vertical increment 

assign hs = ~hSyncActive; // output sync, active low 
assign vs = ~vSyncActive; 

// image generation

assign vg = (hImage < 100);

*/









endmodule












