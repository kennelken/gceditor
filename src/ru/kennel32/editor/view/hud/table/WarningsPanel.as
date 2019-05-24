package ru.kennel32.editor.view.hud.table 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.helper.warning.WarningLevel;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.content.WarningsDialogContent;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class WarningsPanel extends CanvasSprite implements IDisposable
	{
		private var _region:ExpandableRegion;
		private var _tfNumErrors:TextField;
		
		public function WarningsPanel()
		{
			super();
			
			_region = new ExpandableRegion(RectSides.SIDES_0110, null, ExpandableRegionStyle.COLUMN_HEAD);
			_region.setSize(-1, 27);
			addChild(_region);
			
			_tfNumErrors = TextUtils.getText('', 0, 16);
			_tfNumErrors.x = 2;
			_tfNumErrors.y = 2;
			addChild(_tfNumErrors);
			
			setSize( -1, _region.height);
		}
		
		public function init():void
		{
			Main.instance.addEventListener(TableEvent.CACHE_UPDATED, onTableUpdated);
			update();
		}
		
		public function dispose():void
		{
			Main.instance.removeEventListener(TableEvent.CACHE_UPDATED, onTableUpdated);
			cleanup();
		}
		
		private function cleanup():void
		{
			
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_region.setSize(_width, -1);
		}
		
		private function update():void
		{
			_tfNumErrors.text = '';
			
			if (Main.instance.rootTable == null)
			{
				return;
			}
			
			var errorsCount:int = Main.instance.rootTable.cache.getWarningsCount(WarningLevel.ERROR);
			var warningsCount:int = Main.instance.rootTable.cache.getWarningsCount(WarningLevel.WARNING);
			var messagesCount:int = Main.instance.rootTable.cache.getWarningsCount(WarningLevel.MESSAGE);
			var totalCount:int = errorsCount + warningsCount + messagesCount;
			
			TextUtils.addColoredText(_tfNumErrors, "E:" + errorsCount + " ", errorsCount > 0 ? Color.FONT_IMPORTANT : Color.FONT_UNIMPORTANT);
			TextUtils.addColoredText(_tfNumErrors, "W:" + warningsCount + " ", warningsCount > 0 ? Color.FONT_WARNING : Color.FONT_UNIMPORTANT);
			TextUtils.addColoredText(_tfNumErrors, "M:" + messagesCount + " ", messagesCount > 0 ? Color.FONT : Color.FONT_UNIMPORTANT);
			
			_tfNumErrors.mouseEnabled = false;
			mouseEnabled = mouseChildren = totalCount > 0;
			buttonMode = totalCount > 0;
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private function onTableUpdated(e:Event):void
		{
			update();
		}
		
		private function onMouseClick(e:Event):void
		{
			WarningsDialogContent.openDialog();
		}
	}
}