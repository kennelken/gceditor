package ru.kennel32.editor.view.hud.table 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.hud.table.TablesTreeItem;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class TablesTreeView extends CanvasSprite implements IDisposable
	{
		public static const MIN_WIDTH:int = 130;
		public static const MAX_WIDTH:int = 450;
		
		private var _region:ExpandableRegion;
		private var _nameSeparator:ExpandableRegion;
		private var _tfFileName:TextField;
		
		private var _scrollableCanvas:ScrollableCanvas;
		private var _boxContent:Sprite;
		private var _rootItem:TablesTreeItem;
		
		public function TablesTreeView()
		{
			super();
			
			_region = new ExpandableRegion(RectSides.SIDES_0100, RectSides.SIDES_0100, ExpandableRegionStyle.OUT_OF_TABLE);
			_region.minWidth = MIN_WIDTH;
			_region.maxWidth = MAX_WIDTH;
			_region.addEventListener(Event.RESIZE, onResize);
			addChild(_region);
			
			_nameSeparator = new ExpandableRegion(RectSides.SIDES_0001, null, ExpandableRegionStyle.MAJOR);
			_nameSeparator.setSize(100, 30);
			addChild(_nameSeparator);
			
			_tfFileName = TextUtils.getText('', Color.FONT, 18);
			_tfFileName.x = 3;
			_tfFileName.y = 4;
			addChild(_tfFileName);
			
			scrollRect = new Rectangle(0, 0, 0, 0);
			
			_scrollableCanvas = new ScrollableCanvas();
			_scrollableCanvas.x = 2;
			_scrollableCanvas.y = _nameSeparator.height + 1;
			addChild(_scrollableCanvas);
			
			_rootItem = new TablesTreeItem();
			_rootItem.addEventListener(Event.RESIZE, onListResized, false, -int.MAX_VALUE);
			_rootItem.x = 2;
			_rootItem.y = 3;
			
			_boxContent = new Sprite();
			_boxContent.addChild(_rootItem);
			
			_scrollableCanvas.setContent(_boxContent);
			
			mouseEnabled = false;
		}
		
		public function init():void
		{
			Main.instance.addEventListener(TableEvent.FILE_CHANGED, onFileChanged);
			Main.instance.addEventListener(TableEvent.TREE_CHANGED, onTreeChanged);
			Main.instance.commandsHistory.addEventListener(Event.CHANGE, onCommandsHistoryChange);
			
			Settings.addEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			onTableScaleChanged();
			
			_scrollableCanvas.init();
			_region.init();
			update();
		}
		
		public function dispose():void
		{
			Main.instance.removeEventListener(TableEvent.FILE_CHANGED, onFileChanged);
			Main.instance.removeEventListener(TableEvent.TREE_CHANGED, onTreeChanged);
			Main.instance.commandsHistory.removeEventListener(Event.CHANGE, onCommandsHistoryChange);
			Settings.removeEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			_scrollableCanvas.dispose();
			_region.dispose();
			cleanup();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void
		{
			super.setSize(width, height);
			
			_region.setSize(width, height);
			_nameSeparator.setSize(_region.width, -1);
			_scrollableCanvas.setSize(_region.width - 3 - _scrollableCanvas.x, _region.height - _nameSeparator.height - 3);
		}
		
		private function onFileChanged(e:Event):void
		{
			Main.instance.mainUI.playAttentionEffect(_tfFileName);
			update();
		}
		
		private function onTreeChanged(e:Event):void
		{
			update();
		}
		
		public function update(...args):void
		{
			cleanup();
			
			updateFileName();
			
			_rootItem.init(Main.instance.rootTable);
			_scrollableCanvas.updateControls(false);
		}
		
		private function onResize(e:Event):void
		{
			if (e.target == _region)
			{
				setSize(_region.width, -1);
			}
		}
		
		private function cleanup():void
		{
			_tfFileName.text = '';
			_rootItem.dispose();
		}
		
		private function onListResized(e:Event):void
		{
			setSize(-1, -1);
		}
		
		private function onCommandsHistoryChange(e:Event):void
		{
			updateFileName();
		}
		
		private function updateFileName():void
		{
			var file:File = Main.instance.file;
			if (file != null)
			{
				var text:String = file.name;
			}
			else
			{
				text = Texts.textNewProject;
			}
			
			if (Main.instance.hasUnsavedChanges)
			{
				text += '*';
			}
			
			_tfFileName.text = text;
		}
		
		private function onTableScaleChanged(e:Event = null):void
		{
			_boxContent.scaleX = _boxContent.scaleY = Settings.tableScale;
			_scrollableCanvas.updateControls(false);
		}
	}
}