/*
	Copyright Jose R. Cabanes
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

*/


using Toybox.Graphics as Gfx;


class HeartRateGraph {
	const HRMAX= 54;
	var SCALE= 5;
	var heartRates= new[HRMAX];
	var currentHR= 0;
	var acc= 0;
	var maxHr= 180;
	var minHr= 100;
	var idx= 0;

	/** It seems that initialize is reserved method */
	function initialize_(scale) {
	    SCALE= scale;
        for (var i=0; i<HRMAX; i++) {
            heartRates[i]= 0;
        }	
	}
	
	
	function store(value) {
		if (value == null) {
			return;
		}
		currentHR= value;
		acc += value;
		idx += 1;
		    
		if (idx % 10 == 0) {
			recalcMaxMin();
		}
		if (idx % SCALE == 0) {
			heartRates[idx/SCALE % HRMAX]= acc / SCALE;
			acc= 0;
		}
	}
	
	function recalcMaxMin() {
		maxHr= heartRates[0];
		minHr= 160000;
		for (var i=0; i<HRMAX; i++) {
		    var v= heartRates[i];
			if (v > maxHr) {
				maxHr= v;
			}
			if (v < minHr && v > 0) {
				minHr= v;
			}
		}
		minHr -= 1;
		var maxHeight= maxHr - minHr;
		if (maxHeight < 35) {
			var t= (35 - maxHeight) / 2;
			maxHr += t;
			minHr -= t;
		}
	}
	
	function draw(dc, color, gColor) {
		var h= dc.getHeight()/3;
		var vAdj= h>60 ? 6 : 0;
		
		dc.setColor(gColor, Gfx.COLOR_TRANSPARENT);
		var maxHeight= maxHr - minHr;
	
		for (var i=0; i<HRMAX; i++) {
			var ptr= (i + idx/SCALE) % HRMAX;
		    var barHeight= maxHeight <= 0 ? 0 : ((heartRates[ptr] - minHr) * (h - 25) / maxHeight).toNumber();
		    dc.fillRectangle( i+i, h - barHeight + vAdj, 2, barHeight);
		}
		
		dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/4 + 32 + vAdj, -2 + vAdj, Gfx.FONT_NUMBER_MILD,  currentHR.format("%d"), Gfx.TEXT_JUSTIFY_CENTER);
			
	}
}