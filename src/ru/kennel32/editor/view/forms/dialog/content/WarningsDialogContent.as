package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.events.Event;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.helper.warning.WarningData;
	import ru.kennel32.editor.data.helper.warning.WarningLevel;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.components.interfaces.IModalForm;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.components.tabs.TabEvent;
	import ru.kennel32.editor.view.components.windows.ModalBack;
	import ru.kennel32.editor.view.components.windows.WindowsCanvas;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.factory.ObjectsPool;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.interfaces.IAllowCommandsHistoryChange;
	import ru.kennel32.editor.view.interfaces.ICustomPositionable;
	import ru.kennel32.editor.view.interfaces.ICustomSizeable;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	
	public class WarningsDialogContent extends BaseDialogContent implements IDisposable, ICustomSizeable, IModalForm, ICustomPositionable, IAllowCommandsHistoryChange
	{
		private static const WIDTH:int = 900;
		
		private var _region:ExpandableRegion;
		private var _canvas:ScrollableCanvas;
		private var _boxRows:CanvasSprite;
		
		private var _data:Vector.<WarningData>;
		
		public static var instance:WarningsDialogContent;
		
		public static function init():void
		{
			if (instance != null)
			{
				throw new Error('WarningsDialogContent is already inited');
			}
			instance = new WarningsDialogContent();
		}
		
		public static function openDialog():void
		{
			if (instance.stage == null)
			{
				DialogFormParams.create()
					.setContent(instance)
					.show();
			}
			else
			{
				WindowsCanvas.instance.showForm(instance.parentForm);
			}
			instance.onOpen();
		}
		
		public function WarningsDialogContent()
		{
			super();
			
			_region = new ExpandableRegion(null, null, ExpandableRegionStyle.SEARCH_RESULTS);
			_region.y = 0;
			_region.setSize(WIDTH, 400);
			addChild(_region);
			
			_canvas = new ScrollableCanvas(false, true);
			_canvas.setSize(_region.width - 4, _region.height - 4);
			_canvas.x = _region.x + 2;
			_canvas.y = _region.y + 2;
			addChild(_canvas);
			
			_boxRows = new CanvasSprite();
			_canvas.setContent(_boxRows);
			
			cacheAsBitmap = true;
		}
		
		public function onOpen():void
		{
			Settings.addEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			Main.instance.addEventListener(TableEvent.CACHE_UPDATED, onCacheUpdated);
			
			_canvas.init();
			
			redraw();
		}
		
		public function dispose():void
		{
			Settings.removeEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			Main.instance.removeEventListener(TableEvent.CACHE_UPDATED, onCacheUpdated);
			
			_canvas.dispose();
		}
		
		private function redraw():void
		{
			_boxRows.removeAllChildren(true, ObjectsPool.release);
			
			for each (var level:WarningLevel in WarningLevel.ALL)
			{
				for each (var warning:WarningData in Main.instance.rootTable.cache.getWarnings(level))
				{
					var view:WarningEntryView = ObjectsPool.getItem(WarningEntryView) as WarningEntryView;
					view.setSize(_canvas.width / Settings.tableScale, 20);
					view.data = warning;
					_boxRows.addChild(view);
				}
			}
			
			_boxRows.scaleX = _boxRows.scaleY = Settings.tableScale;
			_boxRows.alignChildren(Align.H_LEFT, 0);
			_boxRows.fitToContent();
			
			_canvas.updateControls();
		}
		
		override public function get width():Number 
		{
			return WIDTH;
		}
		
		override public function get height():Number 
		{
			return _region.y + _region.height + 4;
		}
		
		private function onTableScaleChanged(e:Event):void
		{
			redraw();
		}
		
		private function onCacheUpdated(e:Event):void
		{
			redraw();
		}
		
		public function get modalBack():ModalBack
		{
			return null;
		}
		public function get isModal():Boolean
		{
			return false;
		}
		
		public function onPosOffsetChanged(x:int, y:int):void
		{
			Settings.warningsOffsetX = x;
			Settings.warningsOffsetY = y;
		}
		public function get posOffsetX():int
		{
			return Settings.warningsOffsetX;
		}
		public function get posOffsetY():int
		{
			return Settings.warningsOffsetY;
		}
	}
}