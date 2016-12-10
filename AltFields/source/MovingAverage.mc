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


class MovingAverage {
	var arr;
	var ptr= 0;
	var size;
	
	function init(s) {
		size= s+1;
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
	    return (arr[ptr] - arr[(ptr+1) % size]) / (size-1);
	}
}