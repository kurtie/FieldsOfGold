using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class AltFieldsView extends Ui.DataField {
	var posSemiRound= [
		44 ,5,
		112, -1,
		66, 60,
		155, 60,
		68, 120,
		147, 120,
		141, 17, 32,
		60, 72, 
		156, 132
	]; 
	var posRound= [
		54 ,13,
		115, 13,
		66, 76,
		157, 76,
		72, 139,
		147, 139,
		143, 32, 47,
		61, 83, 
		158, 146
	];
	var pace= new MovingAverage();
	var pos= posSemiRound;
	
	var vRunnerSpeed= 310;
	var ghost= 0;
	var time= "00:00";
	var timeSub= null;
	var distance= 0;
	var battery= 0;
	var heartRateGraph= new HeartRateGraph();
	var runnerImg;
	var ghostImg;
	var graphImg;
	var blackBG;
	enum {
		Pace,
		Cadence,
		HeartRate,
		Altitude,
		AvgPace,
		StrideLen,
		Calories,
		TrainEffect
	}
	var fld1Type;
	var fld5Type;
	var fld6Type;
	var fld5Txt;
	var fld5Val;
	var fld6Txt;
	var fld6Val;

    function initialize() {
        DataField.initialize();
        var app= Application.getApp();
        vRunnerSpeed= app.getProperty("VRUNNER_SPEED");
        heartRateGraph.initialize(app.getProperty("GRAPH_SCALE"));
        fld1Type= app.getProperty("GRAPH").toNumber();
        fld5Type= app.getProperty("FIFTH_FIELD").toNumber();
        fld5Txt=getFieldLabel(fld5Type);
        fld6Type= app.getProperty("SIXTH_FIELD").toNumber();
        fld6Txt=getFieldLabel(fld6Type);
        blackBG= getBackgroundColor() == Gfx.COLOR_BLACK;
        runnerImg= getImage(Rez.Drawables.Runner, Rez.Drawables.RunnerBlack);
        ghostImg= getImage(Rez.Drawables.Runner2, Rez.Drawables.Runner2Black );
        graphImg= fld1Type==HeartRate ? 
        	getImage(Rez.Drawables.HeartIcon, Rez.Drawables.HeartIconBlack ) :
        	getImage(Rez.Drawables.AltIcon, Rez.Drawables.AltIconBlack );
        
        var movingAvg= Application.getApp().getProperty("MOVING_AVG").toNumber();
        pace.init(movingAvg);
    }
    
    function getFieldLabel(type) {
    	var res= Rez.Strings.stridelen_sh;
    	if (type == Pace) {
    		res= Rez.Strings.pace;
    	} else
    	if (type == Cadence) {
    		res= Rez.Strings.cadence;
    	} else
    	if (type == AvgPace) {
    		res= Rez.Strings.avgpace_sh;
    	} else
    	if (type == Calories) {
    		res= Rez.Strings.calories;
    	} else
    	if (type == TrainEffect) {
    		res= Rez.Strings.traineffect_sh;
    	}
    	return Ui.loadResource(res);
    }
    
    function onLayout(dc) {    
        View.setLayout(Rez.Layouts.Main(dc));
        View.findDrawableById("Background").setColor(getBackgroundColor());
        pos= dc.getHeight() > 180 ? posRound : posSemiRound;
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
	        pace.push(distance*1000);
	        fld5Val= getFieldValue(fld5Type, info);
	        fld6Val= getFieldValue(fld6Type, info);	        

			battery= System.getSystemStats().battery;
			heartRateGraph.store(fld1Type == HeartRate ? info.currentHeartRate : info.altitude);
	    } 
    }
    
    function getFieldValue(type, info) {
		if (type == AvgPace) {
	        if (info.averageSpeed != null && info.averageSpeed > 0) {
	            var pace= (1000/info.averageSpeed).toNumber();
	            return asTime(pace);
	        } else {
	            return "---";
	        }		
		}
    	if (type == Pace) {
    		var p= pace.get();
    		return p<= 0 ? "---" : asTime( (1000 / p).toNumber() );
    	}
    	if (type == Cadence) {
    		return info.currentCadence == null ? "0" : info.currentCadence.format("%d");
    	}
    	if (type == StrideLen) {
    		var p= pace.get();
    		return p<=0 || info.currentCadence == null ? "---" : (p * 6000 / info.currentCadence).format("%d");
    	}
    	if (type == Calories) {
    		return info.calories;
    	}
    	if (type == TrainEffect) {
    		return info.trainingEffect.format("%.2f");
    	}
    	return "000";    	
    }

    //! Display the value you computed here. This will be called
    //! once a second when the data field is visible.
    function onUpdate(dc) {
    	var width= dc.getWidth();
    	var height= dc.getHeight();
    	var isRound= dc.getHeight() > 180;
    	
    	var w1_2= width/2;
    	var h1_3= height/3 + (isRound ? 6 : 0);
    	var h2_3= height*2/3 - (isRound ? 5 : 0);
    	     
    	// Set the background color
		var bgColor= Gfx.COLOR_TRANSPARENT; 
		var color= blackBG ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK;
		var color2= blackBG ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY;
		
		dc.setColor(Gfx.COLOR_TRANSPARENT, bgColor);
		dc.clear();
    	// Call parent’s onUpdate(dc) to redraw the layout
        View.onUpdate( dc );
		
		dc.drawBitmap(pos[0], pos[1], graphImg);
		dc.setColor(color2 , bgColor);
        dc.drawText(pos[2], pos[3], Gfx.FONT_TINY, "VR "+ asTime(vRunnerSpeed), Gfx.TEXT_JUSTIFY_LEFT); 
        dc.drawText(pos[4], pos[5], Gfx.FONT_TINY, "Timer", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(pos[6], pos[7], Gfx.FONT_TINY, "Distance", Gfx.TEXT_JUSTIFY_CENTER); 
        dc.drawText(pos[8], pos[9], Gfx.FONT_TINY, fld5Txt, Gfx.TEXT_JUSTIFY_CENTER);       
        dc.drawText(pos[10], pos[11], Gfx.FONT_TINY, fld6Txt, Gfx.TEXT_JUSTIFY_CENTER);  
		

		heartRateGraph.draw(dc, color, fld1Type == HeartRate ? Gfx.COLOR_RED : Gfx.COLOR_YELLOW);
      	var absghost= (ghost < 0 ? -ghost : ghost);
  		var pix=  absghost / 6;
	    if (pix < 64) { 
	    	dc.drawBitmap(pos[12] - pix/2, pos[13], ghost < 0 ? runnerImg : ghostImg);
	    } else {
	        pix= 64;
	    }			
	    dc.drawBitmap(pos[12] + pix/2, pos[13], ghost < 0 ? ghostImg : runnerImg); 
		dc.setColor(ghost < 0 ? Gfx.COLOR_DK_RED : Gfx.COLOR_DK_BLUE, bgColor); 
		dc.drawText(pos[2] + dc.getTextWidthInPixels(absghost.format("%d"), Gfx.FONT_NUMBER_MILD), 
						pos[14]+10, isRound ? Gfx.FONT_TINY : Gfx.FONT_SMALL, "m "+ (ghost < 0 ? "behind" : "ahead"), Gfx.TEXT_JUSTIFY_LEFT);    
		
		dc.drawText(pos[2], pos[14], Gfx.FONT_NUMBER_MILD, absghost.format("%d"), Gfx.TEXT_JUSTIFY_LEFT);
		

        dc.setColor(color, bgColor);
        if (timeSub != null) {
        	if (isRound) {
        		dc.drawText(pos[15]-6, pos[16], Gfx.FONT_NUMBER_MEDIUM, time+":"+timeSub, Gfx.TEXT_JUSTIFY_CENTER);
        	} else {
        		dc.drawText(pos[15]+15, pos[16], Gfx.FONT_NUMBER_MEDIUM, time, Gfx.TEXT_JUSTIFY_RIGHT);
        		dc.drawText(pos[15]+39, pos[16]+14, Gfx.FONT_NUMBER_MILD, timeSub, Gfx.TEXT_JUSTIFY_RIGHT);
        	}	
		} else {
			dc.drawText(pos[15], pos[16], Gfx.FONT_NUMBER_MEDIUM, time, Gfx.TEXT_JUSTIFY_CENTER);
		}
 		dc.drawText(pos[17], pos[16], Gfx.FONT_NUMBER_MEDIUM, distance.format("%.2f"), Gfx.TEXT_JUSTIFY_CENTER);
 		
 		dc.drawText(pos[8], pos[18], Gfx.FONT_NUMBER_MEDIUM, fld5Val, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(pos[10], pos[18], Gfx.FONT_NUMBER_MEDIUM, fld6Val, Gfx.TEXT_JUSTIFY_CENTER); 
       
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
