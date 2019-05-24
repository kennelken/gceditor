package ru.kennel32.editor.view.hud.table.cells
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.ChangeItemCommand;
	import ru.kennel32.editor.data.commands.InspectRowCommand;
	import ru.kennel32.editor.view.components.selectbox.SelectItemBox;
	import ru.kennel32.editor.view.forms.dialog.content.InspectRowDialogContent;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class SelectIdTableRowCellView extends BaseTableRowCellView
	{
		private var _selectItemBox:SelectItemBox;
		private var _oldValue:uint;
		
		public function SelectIdTableRowCellView()
		{
			super();
			
			_selectItemBox = new SelectItemBox(-1, DEFAULT_TF_HEIGHT, false);
			_selectItemBox.addEventListener(Event.CHANGE, onChange);
			addChild(_selectItemBox);
			
			_type = TableColumnDescriptionType.SELECT_SINGLE_ID;
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, int.MAX_VALUE);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_selectItemBox.x = 3;
			_selectItemBox.y = (_height - _selectItemBox.height) / 2;
			
			_selectItemBox.setSize(_width - _selectItemBox.x * 2 - 1, -1);
		}
		
		private function onChange(e:Event):void
		{
			if (!dispatchChangeInnerTableValue(_selectItemBox.value))
			{
				Main.instance.commandsHistory.addCommandAndExecute(new ChangeItemCommand(_tableRow, _columnIndex, _oldValue, int(_selectItemBox.value)));
			}
			
			_oldValue = int(_selectItemBox.value);
		}
		
		override public function updateValue():void 
		{
			super.updateValue();
			
			releaseSelectedRow();
			
			var rowId:uint = _tableRow.data[_columnIndex];
			
			_selectItemBox.setTableItem(rowId, _columnData.idFrom);
			_selectItemBox.enabled = !locked;
			
			_selectedRow = Main.instance.rootTable.cache.getRowById(rowId, _columnData.idFrom);
			if (_selectedRow != null)
			{
				_selectedRow.addEventListener(Event.CHANGE, onSelectedRowChanged);
			}
			
			_oldValue = int(_selectItemBox.value);
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (!ViewUtils.isForInspect(e))
			{
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			
			if (_selectItemBox.value <= 0)
			{
				return;
			}
			InspectRowDialogContent.showRow(Main.instance.rootTable.cache.getRowById(int(_selectItemBox.value), _columnData.idFrom));
		}
		
		private var _selectedRow:TableRow;
		override public function dispose():void 
		{
			super.dispose();
			
			releaseSelectedRow();
		}
		
		private function releaseSelectedRow():void
		{
			if (_selectedRow != null)
			{
				_selectedRow.removeEventListener(Event.CHANGE, onSelectedRowChanged);
				_selectedRow = null;
			}
		}
		
		private function onSelectedRowChanged(e:Event):void
		{
			updateValue();
		}
	}
}