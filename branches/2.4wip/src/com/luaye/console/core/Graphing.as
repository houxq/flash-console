/*
* 
* Copyright (c) 2008-2009 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
*/
package com.luaye.console.core {
	import flash.system.System;
	import flash.utils.getTimer;

	import com.luaye.console.vos.GraphInterest;
	import com.luaye.console.vos.GraphGroup;

	import flash.geom.Rectangle;

	public class Graphing {
		
		private var _groups:Array = [];
		private var _map:Object = {};
		
		private var _fpsGroup:GraphGroup;
		private var _memGroup:GraphGroup;
		
		private var _previousTime:Number = -1;
		private var _report:Function;
		public function Graphing(reporter:Function){
			_report = reporter;
		}
		// WINDOW name lowest highest averaging inverse
		// GRAPH key color values
		public function add(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false):void{
			var group:GraphGroup = _map[n];
			var newGroup:Boolean;
			if(!group) {
				newGroup = true;
				group = new GraphGroup(n);
			}
			if(isNaN(col) || col<0) col = Math.random()*0xFFFFFF;
			if(key == null) key = prop;
			var interest:GraphInterest;
			var interests:Array = group.interests;
			for each(interest in interests){
				if(interest.key == key){
					_report("Graph with key ["+key+"] already exists in ["+n+"]", 10);
					return;
				}
			}
			if(rect) group.rect = rect;
			if(inverse) group.inverse = inverse;
			interest = new GraphInterest(key, col);
			var v:Number = NaN;
			try{
				v = interest.setObject(obj, prop);
			}catch (e:Error){
				_report("Error with graph value for ["+key+"] in ["+n+"]. "+e, 10);
				return;
			}
			if(isNaN(v)){
				_report("Graph value for key ["+key+"] in ["+n+"] is not a number (NaN).", 10);
			}else{
				group.interests.push(interest);
				if(newGroup){
					_map[n] = group;
					_groups.push(group);
				}
			}
		}

		public function fixRange(n:String, low:Number = NaN, high:Number = NaN):void{
			var group:GraphGroup = _map[n];
			if(!group) return;
			group.lowest = low;
			group.highest = high;
			group.fixed = !(isNaN(low)||isNaN(high));
		}
		public function remove(n:String, obj:Object = null, prop:String = null):void{
			var group:GraphGroup = _map[n];
			if(!group) return;
			if(obj==null&&prop==null){	
				removeGroup(n);
			}else{
				var interests:Array = group.interests;
				for(var i:int = interests.length-1;i>=0;i--){
					var interest:GraphInterest = interests[i];
					if((obj == null || interest.obj == obj) && (prop == null || interest.prop == prop)){
						interests.splice(i, 1);
					}
				}
				if(interests.length==0){
					removeGroup(n);
				}
			}
		}
		private function removeGroup(n:String):void{
			var g:GraphGroup = _map[n];
			var index:int = _groups.indexOf(g);
			if(index>=0) _groups.splice(index, 1);
			delete _map[n];
		}
		public function get fpsMonitor():Boolean{
			return _fpsGroup!=null;
		}
		public function set fpsMonitor(b:Boolean):void{
			if(b != fpsMonitor){
				if(b) {
					_fpsGroup = addSpecialGroup(GraphGroup.TYPE_FPS);
					_fpsGroup.lowest = 0;
					_fpsGroup.fixed = true;
					_fpsGroup.averaging = 30;
				} else{
					_previousTime = -1;
					var index:int = _groups.indexOf(_fpsGroup);
					if(index>=0) _groups.splice(index, 1);
					_fpsGroup = null;
				}
			}
		}
		//
		public function get memoryMonitor():Boolean{
			return _memGroup!=null;
		}
		public function set memoryMonitor(b:Boolean):void{
			if(b != memoryMonitor){
				if(b) {
					_memGroup = addSpecialGroup(GraphGroup.TYPE_MEM);
					_memGroup.freq = 10;
				} else{
					var index:int = _groups.indexOf(_memGroup);
					if(index>=0) _groups.splice(index, 1);
					_memGroup = null;
				}
			}
		}
		private function addSpecialGroup(type:int):GraphGroup{
			var group:GraphGroup = new GraphGroup("special");
			group.type = type;
			_groups.push(group);
			var graph:GraphInterest = new GraphInterest("special");
			if(type == GraphGroup.TYPE_FPS) {
				graph.col = 0xFF3333;
				graph.avg = 0;
			}else{
				graph.col = 0x5060FF;
			}
			group.interests.push(graph);
			return group;
		}
		public function update(stack:Boolean = false, fps:Number = 0):Array{
			var interest:GraphInterest;
			var v:Number;
			for each(var group:GraphGroup in _groups){
				var ok:Boolean = true;
				if(group.freq>1){
					group.idle++;
					if(group.idle<group.freq){
						ok = false;
					}else{
						group.idle = 0;
					}
				}
				if(ok){
					var typ:uint = group.type;
					var averaging:uint = group.averaging;
					var interests:Array = group.interests;
					if(typ == GraphGroup.TYPE_FPS){
						group.highest = fps;
						interest = interests[0];
						var time:int = getTimer();
						/* TODO: add frames dropped. somehow...
						// this is to try add the frames that have been lagged
						if(frames>Console.FPS_MAX_LAG_FRAMES) frames = Console.FPS_MAX_LAG_FRAMES; // Don't add too many
						while(frames>1){
							updateData();
							frames--;
						}*/
						if(_previousTime >= 0){
							var mspf:Number = time-_previousTime;
							v = 1000/mspf;
							interest.addValue(v, averaging, stack);
						}
						_previousTime = time;
					}else if(typ == GraphGroup.TYPE_MEM){
						interest = interests[0];
						v = Math.round(System.totalMemory/10485.76)/100;
						group.updateMinMax(v);
						interest.addValue(v, averaging, stack);
					}else{
						for each(interest in interests){
							try{
								v = interest.getCurrentValue();
								interest.addValue(v, averaging, stack);
							}catch(e:Error){
								_report("Error with graph value for key ["+interest.key+"] in ["+group.name+"].", 10);
								remove(group.name, interest.obj, interest.prop);
							}
							group.updateMinMax(v);
						}
					}
				}
			}
			return _groups;
		}
	}
}