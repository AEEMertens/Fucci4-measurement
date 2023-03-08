		run("Close All");
		ZProjString = "Average Intensity";

		nTimesSmooth=3;
		PrintStringsToLog=0;
		
		//  first we have to know whether the required directories exist 
		Mac=0; FileSeparator = File.separator; if(FileSeparator=="/"){Dialog.create(" "); Dialog.addCheckbox("Running on a Mac ?", 1); Dialog.show(); Mac = Dialog.getCheckbox();}else{print("this is a PC");}
		FileSeparator = FileSeparator + FileSeparator;	
		//  and for the xls
		Separator 	= "; ";
															DumpLocation		= "D:"+FileSeparator+"ANALYSIS DUMP"+FileSeparator;
															ResultDump			= "Fucci4 Sanderdt"+FileSeparator;
															ImageJDirectory		= getDirectory("imagej");	
															File.makeDirectory(DumpLocation);
															File.makeDirectory(DumpLocation+ResultDump);
														

 
		if(isOpen("ROI Manager")){selectWindow("ROI Manager");run("Close");}	run("ROI Manager...");
		run("Set Measurements...", "area mean limit redirect=None decimal=3");

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		print("");  waitForUser("Choose file in folder   "); print(""); 
		open();		dir = File.directory();  	name = File.name();											 
		
					if(indexOf(dir,"_01")!=-1){ PosNumber=1; }		// dmso
					if(indexOf(dir,"_02")!=-1){ PosNumber=2; }
					if(indexOf(dir,"_03")!=-1){ PosNumber=3; }
					if(indexOf(dir,"_04")!=-1){ PosNumber=4; }
					if(indexOf(dir,"_05")!=-1){ PosNumber=5; }

					if(indexOf(dir,"_11")!=-1){ PosNumber=11; }	// triple
					if(indexOf(dir,"_12")!=-1){ PosNumber=12; }
					if(indexOf(dir,"_13")!=-1){ PosNumber=13; }
					if(indexOf(dir,"_14")!=-1){ PosNumber=14; }
					if(indexOf(dir,"_15")!=-1){ PosNumber=15; }
					if(indexOf(dir,"_16")!=-1){ PosNumber=16; }
					if(indexOf(dir,"_17")!=-1){ PosNumber=17; }
					if(indexOf(dir,"_18")!=-1){ PosNumber=18; }
					if(indexOf(dir,"_19")!=-1){ PosNumber=19; }
					if(indexOf(dir,"_20")!=-1){ PosNumber=20; }

					if(indexOf(dir,"_21")!=-1){ PosNumber=21; }	// VINO
					if(indexOf(dir,"_22")!=-1){ PosNumber=22; }
					if(indexOf(dir,"_23")!=-1){ PosNumber=23; }
					if(indexOf(dir,"_24")!=-1){ PosNumber=24; }
					if(indexOf(dir,"_25")!=-1){ PosNumber=25; }
		run("Close All");

		list = getFileList(dir);																										 
		TitleArray=newArray(list.length-1);																					 
		
		for(j=0;j<list.length;j++){
			open(dir+list[j]);	
			Temp=getTitle();																										 
			if(indexOf(Temp,".tif")!=-1){TitleArray[j]	=Temp;		getDimensions(width, height, channels, slices, frames);		}	 
			if(indexOf(Temp,".avi")!=-1){DepthTitle		=Temp;}																		 
																			 
			if(slices>frames){S_Temp=slices;  F_Temp=frames;  slices=F_Temp;  frames=S_Temp; }
		}    
		Array.print(TitleArray);	
		run("Tile");

					ArrayEventNumber	=newArray(1000);
					ArraySliceNumber	=newArray(1000);
					ArrayX				=newArray(1000);
					ArrayY				=newArray(1000);
					//
					ArrayCellChannel1	=newArray(1000);
					ArrayCellChannel2	=newArray(1000);
					ArrayCellChannel3	=newArray(1000);
					ArrayCellChannel4	=newArray(1000);
					//
					ArrayPlaneChannel1	=newArray(1000);
					ArrayPlaneChannel2	=newArray(1000);
					ArrayPlaneChannel3	=newArray(1000);
					ArrayPlaneChannel4	=newArray(1000);
					//
					ArrayTimeLapseChannel1	=newArray(frames);
					ArrayTimeLapseChannel2	=newArray(frames);
					ArrayTimeLapseChannel3	=newArray(frames);
					ArrayTimeLapseChannel4	=newArray(frames);
					//
					EventNumber=1;			// refers to events in the ANALYZED depth coded movies

									// find the contours of the organoid based on H1-mMaroon signal
									selectWindow(TitleArray[TitleArray.length-1]);		// i.e. select  H1-mMaroon
									// 							
									run("Duplicate...", "title=[Smoothed] duplicate");			for(k=0;k<nTimesSmooth;k++){run("Smooth", "stack");}
									// project time
									run("Z Project...", "projection=[Max Intensity]");			rename("MaxProj");		getMinAndMax(min,max); 	close("MaxProj");
							
									selectWindow("Smoothed");
									run("Z Project...", "projection=["+ZProjString+"]");		rename("TimeProj");		
									run("Threshold..."); 	setAutoThreshold("Huang dark");	  	setAutoThreshold("Huang");				
									run("Tile");
									print("");waitForUser("zet de threshold maar 's effe \n \n  max "+max);print("");
									getThreshold(LowerThreshold, UpperThreshold);
 
									nROIsBefore = roiManager("count");		selectWindow("Log");   setLocation(1,1);
		
									for(k=0;k<frames-1;k++){
										selectWindow("Smoothed"); 	setSlice(k+1);
										setAutoThreshold("Default dark"); setThreshold(UpperThreshold , max*1.1);	selectWindow("Threshold"); 	selectWindow("Smoothed"); 
										run("Create Selection"); roiManager("Add");  
										roiManager("Deselect");  	roiManager("Select", nROIsBefore + k); 	roiManager("rename", "contour t"+k+1);						 
									}
									close("Smoothed");
									close("TimeProj");
									// now readout in the relevant channels
									for(j=0;j<TitleArray.length;j++){
										selectWindow(TitleArray[j]);	 
										for(k=0;k<frames-1;k++){
											roiManager("Deselect"); roiManager("Select",nROIsBefore + k); setSlice(k+1); 				if(k<0){print("");waitForUser("k = "+k+" \n\n roi en slicenumbner  ok?    deze gaat weg");print("");}	
											run("Measure"); 
											if(j==0){	ArrayTimeLapseChannel1[k] = getResult("Mean", nResults-1);	}
											if(j==1){	ArrayTimeLapseChannel2[k] = getResult("Mean", nResults-1);	}
											if(j==2){	ArrayTimeLapseChannel3[k] = getResult("Mean", nResults-1);	}
											if(j==3){	ArrayTimeLapseChannel4[k] = getResult("Mean", nResults-1);	}
 										}
 										run("Select None"); setSlice(1);
									}
		Go=1;
		EventCounter=0;
		while(Go){
				run("Tile");

				E=EventCounter;
				selectWindow(DepthTitle); setLocation(1,1); run("Set... ", "zoom=250");
				print("_");  waitForUser("search event in the depth-coded movie \n \n  and set the time point in the depth coded movie"); 
				selectWindow(DepthTitle); ThisSlice=getSliceNumber;
				for(i=0;i<TitleArray.length;i++){selectWindow(TitleArray[i]);setSlice(ThisSlice); run("Set... ", "zoom=150");}
				Dialog.create(" ");	Dialog.addNumber("Event Number", EventNumber , 0 , 4 , ""); 	Dialog.show();	EventNumber  = Dialog.getNumber();		
				run("Tile");
								ArrayEventNumber[E] = EventNumber;
								ArraySliceNumber[E] = ThisSlice;

								ArrayPlaneChannel1[E] = ArrayTimeLapseChannel1[nROIsBefore + ThisSlice-1];
								ArrayPlaneChannel2[E] = ArrayTimeLapseChannel2[nROIsBefore + ThisSlice-1];
								ArrayPlaneChannel3[E] = ArrayTimeLapseChannel3[nROIsBefore + ThisSlice-1];
								ArrayPlaneChannel4[E] = ArrayTimeLapseChannel4[nROIsBefore + ThisSlice-1];
		 		
				print("_");  waitForUser("draw ROI in cell-of-interest to readout fluorescence (in 4 channels) \n \n             in any of the fluo windows");
				roiManager("Add");	ThisCellROI = roiManager("count") - 1;
				getSelectionBounds(x,y,Width,Height);			
								ArrayX[E] = x+0.5*Width;
								ArrayY[E] = y+0.5*Height;
				for(j=0;j<TitleArray.length;j++){
					selectWindow(TitleArray[j]);	roiManager("Deselect"); roiManager("Select",ThisCellROI); 
					run("Measure"); 
					if(j==0){	ArrayCellChannel1[E] = getResult("Mean", nResults-1);}
					if(j==1){	ArrayCellChannel2[E] = getResult("Mean", nResults-1);}
					if(j==2){	ArrayCellChannel3[E] = getResult("Mean", nResults-1);}
					if(j==3){	ArrayCellChannel4[E] = getResult("Mean", nResults-1);}
					roiManager("Deselect");  	roiManager("Select", ThisCellROI); 	roiManager("rename", "Event #"+EventNumber+"__(t"+ThisSlice+")");
					run("Select None");
				}
			EventCounter++;																																													 

			
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			
			//    NOW store in Strings
			//    NOW store in Strings
				nDecimals =2;																																			 
				//  Define The Array-Of-PrintStrings
				PrintStringArray = newArray(6+frames);
				PrintStringArray[0] = "Experiment : Sander's Fucci4 in p9T";
				PrintStringArray[1] = "";
			
			for(i=0 ; i<frames-1 ; i++){
				ArrayForHeaderString1 	= newArray(1010); 	// first  of 2 lines in xls file
				ArrayForHeaderString2 	= newArray(1010); 	// second of 2 lines in xls file 	
				ArrayForHeaderString3 	= newArray(1010); 	// second of 2 lines in xls file 	
				ArrayForPrintString  	= newArray(1010);
				RecognizeSpaces = "   ";  //  3 times spacebar ; after the remark-column
				
				///  a = column	(consecutive parameters
				///  i = row  	(consecutive events)  
				///  Position and EventNumber are always The First Two. The others, just put them in the order you like, and it will work					
					a = 0;	if(i==0){ArrayForHeaderString1[a]="time";			ArrayForHeaderString2[a]="point";			ArrayForHeaderString3[a]="    ";}										ArrayForPrintString[a] = toString(i+1);				
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="mean fluo";		ArrayForHeaderString2[a]="(organoid)";		ArrayForHeaderString3[a]="Clover-Geminin";}								ArrayForPrintString[a] = d2s(ArrayTimeLapseChannel1[i], nDecimals);				
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="mean fluo";		ArrayForHeaderString2[a]="(organoid)";		ArrayForHeaderString3[a]="mKO2-Cdt1";}									ArrayForPrintString[a] = d2s(ArrayTimeLapseChannel2[i], nDecimals);				
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="mean fluo";		ArrayForHeaderString2[a]="(organoid)";		ArrayForHeaderString3[a]="mTurq-SLBP";}									ArrayForPrintString[a] = d2s(ArrayTimeLapseChannel3[i], nDecimals);				
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="mean fluo";		ArrayForHeaderString2[a]="(organoid)";		ArrayForHeaderString3[a]="H1-Maroon";}									ArrayForPrintString[a] = d2s(ArrayTimeLapseChannel4[i], nDecimals);				
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="        ";		ArrayForHeaderString2[a]="";		   		ArrayForHeaderString3[a]="";}											ArrayForPrintString[a] = "";	
					
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="Measurement";	ArrayForHeaderString2[a]="counter";			ArrayForHeaderString3[a]="     ";}				if(i+1<=EventCounter){	ArrayForPrintString[a] = toString(i+1);								}else{ArrayForPrintString[a]="";}												// eigenlijk betekent dit nix
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="Event";			ArrayForHeaderString2[a]="number";			ArrayForHeaderString3[a]="(depth movie)";}		if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayEventNumber[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="Slice";			ArrayForHeaderString2[a]="number";			ArrayForHeaderString3[a]="     ";}				if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArraySliceNumber[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="ROI";			ArrayForHeaderString2[a]="   x    ";		ArrayForHeaderString3[a]="     ";}				if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayX[i], nDecimals);					}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="ROI";			ArrayForHeaderString2[a]="   y    ";		ArrayForHeaderString3[a]="     ";}				if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayY[i], nDecimals);					}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="        ";		ArrayForHeaderString2[a]="";		   		ArrayForHeaderString3[a]="";}											ArrayForPrintString[a] = "";	
			
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" cell  ";			ArrayForHeaderString3[a]="Clover-Geminin";}		if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayCellChannel1[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" organoid  ";		ArrayForHeaderString3[a]="Clover-Geminin";}		if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayPlaneChannel1[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" cell  ";			ArrayForHeaderString3[a]="mKO2-Cdt1";}			if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayCellChannel2[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" organoid  ";		ArrayForHeaderString3[a]="mKO2-Cdt1";}			if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayPlaneChannel2[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" cell  ";			ArrayForHeaderString3[a]="mTurq-SLBP";}			if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayCellChannel3[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" organoid  ";		ArrayForHeaderString3[a]="mTurq-SLBP";}			if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayPlaneChannel3[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" cell  ";			ArrayForHeaderString3[a]="H1-Maroon";}			if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayCellChannel4[i], nDecimals);		}else{ArrayForPrintString[a]="";}
					a=a+1;	if(i==0){ArrayForHeaderString1[a]="fluo";			ArrayForHeaderString2[a]=" organoid  ";		ArrayForHeaderString3[a]="H1-Maroon";}			if(i+1<=EventCounter){	ArrayForPrintString[a] = d2s(ArrayPlaneChannel4[i], nDecimals);		}else{ArrayForPrintString[a]="";}												
			
			
				NumberOfParameters = a+1; 
				ArrayForPrintString  	= Array.trim(ArrayForPrintString,  NumberOfParameters);  //
				ArrayForHeaderString1 	= Array.trim(ArrayForHeaderString1, NumberOfParameters);  //
				ArrayForHeaderString2 	= Array.trim(ArrayForHeaderString2, NumberOfParameters);  //
			
				// build the HeaderString and put in the PrintStringArray
				if(i==0){
					HeaderString1 = "";																								if(PrintStringsToLog){print("******************* , i = "+i); print("HeaderString1 start : "+HeaderString1);}
					for(j=0 ; j<NumberOfParameters ; j++){HeaderString1 = HeaderString1 + Separator + ArrayForHeaderString1[j];		if(PrintStringsToLog){print("HeaderString1 for-loop "+HeaderString1);}	}
					PrintStringArray[2] = HeaderString1;
					//
					HeaderString2 = "";																								if(PrintStringsToLog){print("HeaderString2 start : "+HeaderString2);}
					for(j=0 ; j<NumberOfParameters ; j++){HeaderString2 = HeaderString2 + Separator + ArrayForHeaderString2[j];		if(PrintStringsToLog){print("HeaderString2 for-loop "+HeaderString2);}	}
					PrintStringArray[3] = HeaderString2;		
					//
					HeaderString3 = "";																								if(PrintStringsToLog){print("HeaderString3 start : "+HeaderString3);}
					for(j=0 ; j<NumberOfParameters ; j++){HeaderString3 = HeaderString3 + Separator + ArrayForHeaderString3[j];		if(PrintStringsToLog){print("HeaderString3 for-loop "+HeaderString3);}	}
					PrintStringArray[4] = HeaderString3;		
				}
					PrintStringArray[5] = "";	
				// build the PrintString and put in the PrintStringArray
				PrintString = "";																									if(PrintStringsToLog){print("PrintString start : "+PrintString);}
				for(j=0 ; j<NumberOfParameters ; j++){PrintString = PrintString + Separator + ArrayForPrintString[j];				if(PrintStringsToLog){print("PrintString for-loop "+PrintString);}		}
				PrintString = toString(PrintString);
				// en nu de Printstring van deze i in de ARRAY zetten
				FirstRow = 6 ;
				PrintStringArray[FirstRow + i] 	= PrintString;																		if(PrintStringsToLog){print("PrintStringArray.length "+PrintStringArray.length);}
																																	if(PrintStringsToLog){print(""); print("******************* , i = "+i);  print("PrintStringArray[FirstRow + i] : "); print(PrintStringArray[FirstRow + i]);}		
			} //  van de i-loop
	
																																																		print("");print("Save results and round up");print("");
														//  SAVE RESULTS  and round up
															ScoreEvents_Output = PrintStringArray;
															Array.show(ScoreEvents_Output); selectWindow("ScoreEvents_Output"); setLocation(1, 1);

															if(PosNumber==NaN){		
																Dialog.create(" ");	Dialog.addMessage(" ... could not retrieve position  number ; please fill in"); 	Dialog.addNumber("PosNumber", 1 , 0 , 4 , ""); 	Dialog.show();	PosNumber  = Dialog.getNumber();		
															}
											
															PosString=""; if(PosNumber!=NaN){PosString = " Pos"+PosNumber;}
															NameResultsWindow = "Fucci4_Output " + PosString + ".xls";//RO1
															IJ.renameResults(NameResultsWindow);	
															saveAs("Results", DumpLocation + ResultDump + NameResultsWindow);   
															selectWindow(NameResultsWindow); run("Close");
		}   
		