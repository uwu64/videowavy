# videowavy

Bare bones VGA signal generation proof of concept using EBAZ4205 board with Xilinx Vivado. This only use the PL section of the chip

This is my first attempt at HDL - don't except anything fancy

Timings are parameterized so it should work for whatever resolution you like. My testing monitor only likes 1080p60 so I used internal PLL to generate 150 MHz pixel clock from the external 50 MHz XO 

Errata: The vertical active zone thing doesn't quite work yet. Horizontal works fine. 
Todo: Potentially do something with image buffer and rendering stuff 

![](images/videowavy-connection.jpg)

![](images/videowavy-colorbars.jpg) 

# License
This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
