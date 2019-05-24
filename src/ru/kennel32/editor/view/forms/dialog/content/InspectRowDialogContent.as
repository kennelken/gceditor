package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.CloseInspectRowCommand;
	import ru.kennel32.editor.data.commands.InspectRowCommand;
	import ru.kennel32.editor.data.commands.SelectTableCommand;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.components.interfaces.IModalForm;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.components.windows.ModalBack;
	import ru.kennel32.editor.view.components.windows.WindowsCanvas;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.BaseForm;
	import ru.kennel32.editor.view.forms.dialog.DialogForm;
	import ru.kennel32.editor.view.hud.table.TableColumnHeadView;
	import ru.kennel32.editor.view.hud.table.TableRowView;
	import ru.kennel32.editor.view.hud.table.cells.BaseTableRowCellView;
	import ru.kennel32.editor.view.interfaces.IAllowCommandsHistoryChange;
	import ru.kennel32.editor.view.interfaces.IClosableByUser;
	import ru.kennel32.editor.view.interfaces.ICustomPositionable;
	import ru.kennel32.editor.view.interfaces.ICustomSizeable;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	
	public class InspectRowDialogContent extends BaseDialogContent implements IDisposable, IAllowCommandsHistoryChange, IClosableByUser, ICustomSizeable, ICustomPositionable, IModalForm
	{
		private static const MIN_HEADS_WIDTH:int = 100;
		private var _headsWidth:int;
		
		private var _cmd:InspectRowCommand;
		
		private var _canvas:ScrollableCanvas;
		private var _boxContent:ExpandableRegion;
		private var _heads:Vector.<TableColumnHeadView>;
		private var _tableRowView:TableRowView;
		
		private var _boxButtons:CanvasSprite;
		private var _btnShowInTable:LabeledButton;
		private var _btnFindUsage:LabeledButton;
		
		private var _randomStartOffsetX:int;
		private var _randomStartOffsetY:int;
		
		public static function showRow(row:TableRow):void
		{
			var allDialogs:Vector.<BaseForm> = WindowsCanvas.instance.getFormsByClass(DialogForm);
			for each (var dialog:DialogForm in allDialogs)
			{
				var inspectRowContent:InspectRowDialogContent = dialog.params.content as InspectRowDialogContent;
				if (inspectRowContent != null && inspectRowContent._cmd.row == row)
				{
					WindowsCanvas.instance.setActiveForm(dialog);
					return;
				}
			}
			
			Main.instance.commandsHistory.addCommandAndExecute(new InspectRowCommand(row));
		}
		
		public function InspectRowDialogContent(cmd:InspectRowCommand)
		{
			super();
			
			_cmd = cmd;
			
			_boxContent = new ExpandableRegion(null, null, new ExpandableRegionStyle(Color.BORDER_LIGHT, 1, 0, 0));
			_boxContent.mouseChildren = true;
			
			_heads = new Vector.<TableColumnHeadView>();
			
			_tableRowView = new TableRowView(true);
			_tableRowView.y = 1;
			_boxContent.addChild(_tableRowView);
			
			_canvas = new ScrollableCanvas();
			addChild(_canvas);
			_canvas.setContent(_boxContent);
			
			Settings.addEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			onTableScaleChanged();
			
			_boxButtons = new CanvasSprite();
			addChild(_boxButtons);
			
			_btnShowInTable = new LabeledButton(Texts.showInTable);
			_btnShowInTable.setSize(170);
			_btnShowInTable.addEventListener(MouseEvent.CLICK, onShowInTable);
			
			_btnFindUsage = new LabeledButton(Texts.findUsage);
			_btnFindUsage.setSize(150);
			_btnFindUsage.addEventListener(MouseEvent.CLICK, onFindUsage);
			
			_randomStartOffsetX = Math.random() * 100;
			_randomStartOffsetY = Math.random() * 100;
			
			cacheAsBitmap = true;
		}
		
		public function setData(row:TableRow):void
		{
			_tableRowView.data = row;
			
			addHeads(row.parent.meta);
			
			_tableRowView.x = 1 + _headsWidth;
			
			_boxContent.setSize(
				(_tableRowView.x + _tableRowView.width),
				(_tableRowView.y + _tableRowView.height)
			);
			
			_canvas.init();
			_canvas.setSize(
				Math.min(WindowsCanvas.instance.width - 130, _boxContent.width * _boxContent.scaleX + 12),
				Math.min(WindowsCanvas.instance.height - 130, _boxContent.height * _boxContent.scaleY)
			);
			
			_boxButtons.removeAllChildren(false);
			_boxButtons.addChild(_btnShowInTable);
			_boxButtons.addChild(_btnFindUsage);
			
			_boxButtons.y = _canvas.height + 8;
			_boxButtons.alignChildren(Align.V_TOP, 10);
			_boxButtons.fitToContent();
			_boxButtons.x = int((_canvas.width - _boxButtons.width) / 2);
			
			_width = _canvas.width;
			_height = _boxButtons.y + (_boxButtons.numChildren > 0 ? _boxButtons.height : 0);
			
			Main.instance.mainUI.addEventListener(TableEvent.ROWS_DELETED, onRowDeleted);
			Main.instance.mainUI.addEventListener(TableEvent.TABLES_DELETED, onTableDeleted);
		}
		
		private function addHeads(meta:TableMeta):void
		{
			_headsWidth = MIN_HEADS_WIDTH;
			for (var i:int = 0; i < meta.allColumns.length; i++)
			{
				var columnDescription:TableColumnDescription = meta.allColumns[i];
				
				var columnHead:TableColumnHeadView = new TableColumnHeadView(true, true);
				columnHead.minWidth = MIN_HEADS_WIDTH;
				columnHead.data = columnDescription;
				
				_headsWidth = Math.max(_headsWidth, columnHead.preferredWidth);
				
				_boxContent.addChild(columnHead);
				_heads.push(columnHead);
			}
			for (i = 0; i < _heads.length; i++)
			{
				var cellView:BaseTableRowCellView = _tableRowView.boxCells.getChildAt(i) as BaseTableRowCellView;
				
				columnHead = _heads[i];
				columnHead.setSize(_headsWidth, cellView.contentHeight);
				
				columnHead.x = 1;
				columnHead.y = _tableRowView.y + cellView.y;
			}
		}
		
		public function dispose():void
		{
			_tableRowView.dispose();
			_canvas.dispose();
			
			for each (var head:TableColumnHeadView in _heads)
			{
				head.dispose();
			}
			_heads.length = 0;
			
			Main.instance.mainUI.removeEventListener(TableEvent.ROWS_DELETED, onRowDeleted);
			Main.instance.mainUI.removeEventListener(TableEvent.TABLES_DELETED, onTableDeleted);
		}
		
		private function onRowDeleted(e:TableEvent):void
		{
			if (_cmd.row == e.row)
			{
				onClosedByUser();
				_parentForm.close();
			}
		}
		
		private function onTableDeleted(e:TableEvent):void
		{
			if (_cmd.row.parent == e.parent)
			{
				onClosedByUser();
				_parentForm.close();
			}
		}
		
		public function get scrollPosition():Point
		{
			return new Point(_boxContent.x, _boxContent.y);
		}
		public function set scrollPosition(value:Point):void
		{
			_boxContent.x = value.x;
			_boxContent.y = value.y;
			_canvas.updateControls(false);
		}
		
		private function onTableScaleChanged(e:Event = null):void
		{
			_boxContent.scaleX = _boxContent.scaleY = Settings.tableScale;
			_canvas.updateControls(false);
		}
		
		public function onClosedByUser():void
		{
			Main.instance.commandsHistory.addExecutedCommand(new CloseInspectRowCommand(_cmd));
		}
		
		private function onShowInTable(e:Event):void
		{
			Main.instance.commandsHistory.addCommandAndExecute(new SelectTableCommand(
				_cmd.row.parent,
				Main.instance.selectedTable,
				_cmd.row
			));
		}
		
		private function onFindUsage(e:Event):void
		{
			FindDialogContent.openDialog(true, _tableRowView.data);
		}
		
		private var _width:int;
		override public function get width():Number 
		{
			return _width;
		}
		
		private var _height:int;
		override public function get height():Number 
		{
			return _height;
		}
		
		public function onPosOffsetChanged(x:int, y:int):void
		{
			Settings.inspectOffsetX = x - _randomStartOffsetX;
			Settings.inspectOffsetY = y - _randomStartOffsetY;
		}
		public function get posOffsetX():int
		{
			return Settings.inspectOffsetX + _randomStartOffsetX;
		}
		public function get posOffsetY():int
		{
			return Settings.inspectOffsetY + _randomStartOffsetY;
		}
		
		public function get modalBack():ModalBack
		{
			return null;
		}
		public function get isModal():Boolean
		{
			return false;
		}
	}
}