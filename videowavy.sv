`timescale 1ns / 1ps

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
// some of these don't work lol - at least the color bars look good 

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

endmodule
