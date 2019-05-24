package ru.kennel32.editor.view.components.tabs
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.controls.CheckBox;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class TabView extends CanvasSprite
	{
		private var _data:TabInfo;
		
		private var _regionUnselected:ExpandableRegion;
		private var _regionSelected:ExpandableRegion;
		private var _tfBox:Sprite;
		private var _tf:TextField;
		private var _checkBox:CheckBox;
		
		public function TabView(stopChildEvents:Boolean=false)
		{
			super(stopChildEvents);
			
			_tfBox = new Sprite();	//fix buttonMode+textfield bug
			_tfBox.mouseChildren = false;
			_tfBox.mouseEnabled = false;
			addChild(_tfBox);
			
			_tf = TextUtils.getTextCentered('', Color.FONT, 14);
			_tf.height = 19;
			
			_checkBox = new CheckBox(20);
			_checkBox.addEventListener(Event.CHANGE, onCheckBoxChange);
			_regionUnselected = new ExpandableRegion(null, null, ExpandableRegionStyle.TAB_UNSELECTED);
			_regionSelected = new ExpandableRegion(null, null, ExpandableRegionStyle.TAB_SELECTED);
		}
		
		public function get data():TabInfo
		{
			return _data;
		}
		public function set data(data:TabInfo):void
		{
			_data = data;
			
			update();
		}
		
		public function update():void
		{
			if (_data == null)
			{
				buttonMode = false;
				ViewUtils.setParent(_tf, _tfBox, false);
				ViewUtils.setParent(_checkBox, this, false);
				return;
			}
			
			ViewUtils.setParent(_regionUnselected, this, false);
			ViewUtils.setParent(_regionSelected, this, false);
			
			buttonMode = !_data.selected;
			ViewUtils.setParent(_tf, _tfBox, true);
			ViewUtils.setParent(_checkBox, this, _data.needCheckBox);
			
			_checkBox.checked = _data.checked;
			
			var sidesOffset:int = 3;
			
			_tf.text = _data.name;
			_tf.width = _width - 2 * sidesOffset - (_data.needCheckBox ? _checkBox.width + 4 : 0);
			
			alignChildren(Align.V_CENTER, NaN, true, 3);
			_checkBox.y += 1;
			
			ViewUtils.setParent(_regionUnselected, this, !_data.selected, 0);
			ViewUtils.setParent(_regionSelected, this, _data.selected, 0);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_regionUnselected.setSize(_width, _height);
			_regionSelected.setSize(_width, _height);
			
			update();
		}
		
		private function onCheckBoxChange(e:Event):void
		{
			_data.checked = _checkBox.checked;
		}
	}
}