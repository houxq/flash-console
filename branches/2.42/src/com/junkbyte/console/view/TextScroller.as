/*
* 
* Copyright (c) 2008-2010 Lu Aye Oo
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
package com.junkbyte.console.view 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class TextScroller extends Sprite {
		
		private var _scroller:Sprite;
		private var _scrolldelay:uint;
		private var _scrolldir:int;
		
		private var _h:Number = 100;
		private var _scrolling:Boolean;
		
		private var _color:Number;
		
		public var targetIncrement:Number;
		
		public function TextScroller(color:Number) {
			_color = color;
			name = "scroller";
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_DOWN, onScrollbarDown, false, 0, true);
			//
			_scroller = new Sprite();
			_scroller.name = "scrollbar";
			_scroller.y = 5;
			_scroller.graphics.beginFill(_color, 1);
			
			_scroller.graphics.drawRect(-5, 0, 5, 30);
			_scroller.graphics.beginFill(0, 0);
			_scroller.graphics.drawRect(-10, 0, 10, 30);
			_scroller.graphics.endFill();
			_scroller.buttonMode = true;
			_scroller.addEventListener(MouseEvent.MOUSE_DOWN, onScrollerDown, false, 0, true);
			addChild(_scroller);
		}
		public override function set height(n:Number):void{
			_h = n;
			_scroller.visible = _h>40;
			graphics.clear();
			if(_h>=10){
				graphics.beginFill(_color, 0.7);
				graphics.drawRect(-5, 0, 5, 5);
				graphics.drawRect(-5, n-5, 5, 5);
				graphics.beginFill(_color, 0.25);
				graphics.drawRect(-5, 5, 5, n-10);
				graphics.beginFill(0, 0);
				graphics.drawRect(-10, 10, 10, n-10);
				graphics.endFill();
			}
		}
		public function get scrollPercent():Number{
			return (_scroller.y-5)/(_h-40);
		}
		public function set scrollPercent(per:Number):void{
			_scroller.y = 5+((_h-40)*per);
		}
		private function incScroll(i:int):void{
			targetIncrement = i;
			dispatchEvent(new Event(Event.CHANGE));
		}
		private function onScrollbarDown(e:MouseEvent):void{
			if((_scroller.visible && _scroller.mouseY>0) || (!_scroller.visible && mouseY>_h/2)) {
				incScroll(3);
				_scrolldir = 3;
			}else {
				incScroll(-3);
				_scrolldir = -3;
			}
			_scrolldelay = 0;
			addEventListener(Event.ENTER_FRAME, onScrollBarFrame, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollBarUp, false, 0, true);
		}
		private function onScrollBarFrame(e:Event):void{
			_scrolldelay++;
			if(_scrolldelay>10){
				_scrolldelay = 9;
				if((_scrolldir<0 && _scroller.y>mouseY)||(_scrolldir>0 && _scroller.y+_scroller.height<mouseY)){
					incScroll(_scrolldir);
				}
			}
		}
		private function onScrollBarUp(e:Event):void{
			removeEventListener(Event.ENTER_FRAME, onScrollBarFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollBarUp);
		}
		//
		//
		private function onScrollerDown(e:MouseEvent):void{
			_scrolling = true;
			dispatchEvent(new Event(Event.INIT));
			_scroller.startDrag(false, new Rectangle(0,5, 0, (_h-40)));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollerMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollerUp, false, 0, true);
			e.stopPropagation();
		}
		private function onScrollerMove(e:MouseEvent):void{
			dispatchEvent(new Event(Event.SCROLL));
		}
		private function onScrollerUp(e:MouseEvent):void{
			_scroller.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollerMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollerUp);
			_scrolling = false;
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
