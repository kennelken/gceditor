package ru.kennel32.editor.view.components.selectbox
{
	public class SelectBoxValue
	{
		public var value:Object;
		public var name:String;
		public var hidden:Boolean;
		public var alwaysShown:Boolean;
		
		public function SelectBoxValue(value:Object, name:String, alwaysShown:Boolean = false, hidden:Boolean = false)
		{
			this.value = value;
			this.name = name;
			this.alwaysShown = alwaysShown;
			this.hidden = hidden;
		}
		
		public static function wrapToList(values:*, names:Vector.<String>):Vector.<SelectBoxValue>
		{
			var res:Vector.<SelectBoxValue> = new Vector.<SelectBoxValue>();
			
			for (var i:int = 0; i < values['length']; i++)
			{
				res.push(new SelectBoxValue(values[i], names[i], false, false));
			}
			
			return res;
		}
	}
}