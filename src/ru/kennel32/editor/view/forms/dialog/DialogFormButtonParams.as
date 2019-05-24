package ru.kennel32.editor.view.forms.dialog
{
	public class DialogFormButtonParams
	{
		public var name:String;
		public var callback:Function;
		public var callbackParams:Array;
		public var keyCode:int;
		
		public function DialogFormButtonParams(name:String, callback:Function = null, callbackParams:Array = null, keyCode:int = -1)
		{
			this.name = name;
			this.callback = callback;
			this.callbackParams = callbackParams;
			this.keyCode = keyCode;
		}
		
		public function callCallback():void
		{
			if (callback != null)
			{
				callback.apply(null, callbackParams);
			}
		}
	}
}