class MovingAverage {
	var arr;
	var ptr= 0;
	var size;
	
	function init(s) {
		size= s;
	    arr= new[size];
	    for (var i=0; i<size; i++) {
	        arr[i]= 0;
	    }
	}
	
	function push(value) {
		ptr= (ptr+1) % size;
	    arr[ptr]= value;
	}
	
	function get() {
	    return (arr[ptr] - arr[(ptr+1) % size]) / size;
	}
}