using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class AltFieldsView extends Ui.DataField {
	var vRunnerSpeed= 300;
	var cadence= 0;
	var ghost= 0;
	var time= "00:00";
	var timeSub= null;
	var distance= 0;
	var avgPace= "---";
	var altitude= 0;
	var battery= 0;
	var heartRateGraph= new HeartRateGraph();
	var runnerImg;
	var ghostImg;
	var heartImg;
	var blackBG;
	

    function initialize() {
        DataField.initialize();
        vRunnerSpeed= Application.getApp().getProperty("VRUNNER_SPEED");
        heartRateGraph.initialize(Application.getApp().getProperty("GRAPH_SCALE"));
        blackBG= getBackgroundColor() == Gfx.COLOR_BLACK;
        runnerImg= getImage(Rez.Drawables.Runner, Rez.Drawables.RunnerBlack);
        ghostImg= getImage(Rez.Drawables.Runner2, Rez.Drawables.Runner2Black );
        heartImg= getImage(Rez.Drawables.HeartIcon, Rez.Drawables.HeartIconBlack );
    }
    
    function getImage(img1, img2) {
    	return Ui.loadResource( blackBG ? img2 : img1);
    }

    function asTime(n) {
        return (n / 60) + ":" +(n % 60).format("%02d");
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and save it locally in this method.
    function compute(info) {
		if (info!=null) {
			cadence = info.currentCadence == null ? 0 : info.currentCadence;
			
			if (info.timerTime  != null) {
				var secs= info.timerTime  / 1000;
				if (secs >= 3600) {
				    time= (secs/ 3600) + ":" + (secs / 60 % 60).format("%02d");
				    timeSub= (secs % 60).format("%02d");
				} else {
					time= asTime(secs);
					timeSub= null;
				}
				if (info.elapsedDistance != null) {
					var dist= info.timerTime / vRunnerSpeed;
					ghost = info.elapsedDistance - dist;
				}
			}
	        distance = info.elapsedDistance == null ? 0 : (info.elapsedDistance / 1000);	
	        if (info.averageSpeed != null && info.averageSpeed > 0) {
	            var pace= (1000/info.averageSpeed).toNumber();
	            avgPace= asTime(pace);
	        } else {
	            avgPace= "---";
	        }
			altitude= info.altitude == null ? 0 : info.altitude;
			battery= System.getSystemStats().battery;
			heartRateGraph.store(info.currentHeartRate);
	    } 
    }

    //! Display the value you computed here. This will be called
    //! once a second when the data field is visible.
    function onUpdate(dc) {        
    	var width= dc.getWidth();
    	var height= dc.getHeight();
    	var w3_4= width*3/4;
    	var w1_2= width/2;
    	var w1_4= width/4;
    	var h1_3= height/3;
    	var h2_3= height*2/3;
    	     
    	// Set the background color
		var bgColor= Gfx.COLOR_TRANSPARENT; 
		var color= blackBG ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK;
		var color2= blackBG ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY;
		
		dc.drawBitmap(44, 5, heartImg);
		
		
		dc.setColor(color2 , bgColor);
//        dc.drawText(width/2 - 12, 0, Gfx.FONT_TINY, "Altitude", Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w3_4 - 18, -1, Gfx.FONT_TINY, "Ghost "+ asTime(vRunnerSpeed), Gfx.TEXT_JUSTIFY_CENTER); 
        dc.drawText(w1_4 + 12, h1_3, Gfx.FONT_TINY, "Timer", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(w3_4 - 6, h1_3, Gfx.FONT_TINY, "Distance", Gfx.TEXT_JUSTIFY_CENTER); 
        dc.drawText(w1_4 + 12, h2_3, Gfx.FONT_TINY, "Avg Pace", Gfx.TEXT_JUSTIFY_CENTER);       
        dc.drawText(w3_4 - 12, h2_3, Gfx.FONT_TINY, "Cadence", Gfx.TEXT_JUSTIFY_CENTER);  
		
//		dc.setColor(color, bgColor);
//        dc.drawText(width/2 - 12, 0 + 12, Gfx.FONT_NUMBER_MEDIUM,  altitude.format("%d"), Gfx.TEXT_JUSTIFY_RIGHT);

		heartRateGraph.draw(dc, color);
      
      	var absghost= (ghost < 0 ? -ghost : ghost);
  		var pix=  absghost / 5;
	    if (pix < 64) { 
	    	dc.drawBitmap(w3_4 - pix/2 -20, 18, ghost < 0 ? runnerImg : ghostImg);
	    } else {
	        pix= 64;
	    }			
	    dc.drawBitmap(w3_4 + pix/2 -20, 18, ghost < 0 ? ghostImg : runnerImg); 
		dc.setColor(ghost < 0 ? Gfx.COLOR_DK_RED : Gfx.COLOR_DK_BLUE, bgColor); 
		dc.drawText(w1_2 + dc.getTextWidthInPixels(absghost.format("%d"), Gfx.FONT_NUMBER_MILD) + 5, 
						42, Gfx.FONT_SMALL, "m "+ (ghost < 0 ? "behind" : "ahead"), Gfx.TEXT_JUSTIFY_LEFT);    
		
		dc.drawText(width/2 + 4, 33, Gfx.FONT_NUMBER_MILD, absghost.format("%d"), Gfx.TEXT_JUSTIFY_LEFT);
		

        dc.setColor(color, bgColor);
        if (timeSub != null) {
        	dc.drawText(w1_2 - 30, h1_3 + 14, Gfx.FONT_NUMBER_MEDIUM, time, Gfx.TEXT_JUSTIFY_RIGHT);
        	dc.setColor(color2, bgColor);
        	dc.drawText(w1_2 - 6, h1_3 + 28, Gfx.FONT_NUMBER_MILD, timeSub, Gfx.TEXT_JUSTIFY_RIGHT);
        	dc.setColor(color, bgColor);
		} else {
			dc.drawText(w1_4 + 6, h1_3 + 14, Gfx.FONT_NUMBER_MEDIUM, time, Gfx.TEXT_JUSTIFY_CENTER);
		}
 		dc.drawText(w3_4 - 6, h1_3 + 14, Gfx.FONT_NUMBER_MEDIUM, distance.format("%.2f"), Gfx.TEXT_JUSTIFY_CENTER);
 		dc.drawText(w1_2 - 12, h2_3 + 12, Gfx.FONT_NUMBER_MEDIUM, avgPace, Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w3_4 - 12, h2_3 + 12, Gfx.FONT_NUMBER_MEDIUM, cadence.format("%d"), Gfx.TEXT_JUSTIFY_CENTER); 
       
		var batInd= 34 * battery / 100.0 - 17;
        dc.setPenWidth(10);
        dc.setColor(Gfx.COLOR_LT_GRAY, bgColor);
        dc.drawArc(w1_2, height/2, w1_2 - 4, 0, batInd, 17);
        var batCol= battery > 60 ? Gfx.COLOR_DK_GREEN : 
        			(battery > 40 ? Gfx.COLOR_YELLOW : 
        			(battery > 20 ? Gfx.COLOR_ORANGE : Gfx.COLOR_RED));
        dc.setColor(batCol, bgColor);
        dc.drawArc(w1_2, height/2, w1_2 - 4, 0, -17, batInd);
        
        
        dc.setPenWidth(1);
        dc.setColor(Gfx.COLOR_BLUE, bgColor);
		dc.drawLine(w1_2, 0, w1_2, height);
		dc.drawLine(0, h1_3, width, h1_3);
		dc.drawLine(0, h2_3, width, h2_3);
    }


}
