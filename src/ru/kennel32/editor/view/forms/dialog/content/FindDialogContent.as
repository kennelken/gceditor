package ru.kennel32.editor.view.forms.dialog.content
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.data.table.find.FindResult;
	import ru.kennel32.editor.data.table.find.FindResultEntry;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.controls.CheckBox;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.components.interfaces.IModalForm;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.components.tabs.TabEvent;
	import ru.kennel32.editor.view.components.tabs.TabInfo;
	import ru.kennel32.editor.view.components.tabs.TabsGroup;
	import ru.kennel32.editor.view.components.windows.ModalBack;
	import ru.kennel32.editor.view.components.windows.WindowsCanvas;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.factory.ObjectsPool;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.interfaces.IAllowCommandsHistoryChange;
	import ru.kennel32.editor.view.interfaces.ICustomPositionable;
	import ru.kennel32.editor.view.interfaces.ICustomSizeable;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class FindDialogContent extends BaseDialogContent implements IDisposable, ICustomSizeable, IModalForm, ICustomPositionable, IAllowCommandsHistoryChange
	{
		private static const WIDTH:int = 900;
		
		private var _tfFind:TextField;
		private var _btnFind:LabeledButton;
		private var _checkBoxWholeProject:CheckBox;
		private var _tfFindTime:TextField;
		private var _tfFindTable:TextField;
		
		private var _tabs:TabsGroup;
		
		private var _region:ExpandableRegion;
		private var _canvas:ScrollableCanvas;
		private var _boxRows:CanvasSprite;
		
		private var _findResult:FindResult;
		
		public static var instance:FindDialogContent;
		
		public static function init():void
		{
			if (instance != null)
			{
				throw new Error('FindDialogContent is already inited');
			}
			instance = new FindDialogContent();
		}
		
		public static function openDialog(wholeProject:Boolean, usageRow:TableRow = null):void
		{
			instance.wholeProject = wholeProject;
			instance.prefilledText = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String
			if (usageRow != null)
			{
				instance.findUsage = true;
				instance.wholeProject = true;
				instance.prefilledText = usageRow.parent.meta.counterId + ':' + usageRow.id;
				
				setTimeout(instance.doFind, 30);
			}
			
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
		
		public function FindDialogContent()
		{
			super();
			
			_btnFind = new LabeledButton(Texts.menuFind);
			_btnFind.setSize(120, 25);
			_btnFind.x = WIDTH - _btnFind.width;
			_btnFind.addEventListener(MouseEvent.CLICK, onBtnFind);
			addChild(_btnFind);
			
			_tfFind = TextUtils.getInputText(Color.FONT, 20, WIDTH - _btnFind.width - 5);
			addChild(_tfFind);
			
			_checkBoxWholeProject = new CheckBox(15);
			_checkBoxWholeProject.x = _tfFind.x;
			_checkBoxWholeProject.y = _tfFind.y + _tfFind.height + 4;
			_checkBoxWholeProject.text = Texts.wholeProject;
			addChild(_checkBoxWholeProject);
			
			_tfFindTime = TextUtils.getTextCentered('', Color.FONT, 12);
			_tfFindTime.width = _btnFind.width;
			_tfFindTime.x = _btnFind.x;
			_tfFindTime.y = _btnFind.y + _btnFind.height + 3;
			addChild(_tfFindTime);
			
			_tfFindTable = TextUtils.getTextCentered('', Color.FONT, 12);
			_tfFindTable.width = WIDTH;
			_tfFindTable.x = 0;
			_tfFindTable.y = _tfFindTime.y;
			_tfFindTable.mouseEnabled = false;
			addChild(_tfFindTable);
			
			_tabs = new TabsGroup(WIDTH, 30);
			_tabs.y = _checkBoxWholeProject.y + _checkBoxWholeProject.height + 20;
			_tabs.values = createTabsValues();
			_tabs.selectedValue = FindResult.TAB_META; 
			addChild(_tabs);
			
			_region = new ExpandableRegion(null, null, ExpandableRegionStyle.SEARCH_RESULTS);
			_region.y = _tabs.y + _tabs.height - 1;
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
		
		private function createTabsValues():Vector.<TabInfo>
		{
			var res:Vector.<TabInfo> = new Vector.<TabInfo>();
			
			for each (var tabIndex:int in FindResult.ALL_TABS)
			{
				var needCheckBox:Boolean = false;
				var checked:Boolean = false;
				
				switch (tabIndex)
				{
					case FindResult.TAB_META:
						break;
					
					case FindResult.TAB_ROWS:
						break;
						
					case FindResult.TAB_USAGE:
						needCheckBox = true;
						checked = Settings.needFindCheckboxUsage;
						break;
						
					case FindResult.TAB_LOCALIZATIONS:
						needCheckBox = true;
						checked = Settings.needFindCheckboxLocalizations;
						break;
				}
				res.push(new TabInfo(getTabName(tabIndex), tabIndex, needCheckBox, checked, false));
			}
			
			return res;
		}
		
		public function set wholeProject(value:Boolean):void
		{
			_checkBoxWholeProject.checked = value;
		}
		
		public function set prefilledText(value:String):void
		{
			_tfFind.text = value == null ? '' : value;
		}
		
		public function doFind():void
		{
			var table:BaseTable = _checkBoxWholeProject.checked || Main.instance.selectedTable == null ? Main.instance.rootTable : Main.instance.selectedTable;
			_tfFindTable.text = 'Results in table ' + table.meta.id + '.' + table.meta.name;
			_tfFindTable.width = _tfFindTable.textWidth + 5;
			_tfFindTable.x = int((WIDTH - _tfFindTable.width) / 2);
			Main.instance.mainUI.playAttentionEffect(_tfFindTable);
			
			var startTs:int = getTimer();
			
			_findResult = FindResult.newFind(
				_tfFind.text.toLowerCase(),
				_tabs.getTabByValue(FindResult.TAB_USAGE).checked,
				_tabs.getTabByValue(FindResult.TAB_LOCALIZATIONS).checked,
				table
			);
			
			_tfFindTime.text = Texts.foundIn(getTimer() - startTs);
			Main.instance.mainUI.playAttentionEffect(_tfFindTime);
			
			for each (var tab:int in FindResult.ALL_TABS)
			{
				var numItems:int = _findResult.result[tab].length;
				_tabs.getTabByValue(tab).name = getTabName(tab) + (numItems > 0 ? '(' + numItems + ')' : '');
			}
			
			if (_findResult.result[_tabs.selectedValue].length <= 0)
			{
				for each (tab in FindResult.ALL_TABS)
				{
					if (_findResult.result[tab].length > 0)
					{
						_tabs.selectedValue = tab;
						break;
					}
				}
			}
			
			_tabs.update();
			
			updateCurrentTab();
		}
		
		private function updateCurrentTab():void
		{
			_boxRows.removeAllChildren(true, ObjectsPool.release);
			
			if (_findResult != null)
			{
				for each (var entry:FindResultEntry in _findResult.result[_tabs.selectedTab.value])
				{
					var view:FindResultEntryView = ObjectsPool.getItem(FindResultEntryView) as FindResultEntryView;
					view.setSize(_canvas.width / Settings.tableScale, 20);
					view.data = entry;
					_boxRows.addChild(view);
				}
			}
			
			_boxRows.scaleX = _boxRows.scaleY = Settings.tableScale;
			_boxRows.alignChildren(Align.H_LEFT, 0);
			_boxRows.fitToContent();
			
			_canvas.updateControls();
		}
		
		public function set findUsage(value:Boolean):void
		{
			_tabs.getTabByValue(FindResult.TAB_USAGE).checked = true;
			_tabs.getTabByValue(FindResult.TAB_USAGE).selected = value;
			_tabs.selectedValue = FindResult.TAB_USAGE;
		}
		
		public function onOpen():void
		{
			Main.stage.focus = _tfFind;
			_tfFind.setSelection(0, _tfFind.text.length);
			
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Settings.addEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			_tabs.addEventListener(TabEvent.TAB_CLICK, onTabClick);
			
			_canvas.init();
			
			updateCurrentTab();
		}
		
		public function dispose():void
		{
			Settings.needFindCheckboxUsage = _tabs.getTabByValue(FindResult.TAB_USAGE).checked;
			Settings.needFindCheckboxLocalizations = _tabs.getTabByValue(FindResult.TAB_LOCALIZATIONS).checked;
			
			Main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Settings.removeEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			_tabs.removeEventListener(TabEvent.TAB_CLICK, onTabClick);
			
			_canvas.dispose();
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.charCode == Keyboard.ENTER)
			{
				onBtnFind();
			}
		}
		
		override public function get width():Number 
		{
			return WIDTH;
		}
		
		override public function get height():Number 
		{
			return _region.y + _region.height + 4;
		}
		
		private function onBtnFind(e:Event = null):void
		{
			doFind();
		}
		
		private function getTabName(tabIndex:int):String
		{
			switch (tabIndex)
			{
				case FindResult.TAB_META:
					return Texts.tabMeta;
				
				case FindResult.TAB_ROWS:
					return Texts.tabRows;
					
				case FindResult.TAB_USAGE:
					return Texts.tabUsage;
					
				case FindResult.TAB_LOCALIZATIONS:
					return Texts.tabLocalizations;
			}
			
			return null;
		}
		
		private function onTableScaleChanged(e:Event):void
		{
			updateCurrentTab();
		}
		
		private function onTabClick(e:TabEvent):void
		{
			_tabs.selectedTab = e.tab;
			updateCurrentTab();
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
			Settings.findOffsetX = x;
			Settings.findOffsetY = y;
		}
		public function get posOffsetX():int
		{
			return Settings.findOffsetX;
		}
		public function get posOffsetY():int
		{
			return Settings.findOffsetY;
		}
	}
}