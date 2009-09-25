﻿package com.atticmedia.console.view {
	import com.atticmedia.console.Console;
	import com.atticmedia.console.core.Utils;
	import com.atticmedia.console.events.TextFieldRollOver;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;		

	/**
	 * @author LuAye
	 */
	public class GraphingPanel extends AbstractPanel {
		private var _interests:Array = [];
		private var _history:Array = [];
		private var _updatedFrame:uint = 0;
		private var _drawnFrame:uint = 0;
		private var _needRedraw:Boolean;
		private var _isRunning:Boolean;
		//
		protected var fixed:Boolean;
		protected var graph:Shape;
		protected var lowTxt:TextField;
		protected var highTxt:TextField;
		protected var keyTxt:TextField;
		//
		public var updateEvery:uint = 1;
		public var drawEvery:uint = 1;
		public var lowest:Number;
		public var highest:Number;
		public var averaging:uint;
		public var inverse:Boolean;
		//
		public function GraphingPanel(m:Console, W:int = 0, H:int = 0, resizable:Boolean = true) {
			super(m);
			registerDragger(bg);
			minimumHeight = 26;
			//
			lowTxt = new TextField();
			lowTxt.name = "lowestField";
			lowTxt.mouseEnabled = false;
			lowTxt.styleSheet = style.css;
			lowTxt.height = 14;
			addChild(lowTxt);
			highTxt = new TextField();
			highTxt.name = "highestField";
			highTxt.mouseEnabled = false;
			highTxt.styleSheet = style.css;
			highTxt.height = 14;
			highTxt.y = 6;
			addChild(highTxt);
			//
			keyTxt = new TextField();
			keyTxt.name = "menuField";
			keyTxt.styleSheet = style.css;
			keyTxt.height = 16;
			keyTxt.y = -3;
			keyTxt.selectable = false;
			keyTxt.addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			registerRollOverTextField(keyTxt);
			keyTxt.addEventListener(TextFieldRollOver.ROLLOVER, onMenuRollOver, false, 0, true);
			registerDragger(keyTxt); // so that we can still drag from textfield
			addChild(keyTxt);
			//
			graph = new Shape();
			graph.name = "graph";
			graph.y = 10;
			addChild(graph);
			//
			init(W?W:100,H?H:80,resizable);
		}
		
		public function get rand():Number{
			return Math.random();
		}
		public function add(obj:Object, prop:String, col:Number = -1, key:String=null):void{
			if(obj == null) return;
			var cur:Number = obj[prop];
			if(!isNaN(cur)){
				if(isNaN(lowest)) lowest = cur;
				if(isNaN(highest)) highest = cur;
			}
			if(isNaN(col) || col<0) col = Math.random()*0xFFFFFF;
			if(key == null) key = prop;
			//_interests.push([obj, prop, col, key, NaN]);
			_interests.push(new Interest(obj, prop, col, key));
			updateKeyText();
			//
			start();
		}
		public function remove(obj:Object, prop:String):void{
			for(var X:String in _interests){
				var interest:Interest = _interests[X];
				if(interest && interest.obj == obj && interest.prop == prop){
					_interests.splice(int(X), 1);
				}
			}
		}
		public function mark(col:Number = -1, v:Number = NaN):void{
			if(_history.length==0) return;
			var interests:Array = _history[_history.length-1];
			interests.push([col, v]);
		}
		public function start():void{
			_isRunning = true;
			// Note that if it has already started, it won't add another listener on top.
			addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
		}
		public function stop():void {
			_isRunning = false;
			removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		public function get numInterests():int{
			return _interests.length;
		}
		override public function close():void {
			stop();
			super.close();
		}
		public function reset():void{
			if(!fixed){
				lowest = NaN;
				highest = NaN;
			}
			_history = [];
			graph.graphics.clear();
		}
		public function get running():Boolean {
			return _isRunning;
		}
		public function fixRange(low:Number,high:Number):void{
			if(isNaN(low) || isNaN(high)) {
				fixed = false;
				return;
			}
			fixed = true;
			lowest = low;
			highest = high;
		}
		public function set showKeyText(b:Boolean):void{
			keyTxt.visible = b;
		}
		public function get showKeyText():Boolean{
			return keyTxt.visible;
		}
		public function set showBoundsText(b:Boolean):void{
			lowTxt.visible = b;
			highTxt.visible = b;
		}
		public function get showBoundsText():Boolean{
			return lowTxt.visible;
		}
		override public function set height(n:Number):void{
			super.height = n;
			lowTxt.y = n-13;
			_needRedraw = true;
		}
		override public function set width(n:Number):void{
			super.width = n;
			lowTxt.width = n;
			highTxt.width = n;
			keyTxt.width = n;
			graphics.clear();
			graphics.lineStyle(1,0xAAAAAA, 1);
			graphics.moveTo(0, graph.y);
			graphics.lineTo(n, graph.y);
			_needRedraw = true;
		}
		protected function getCurrentOf(i:int):Number{
			var values:Array = _history[_history.length-1];
			return values?values[i]:0;
		}
		protected function getAverageOf(i:int):Number{
			var interest:Interest = _interests[i];
			return interest?interest.avg:0;
		}
		//
		//
		//
		protected function onFrame(e:Event):void{
			updateData();
			drawGraph();
		}
		protected function updateData():void{
			_updatedFrame++;
			if(_updatedFrame < updateEvery) return;
			_updatedFrame= 0;
			var values:Array = [];
			for each(var interest in _interests){
				var v:Number = interest.obj[interest.prop];
				if(isNaN(v)){
					v = 0;
				}else{
					if(isNaN(lowest)) lowest = v;
					if(isNaN(highest)) highest = v;
				}
				values.push(v);
				if(averaging>0){
					var avg:Number = interest.avg;
					if(isNaN(avg)) {
						interest.avg = v;
					}else{
						interest.avg = Utils.averageOut(avg, v, averaging);
					}
				}
				if(!fixed){
					if(v > highest) highest = v;
					if(v < lowest) lowest = v;
				}
			}
			_history.push(values);
			// clean up off screen data
			var maxLen:int = Math.floor(width)+10;
			var len:uint = _history.length;
			if(len > maxLen){
				_history.splice(0, (len-maxLen));
			}
		}
		// TODO: MAYBE USE BITMAPDATA INSTEAD OF DRAW
		public function drawGraph():void{
			_drawnFrame++;
			if(!_needRedraw && _drawnFrame < drawEvery) return;
			_needRedraw = false;
			_drawnFrame= 0;
			var W:Number = width;
			var H:Number = height-graph.y;
			graph.graphics.clear();
			var diffGraph:Number = highest-lowest;
			var numInterests:int = _interests.length;
			var len:int = _history.length;
			var firstpass:Boolean = true;
			var marks:Array = [];
			for(var j:int = 0;j<numInterests;j++){
				var interest:Interest = _interests[j];
				var first:Boolean = true;
				for(var i:int = 1;i<W;i++){
					if(len < i) break;
					var values:Array = _history[len-i];
					if(first){
						graph.graphics.lineStyle(1,interest.col);
					}
					var Y:Number = (diffGraph?((values[j]-lowest)/diffGraph):0.5)*H;
					if(!inverse) Y = H-Y;
					if(Y<0)Y=0;
					if(Y>H)Y=H;
					graph.graphics[(first?"moveTo":"lineTo")]((W-i), Y);
					first = false;
					if(firstpass){
						if(values.length>numInterests){
							marks.push(i);
						}
					}
				}
				firstpass = false;
				if(averaging>0 && diffGraph){
					Y = ((interest.avg-lowest)/diffGraph)*H;
					if(!inverse) Y = H-Y;
					if(Y<-1)Y=-1;
					if(Y>H)Y=H+1;
					graph.graphics.lineStyle(1,interest.col, 0.3);
					graph.graphics.moveTo(0, Y);
					graph.graphics.lineTo(W, Y);
				}
			}
			for each(var mark:int in marks){
				// TODO: Mark should have its own special color and value point
				graph.graphics.lineStyle(1,0xFFCC00, 0.4);
				graph.graphics.moveTo(W-mark, 0);
				graph.graphics.lineTo(W-mark, H);
			}
			lowTxt.text = isNaN(lowest)?"":"<s>"+lowest+"</s>";
			highTxt.text = isNaN(highest)?"":"<s>"+highest+"</s>";
		}
		public function updateKeyText():void{
			var str:String = "<r><s>";
			for each(var interest:Interest in _interests){
				str += " <font color='#"+interest.col.toString(16)+"'>"+interest.key+"</font>";
			}
			str +=  " | <font color='#FF8800'><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></font></s></r>";
			keyTxt.htmlText = str;
		}
		protected function linkHandler(e:TextEvent):void{
			if(e.text == "reset"){
				reset();
			}else if(e.text == "close"){
				close();
			}
			e.stopPropagation();
		}
		protected function onMenuRollOver(e:TextFieldRollOver):void{
			master.panels.tooltip(e.url?e.url.replace("event:",""):null, this);
		}
	}
}
class Interest{
	public var obj:Object;
	public var prop:String;
	public var col:Number;
	public var key:String;
	public var avg:Number;
	public function Interest(object:Object, property:String, color:Number, keystr:String):void{
		obj = object;
		prop = property;
		col = color;
		key = keystr;
	}
}
/*class Mark{
	public var position:int;
	public var col:Number;
	public var val:Number;
	public function Mark(color:Number, value:Number):void{
		col = color;
		val = value;
	}
}*/