package ru.kennel32.editor.view.components.tabs
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	
	public class TabsGroup extends CanvasSprite
	{
		public function TabsGroup(width:int = -1, height:int = -1)
		{
			super();
			
			setSize(width, height);
		}
		
		private var _values:Vector.<TabInfo>;
		public function get values():Vector.<TabInfo>
		{
			return _values;
		}
		public function set values(list:Vector.<TabInfo>):void
		{
			removeAllChildren(true);
			
			_values = list;
			for each (var tab:TabInfo in list)
			{
				var tabView:TabView = new TabView();
				tabView.data = tab;
				
				tabView.addEventListener(MouseEvent.CLICK, onTabClick);
				addChild(tabView);
			}
			
			update();
			setSize(_width, _height);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:TabView = getChildAt(i) as TabView;
				
				child.setSize(int(_width / numChildren), _height);
			}
			
			alignChildren(Align.V_TOP, NaN, true);
		}
		
		private function onTabClick(e:Event):void
		{
			var tab:TabView = e.currentTarget as TabView;
			
			if (!tab.data.selected)
			{
				selectedTab = tab.data;
				dispatchEvent(new TabEvent(TabEvent.TAB_CLICK, tab.data));
			}
		}
		
		private var _selectedTab:TabInfo;
		public function get selectedTab():TabInfo
		{
			return _selectedTab;
		}
		public function set selectedTab(tab:TabInfo):void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:TabView = getChildAt(i) as TabView;
				
				child.data.selected = child.data == tab;
				if (child.data.selected)
				{
					_selectedTab = tab;
				}
			}
			
			update();
		}
		
		public function get selectedValue():Object
		{
			return _selectedTab != null ? _selectedTab.value : null;
		}
		public function set selectedValue(value:Object):void
		{
			selectedTab = getTabByValue(value);
		}
		
		public function update():void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:TabView = getChildAt(i) as TabView;
				
				child.update();
			}
		}
		
		public function getTabByValue(value:Object):TabInfo
		{
			for each (var tab:TabInfo in _values)
			{
				if (tab.value == value)
				{
					return tab;
				}
			}
			
			return null;
		}
	}
}