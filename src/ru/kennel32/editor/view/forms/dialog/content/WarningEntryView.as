package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.commands.SelectTableCommand;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.helper.warning.WarningData;
	import ru.kennel32.editor.data.helper.warning.WarningLevel;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class WarningEntryView extends CanvasSprite
	{
		private var _bgTable:ExpandableRegion;
		private var _tfTable:TextField;
		
		private var _bgMessage:ExpandableRegion;
		private var _tfMessage:TextField;
		
		private var _bgInspect:ExpandableRegion;
		private var _btnInspect:LabeledButton;
		
		public function WarningEntryView(stopChildEvents:Boolean=false)
		{
			super(stopChildEvents);
			
			_bgTable = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.FIND_ENTRY);
			addChild(_bgTable);
			_tfTable = TextUtils.getText('', Color.FONT, 12);
			_tfTable.x = 2;
			_tfTable.y = 1;
			_bgTable.addChild(_tfTable);
			
			_bgMessage = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.FIND_ENTRY);
			addChild(_bgMessage);
			_tfMessage = TextUtils.getText('', 0, 12);
			_tfMessage.x = 2;
			_tfMessage.y = 1;
			_bgMessage.addChild(_tfMessage);
			
			_bgInspect = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.FIND_ENTRY);
			addChild(_bgInspect);
			_btnInspect = new LabeledButton(Texts.inspect);
			_btnInspect.x = 2;
			_btnInspect.y = 2;
			_btnInspect.addEventListener(MouseEvent.CLICK, onBtnInspectClick);
			_bgInspect.addChild(_btnInspect);
			_bgInspect.mouseChildren = true;
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, int.MAX_VALUE);
			
			cacheAsBitmap = true;
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_bgTable.setSize(550, _height);
			_bgMessage.setSize(width - 550 - 80 - 16, _height);
			_bgInspect.setSize(80, _height);
			
			_tfTable.autoSize = TextFieldAutoSize.NONE;
			_tfTable.width = _bgTable.width - _tfTable.width * 2;
			
			_tfMessage.autoSize = TextFieldAutoSize.NONE;
			_tfMessage.width = _bgMessage.width - _tfMessage.x * 2;
			
			_btnInspect.setSize(_bgInspect.width - _btnInspect.x * 2 - 1, _bgInspect.height - _btnInspect.y * 2);
			
			alignChildren(Align.V_TOP, 0);
		}
		
		private var _data:WarningData;
		public function get data():WarningData
		{
			return _data;
		}
		public function set data(value:WarningData):void
		{
			_data = value;
			
			if (_data == null)
			{
				_tfTable.text = '';
				_tfMessage.text = '';
				
				_btnInspect.enabled = false;
				return;
			}
			
			_tfTable.text = '';
			TextUtils.addColoredText(_tfTable, ViewUtils.getTableName(_data.table.meta.id), Color.FONT);
			if (_data.column != null)
			{
				TextUtils.addColoredText(_tfTable, '/' + _data.column.name, Color.FONT_MEDIUM);
			}
			if (_data.row != null)
			{
				TextUtils.addColoredText(_tfTable, '/' + _data.row.nameWithId, Color.FONT_UNIMPORTANT);
			}
			
			_tfMessage.text = Texts.getWarningMessage(_data.type);
			switch (_data.type.level)
			{
				case WarningLevel.ERROR:
					_tfMessage.textColor = Color.FONT_IMPORTANT;
					break;
				
				case WarningLevel.WARNING:
					_tfMessage.textColor = Color.FONT_WARNING;
					break;
				
				case WarningLevel.MESSAGE:
					_tfMessage.textColor = Color.FONT;
					break;
			}
			
			_btnInspect.enabled = _data.row != null || _data.table != null;
		}
		
		private function onBtnInspectClick(e:Event = null):void
		{
			if (_data.row == null)
			{
				var currentTable:BaseTable = Main.instance.selectedTable;
				if (currentTable != _data.table)
				{
					Main.instance.commandsHistory.addCommandAndExecute(new SelectTableCommand(_data.table, currentTable));
				}
				return;
			}
			
			InspectRowDialogContent.showRow(_data.row);
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (!ViewUtils.isForInspect(e))
			{
				return;
			}
			
			e.stopImmediatePropagation();
			e.preventDefault();
			
			onBtnInspectClick(null);
		}
	}
}