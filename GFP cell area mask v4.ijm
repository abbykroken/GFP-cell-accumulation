//tidy up and set measurements
run("Set Measurements...", "area mean redirect=None decimal=3");
run("Clear Results");
run("Bio-Formats Macro Extensions");

//User selects source directory and output directory.
source_dir = getDirectory("Select source directory")
output_dir = getDirectory("Select output directory")
file_list = getFileList(source_dir);

setBatchMode(true);

for(a=0; a<file_list.length; a++){
	if(endsWith(file_list[a],  ".nd2")){
		run("Bio-Formats Importer", "open=[" + source_dir + file_list[a] + "] autoscale color_mode=Composite concatenate_series open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

			//duplicate GFP channel 1 and make a mask with stack threshold
			run("Duplicate...", "title=gfp duplicate channels=1");
			run("Duplicate...", "title=[gfp mask] duplicate channels=1");
			setAutoThreshold("Triangle dark stack");
			run("Convert to Mask", "method=Triangle background=Dark create");
			
			//remove tiny particles smaller than a cell, size may require adjustment depending on magnification. 
			run("Analyze Particles...", "size=10-infinity show=Masks stack");  
			
			//make mask and apply to to GFP channel
			imageCalculator("Divide create 32-bit stack", "Mask of MASK_gfp mask","Mask of MASK_gfp mask");
			imageCalculator("Divide create 32-bit stack", "gfp","Result of Mask of MASK_gfp mask");
	
			//measure area and GFP intensity in each frame
			getDimensions(width, height, channels, slices, nframes);
			for (i = 0; i < nframes; i++) {
			
			Stack.setFrame(i);
			run("Measure");
			
			}
			//save results window as csv
			selectWindow("Results");
			saveAs("Results", output_dir + file_list[a] + ".csv");
			
			run("Clear Results");
			
			//save GFP mask as tif
			selectWindow("Mask of MASK_gfp mask");
			saveAs("Tiff", output_dir + file_list[a] + ".tif");
			
			close("*");
			
	}
}			
			