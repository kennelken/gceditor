package ru.kennel32.editor.view 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.view.components.windows.WindowsCanvas;
	import ru.kennel32.editor.view.hud.MainHUD;
	import ru.kennel32.editor.view.hud.effects.AttentionEffect;
	
	public class MainUI extends Sprite
	{
		private var _mainHUD:MainHUD;
		private var _windowsCanvas:WindowsCanvas;
		
		public function MainUI()
		{
			super();
			
			_mainHUD = new MainHUD();
			addChild(_mainHUD);
			
			_windowsCanvas = new WindowsCanvas();
			addChild(_windowsCanvas);
		}
		
		public function init():void
		{
			_mainHUD.init();
		}
		
		public function setSize(width:int, height:int):void
		{
			_mainHUD.setSize(width, height);
			_windowsCanvas.setSize(width, height);
		}
		
		public function get mainHUD():MainHUD
		{
			return _mainHUD;
		}
		
		public function playAttentionEffect(dobj:DisplayObject, error:Boolean = false):void
		{
			new AttentionEffect(dobj, this).play(true, error);
		}
		
		public function doBeforeTablesDeleted(tables:Vector.<BaseTable>):void
		{
			for each (var table:BaseTable in tables)
			{
				dispatchEvent(new TableEvent(TableEvent.TABLES_DELETED, table));
			}
		}
		
		public function doBeforeRowsDeleted(rows:Vector.<TableRow>):void
		{
			for each (var row:TableRow in rows)
			{
				dispatchEvent(new TableEvent(TableEvent.ROWS_DELETED, row.parent, row));
			}
		}
	}
}