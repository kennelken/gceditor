package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.commands.SelectTableCommand;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.table.find.FindResultEntry;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class FindResultEntryView extends CanvasSprite
	{
		private var _bgTable:ExpandableRegion;
		private var _tfTable:TextField;
		
		private var _bgGroup:ExpandableRegion;
		private var _tfGroup:TextField;
		
		private var _bgWhere:ExpandableRegion;
		private var _tfWhere:TextField;
		private var _defaultTextFormat:TextFormat;
		private var _selectedTextFormat:TextFormat;
		
		private var _bgInspect:ExpandableRegion;
		private var _btnInspect:LabeledButton;
		
		public function FindResultEntryView(stopChildEvents:Boolean=false)
		{
			super(stopChildEvents);
			
			_bgTable = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.FIND_ENTRY);
			addChild(_bgTable);
			_tfTable = TextUtils.getText('', Color.FONT, 12);
			_tfTable.x = 2;
			_tfTable.y = 1;
			_bgTable.addChild(_tfTable);
			
			_bgGroup = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.FIND_ENTRY);
			addChild(_bgGroup);
			_tfGroup = TextUtils.getText('', Color.FONT, 12);
			_tfGroup.x = 2;
			_tfGroup.y = 1;
			_bgGroup.addChild(_tfGroup);
			
			_bgWhere = new ExpandableRegion(RectSides.SIDES_0101, null, ExpandableRegionStyle.FIND_ENTRY);
			addChild(_bgWhere);
			_tfWhere = TextUtils.getText('', Color.FONT, 12);
			_tfWhere.x = 2;
			_tfWhere.y = 1;
			_bgWhere.addChild(_tfWhere);
			
			_defaultTextFormat = _tfWhere.defaultTextFormat;
			_selectedTextFormat = new TextFormat(_defaultTextFormat.font, _defaultTextFormat.size, Color.RED);
			
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
			
			_bgTable.setSize(180, _height);
			_bgGroup.setSize(180, _height);
			_bgInspect.setSize(80, _height);
			
			_tfTable.autoSize = TextFieldAutoSize.NONE;
			_tfTable.width = _bgTable.width - _tfTable.width * 2;
			
			_tfGroup.autoSize = TextFieldAutoSize.NONE;
			_tfGroup.width = _bgGroup.width - _tfGroup.x * 2;
			
			_bgWhere.setSize(_width - _bgTable.width - _bgGroup.width - _bgInspect.width, _height);
			
			_tfWhere.autoSize = TextFieldAutoSize.NONE;
			_tfWhere.width = _bgWhere.width - _tfWhere.x * 2;
			
			_btnInspect.setSize(_bgInspect.width - _btnInspect.x * 2 - 1, _bgInspect.height - _btnInspect.y * 2);
			
			alignChildren(Align.V_TOP, 0);
		}
		
		private var _data:FindResultEntry;
		public function get data():FindResultEntry
		{
			return _data;
		}
		public function set data(value:FindResultEntry):void
		{
			_data = value;
			
			if (_data == null)
			{
				_tfTable.text = '';
				_tfGroup.text = '';
				_tfWhere.text = '';
				
				_btnInspect.enabled = false;
				return;
			}
			
			_tfTable.text = ViewUtils.getTableName(_data.table.meta.id);
			_tfGroup.text = _data.groupDescription;
			
			_tfWhere.defaultTextFormat = _defaultTextFormat;
			_tfWhere.text = _data.where != null ? _data.where : '';
			if (_data.where != null && _data.whereSelectionStartIndex != _data.whereSelectionEndIndex)
			{
				_tfWhere.setTextFormat(_selectedTextFormat, _data.whereSelectionStartIndex, _data.whereSelectionEndIndex);
			}
			_tfWhere.height = _tfWhere.textHeight + 5;
			
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