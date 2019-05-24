package ru.kennel32.editor.view.hud.table
{
	import flash.events.Event;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.commands.DeselectRowCommand;
	import ru.kennel32.editor.data.commands.SelectRowCommand;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.controls.CheckBox;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class SubtableItemView extends CanvasSprite implements IDisposable
	{
		private var _checkBoxRegion:ExpandableRegion;
		private var _checkBox:CheckBox;
		private var _data:BaseTable;
		
		private var _nameRegion:ExpandableRegion;
		private var _tfName:TextField;
		
		public function SubtableItemView(top:Boolean)
		{
			super(true);
			
			_checkBoxRegion = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.COLUMN_HEAD_STATIC);
			_checkBoxRegion.setSize(TableView.CHECKBOX_COLUMN_WIDTH, 30);
			addChild(_checkBoxRegion);
			
			_checkBox = new CheckBox(17);
			_checkBox.x = ((_checkBoxRegion.width - _checkBox.width) / 2) - 1;
			_checkBox.addEventListener(Event.CHANGE, onCheckBoxChanged);
			addChild(_checkBox);
			
			_nameRegion = new ExpandableRegion(top ? RectSides.SIDES_0111 : RectSides.SIDES_0101, null, ExpandableRegionStyle.CELL_REGULAR);
			_nameRegion.setSize(100, _checkBoxRegion.height);
			_nameRegion.x = _checkBoxRegion.width;
			addChild(_nameRegion);
			
			_tfName = TextUtils.getText('', Color.FONT, 16);
			_tfName.selectable = true;
			_tfName.x = _nameRegion.x;
			
			addChild(_tfName);
			
			setSize(550, 30);
		}
		
		public function set data(value:BaseTable):void
		{
			if (_data == value)
			{
				return;
			}
			
			cleanup();
			
			_data = value;
			
			if (_data == null)
			{
				return;
			}
			
			_data.addEventListener(Event.CHANGE, onDataChange);
			_data.addEventListener(TableEvent.TABLE_CHECKED_CHANGED, onCheckedChanged);
			_data.addEventListener(TableEvent.META_CHANGED, onMetaChanged);
			
			update();
			
			_checkBox.checked = _data.checked;
			
			setSize(-1, -1);
		}
		public function get data():BaseTable
		{
			return _data;
		}
		
		private function update():void
		{
			_tfName.text = _data.meta.id + '.' + _data.meta.name;
		}
		
		private function cleanup():void
		{
			if (_data != null)
			{
				_data.removeEventListener(Event.CHANGE, onDataChange);
				_data.removeEventListener(TableEvent.TABLE_CHECKED_CHANGED, onCheckedChanged);
				_data.removeEventListener(TableEvent.META_CHANGED, onMetaChanged);
				
				_data = null;
			}
		}
		
		public function dispose():void
		{
			cleanup();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_checkBoxRegion.setSize(-1, _height);
			_checkBox.y = ((_checkBoxRegion.height - _checkBox.height) / 2) - 1;
			
			_nameRegion.setSize(_width - _nameRegion.x - 1, _height);
			_tfName.y = _checkBox.y;
		}
		
		public function get checked():Boolean
		{
			return _checkBox.checked;
		}
		
		private function onDataChange(e:Event):void
		{
			update();
		}
		
		private function onCheckBoxChanged(e:Event):void
		{
			Main.instance.commandsHistory.addCommandAndExecute(_checkBox.checked ? new SelectRowCommand(null, _data, _data.checked) : new DeselectRowCommand(null, _data, _data.checked));
		}
		
		private function onCheckedChanged(e:Event):void
		{
			_checkBox.checked = _data.checked;
		}
		
		private function onMetaChanged(e:Event):void
		{
			update();
		}
	}
}