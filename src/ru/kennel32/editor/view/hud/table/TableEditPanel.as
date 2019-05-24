package ru.kennel32.editor.view.hud.table 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.AddRowCommand;
	import ru.kennel32.editor.data.commands.DeleteRowsCommand;
	import ru.kennel32.editor.data.commands.DeleteTablesCommand;
	import ru.kennel32.editor.data.commands.DuplicateRowsCommand;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.utils.Hardcode;
	import ru.kennel32.editor.view.components.buttons.BtnAdd;
	import ru.kennel32.editor.view.components.buttons.BtnDelete;
	import ru.kennel32.editor.view.components.buttons.BtnDuplicate;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.forms.dialog.content.EditTableDialogContent;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class TableEditPanel extends CanvasSprite implements IDisposable
	{
		private var _parent:TableView;
		
		private var _region:ExpandableRegion;
		private var _tfNumEntries:TextField;
		private var _tfNumSelectedEntries:TextField;
		
		private var _btnAdd:BtnAdd;
		private var _btnDelete:BtnDelete;
		private var _btnDuplicate:BtnDuplicate;
		
		public function TableEditPanel(parent:TableView)
		{
			super();
			
			_parent = parent;
			
			_region = new ExpandableRegion(RectSides.SIDES_0000, null, ExpandableRegionStyle.COLUMN_HEAD);
			_region.setSize(-1, 27);
			addChild(_region);
			
			_tfNumEntries = TextUtils.getText('', Color.FONT, 16);
			_tfNumEntries.x = 2;
			_tfNumEntries.y = 2;
			addChild(_tfNumEntries);
			
			_tfNumSelectedEntries = TextUtils.getText('', Color.FONT, 16);
			_tfNumSelectedEntries.y = _tfNumEntries.y;
			addChild(_tfNumSelectedEntries);
			
			_btnAdd = new BtnAdd(20);
			_btnAdd.x = 3;
			_btnAdd.y = 3;
			_btnAdd.addEventListener(MouseEvent.CLICK, onBtnAddClick);
			addChild(_btnAdd);
			
			_btnDelete = new BtnDelete(20);
			_btnDelete.x = _btnAdd.x + _btnAdd.width + 3;
			_btnDelete.y = _btnAdd.y;
			_btnDelete.addEventListener(MouseEvent.CLICK, onBtnDeleteClick);
			addChild(_btnDelete);
			
			_btnDuplicate = new BtnDuplicate(20);
			_btnDuplicate.x = _btnDelete.x + _btnDelete.width + 3;
			_btnDuplicate.y = _btnAdd.y;
			_btnDuplicate.addEventListener(MouseEvent.CLICK, onBtnDuplicateClick);
			addChild(_btnDuplicate);
			
			setSize(-1, _region.height);
		}
		
		public function init():void
		{
		}
		
		public function dispose():void
		{
			cleanup();
		}
		
		private function cleanup():void
		{
			
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_region.setSize(_width, -1);
			
			_tfNumEntries.x = _width - _tfNumEntries.textWidth - 50 - _tfNumSelectedEntries.textWidth - 50;
			_tfNumSelectedEntries.x = _tfNumEntries.x + _tfNumEntries.textWidth + 50;
		}
		
		public function onRowsSelectedChanged():void
		{
			var isDataTable:Boolean = _parent.data is DataTable;
			var numSelected:int = (isDataTable ? _parent.getCheckedRows() : _parent.getCheckedSubtables()).length;
			
			_tfNumEntries.text = Texts.textNumEntries + '' + (isDataTable ? _parent.rows : _parent.subtables).length;
			_tfNumSelectedEntries.text = Texts.textNumSelectedEntries + '' + numSelected;
			
			updateButtonsEnabled();
			
			setSize(-1, -1);
		}
		
		public function onDataChanged():void
		{
			onRowsSelectedChanged();
			
			_btnAdd.visible = _parent.data != null;
			_btnDelete.visible = _parent.data != null;
			_btnDuplicate.visible = _parent.data is DataTable;
			
			updateButtonsEnabled();
		}
		
		private function updateButtonsEnabled():void
		{
			var isDataTable:Boolean = _parent.data is DataTable;
			var numSelected:int = (isDataTable ? _parent.getCheckedRows() : _parent.getCheckedSubtables()).length;
			
			_btnAdd.enabled = _parent.data != null && !_parent.data.meta.forInnerTable && !Hardcode.isLockedData(_parent.data.meta);
			_btnDelete.enabled = _btnAdd.enabled && numSelected > 0 && !Hardcode.isLockedData(_parent.data.meta);
			_btnDuplicate.enabled = _btnDelete.enabled && !Hardcode.isLockedData(_parent.data.meta);
		}
		
		private function onRowSelectionChanged(e:Event):void
		{
			onRowsSelectedChanged();
		}
		
		private function onBtnAddClick(e:Event):void
		{
			var dataTable:DataTable = _parent.data as DataTable;
			if (dataTable != null)
			{
				Main.instance.commandsHistory.addCommandAndExecute(new AddRowCommand(dataTable, dataTable.createNewRow(1)));
			}
			else
			{
				initCreateNewTable(_parent.data as ContainerTable);
			}
		}
		
		private function onBtnDeleteClick(e:Event):void
		{
			var canNotDeleteIds:Vector.<int> = new Vector.<int>();
			
			var dataTable:DataTable = _parent.data as DataTable;
			if (dataTable != null)
			{
				var checkedRows:Vector.<TableRowView> = _parent.getCheckedRows();
				var rows:Vector.<TableRow> = new Vector.<TableRow>();
				for (var i:int = 0; i < checkedRows.length; i++)
				{
					var row:TableRow = checkedRows[i].data;
					rows.push(row);
					if (row.lock || row.isSystem ||
						row is Counter && Main.instance.rootTable.cache.getTablesByCounterId(row.id).length > 0)
					{
						canNotDeleteIds.push(checkedRows[i].data.id);
					}
				}
				
				if (canNotDeleteIds.length <= 0)
				{
					if (rows.length <= 0)
					{
						DialogFormParams.create().setText(Texts.textNothingSelected).show();
					}
					else
					{
						Main.instance.mainUI.doBeforeRowsDeleted(rows);
						Main.instance.commandsHistory.addCommandAndExecute(new DeleteRowsCommand(dataTable, rows));
					}
				}
				else
				{
					DialogFormParams.create().setText(Texts.textCannotDeleteRows + '\n' + canNotDeleteIds.join(', ')).show();
				}
			}
			else
			{
				var containerTable:ContainerTable = _parent.data as ContainerTable;
				
				var checkedTables:Vector.<SubtableItemView> = _parent.getCheckedSubtables();
				var tables:Vector.<BaseTable> = new Vector.<BaseTable>();
				
				for (i = 0; i < checkedTables.length; i++)
				{
					tables.push(checkedTables[i].data);
				}
				
				initDeleteTables(containerTable, tables);
			}
		}
		
		private function onBtnDuplicateClick(e:Event):void
		{
			var canNotDuplicateIds:Vector.<int> = new Vector.<int>();
			
			var dataTable:DataTable = _parent.data as DataTable;
			if (dataTable != null)
			{
				var checkedRows:Vector.<TableRowView> = _parent.getCheckedRows();
				var rows:Vector.<TableRow> = new Vector.<TableRow>();
				for (var i:int = 0; i < checkedRows.length; i++)
				{
					rows.push(checkedRows[i].data);
					if (checkedRows[i].data.lock)
					{
						canNotDuplicateIds.push(checkedRows[i].data.id);
					}
				}
				
				if (canNotDuplicateIds.length <= 0)
				{
					if (rows.length <= 0)
					{
						DialogFormParams.create().setText(Texts.textNothingSelected).show();
					}
					else
					{
						Main.instance.commandsHistory.addCommandAndExecute(new DuplicateRowsCommand(dataTable, rows));
					}
				}
				else
				{
					DialogFormParams.create().setText(Texts.textCannotDuplicateRows + '\n' + canNotDuplicateIds.join(', ')).show();
				}
			}
		}
		
		public static function initCreateNewTable(containerTable:ContainerTable):void
		{
			var content:EditTableDialogContent = new EditTableDialogContent(null, containerTable);
			DialogFormParams.create().setText(Texts.textCreateNewTable).setContent(content).show();
		}
		
		public static function initDeleteTables(containerTable:ContainerTable, tables:Vector.<BaseTable>):void
		{
			var canNotDeleteIds:Vector.<int> = new Vector.<int>();
			
			for (var i:int = 0; i < tables.length; i++)
			{
				if (Hardcode.isSystemMeta(tables[i].meta))
				{
					canNotDeleteIds.push(tables[i].meta.id);
					continue;
				}
				
				if (tables[i].meta.forInnerTable && Main.instance.rootTable.cache.getTablesByInnerTableMeta(tables[i].meta.id).length > 0)
				{
					canNotDeleteIds.push(tables[i].meta.id);
					continue;
				}
				
				var childDataTable:DataTable = tables[i] as DataTable;
				var childContainerTable:ContainerTable = tables[i] as ContainerTable;
				
				if (childDataTable != null && childDataTable.rows.length > 0)
				{
					canNotDeleteIds.push(tables[i].meta.id);
					continue;
				}
				if (childContainerTable != null && childContainerTable.children.length > 0)
				{
					canNotDeleteIds.push(tables[i].meta.id);
					continue;
				}
			}
			
			if (canNotDeleteIds.length <= 0)
			{
				if (tables.length <= 0)
				{
					DialogFormParams.create().setText(Texts.textNothingSelected).show();
				}
				else
				{
					Main.instance.mainUI.doBeforeTablesDeleted(tables);
					Main.instance.commandsHistory.addCommandAndExecute(new DeleteTablesCommand(containerTable, tables));
				}
			}
			else
			{
				DialogFormParams.create().setText(Texts.textCanNotDeleteNotEmptyTable + '\n' + canNotDeleteIds.join(', ')).show();
			}
		}
	}
}