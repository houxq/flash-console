﻿/*
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
package 
{
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.ConsoleChannel;
	import com.junkbyte.console.ConsoleConfig;

	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	import flash.utils.*;

	public dynamic class Sample extends MovieClip{
		
		private var _spamcount:int;
		
		private var _ch:ConsoleChannel = new ConsoleChannel('myCh');
		
		public function Sample() {
			//
			// SET UP - only required once
			//
			var config:ConsoleConfig = new ConsoleConfig(); // optional.
			//style.big(); // BIG text
			//style.whiteBase(); // Black on white
			
			Cc.startOnStage(this, "`", config); // "`" - change for password. This will start hidden
			Cc.visible = true; // show console, because having password hides console.
			//C.tracing = true; // trace on flash's normal trace
			Cc.commandLine = true; // enable command line
			
			Cc.height = 220;
			Cc.remotingPassword = null; // Just so that remote don't ask for password
			Cc.remoting = true;
			//
			// End of setup
			//
			
			// BASICS
			//
			Cc.info("Hello world.");
			Cc.log("A log message for console.", "optionally there", "can be", "multiple arguments.");
			Cc.debug("A debug level log.");
			Cc.warn("This is a warning log.");
			Cc.error("This is an error log.", "multiple arguments are supported", "for above basic logging methods.");
			Cc.fatal("This is a fatal error log.", "with high visibility");
			//
			// basic channel logging
			//
			Cc.infoch("myChannel", "Hello myChannel.");
			Cc.logch("myChannel", "A log message at myChannel.", "optionally there", "can be", "multiple arguments.");
			//Cc.debugch("myChannel", "A debug level log.");
			//Cc.warnch("myChannel", "This is a warning log.");
			//Cc.errorch("myChannel", "This is an error log.", "multiple arguments are supported", "for above basic logging methods.");
			//
			// instanced channel
			//
			// var _ch:Ch = new Ch('myCh'); // already declared above.
			_ch.log("Hello instanced channel.");
			_ch.info("Works just like other logging methods","but this way you keep the channel name as a class instance");
			//
			// advanced logging
			//
			Cc.add("My advanced log in priority 7.", 7);
			Cc.add("My advanced log in priority 2, 1 (no repeats)", 2, true);
			Cc.add("My advanced log in priority 2, 2 (no repeats)", 2, true);
			Cc.add("My advanced log in priority 2, 3 (no repeats)", 2, true);
			// When 'no repeat' (3rd param) is set to true, it will not generate new lines for each log.
			// It will keep replacing the previous line until a certain count is passed.
			// For example, if you are tracing download progress and you don't want to flood console with it.
			//
			// Advanced channel logging
			//
			Cc.ch("chn", "Advanced log in priority 7.", 7);
			Cc.ch("chn", "Advanced log in priority 3, 1 (no repeats)", 3, true);
			Cc.ch("chn", "Advanced log in priority 3, 2 (no repeats)", 3, true);
			Cc.ch("chn", "Advanced log in priority 3, 3 (no repeats)", 3, true);
			
			
			
			//
			// End of demo code
			//
			setupUI();
		}
		private function setupUI():void{
			TextField(txtPriority).restrict = "0-9";
			TextField(txtPriority2).restrict = "0-9";
			setUpButton(btnInterval, "Start interval");
			setUpButton(btnAdd1, "Add");
			setUpButton(btnAdd2, "Add");
			setUpButton(btnSpam, "Spam");
		}
		private function setUpButton(btn:MovieClip, t:String):void{
			btn.stop();
			btn.buttonMode = true;
			btn.mouseChildren = false;
			btn.txt.text = t;
			btn.addEventListener(MouseEvent.CLICK, onButtonClick);
			btn.addEventListener(MouseEvent.ROLL_OVER, onButtonEvent);
			btn.addEventListener(MouseEvent.ROLL_OUT, onButtonEvent);
		}
		private function onButtonEvent(e:MouseEvent):void{
			MovieClip(e.currentTarget).gotoAndStop(e.type==MouseEvent.ROLL_OVER?"over":"out");
		}
		private function onButtonClick(e:MouseEvent):void{
			switch(e.currentTarget){
				case btnAdd1:
					Cc.add(txtLog.text,int(txtPriority.text));
				break;
				case btnAdd2:
					Cc.ch(txtChannel.text, txtLog2.text,int(txtPriority2.text));
				break;
				case btnInterval:
					if(_interval){
						clearInterval(_interval);
						_interval = 0;
						btnInterval.txt.text = "Start Interval";
					}else{
						_interval = setInterval(onIntervalEvent,100);
						btnInterval.txt.text = "Stop Interval";
					}
				break;
				case btnSpam:
					spam();
				break;
			}
		}
		private function onIntervalEvent():void{
			Cc.add("Repeative log _ " + getTimer(), 5,true);
		}
		private function spam():void{
			for(var i:int = 0;i<100;i++){
				var str:String = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.";
				var rand:int = Math.random()*5;
				if(rand == 1){
					str = "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam,";
				}else if(rand == 2){
					str = "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi";
				}else if(rand == 3){
					str = "Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae.";
				}else if(rand == 4){
					str = "Itaque earum rerum hic tenetur a sapiente delectus.";
				}else if(rand == 5){
					str = "voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis";
				}
				_spamcount++;
				Cc.ch("ch"+Math.round(Math.random()*5), _spamcount+" "+str, Math.round(Math.random()*10));
			}
		}
		
		private var _interval:uint;
	}
}
