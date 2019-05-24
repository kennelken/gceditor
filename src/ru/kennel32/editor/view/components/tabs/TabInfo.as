package ru.kennel32.editor.view.components.tabs
{
	public class TabInfo
	{
		public var name:String;
		public var value:Object;
		
		public var needCheckBox:Boolean;
		public var checked:Boolean;
		
		public var selected:Boolean;
		
		public function TabInfo(name:String, value:Object, needCheckBox:Boolean, checked:Boolean, selected:Boolean)
		{
			this.name = name;
			this.value = value;
			
			this.needCheckBox = needCheckBox;
			this.checked = checked;
			
			this.selected = selected;
		}
	}
}