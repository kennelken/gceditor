package ru.kennel32.editor.view.components.tooltip 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.TableType;
	import ru.kennel32.editor.view.components.SimpleBackground;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class TableTooltipView extends Sprite implements ICustomTooltipView
	{
		private static const CONTENT_OFFSET:int = 2;
		private static const MAX_VALUE_WIDTH:int = 500;
		
		private var _bg:SimpleBackground;
		
		private var _boxContent:Sprite;
		private var _tfTag:TextField;
		private var _tfForInnerTable:TextField;
		private var _tfContainer:TextField;
		private var _tfCounter:TextField;
		private var _tfDescription:TextField;
		
		public function TableTooltipView()
		{
			_bg = new SimpleBackground();
			addChild(_bg);
			
			_boxContent = new Sprite();
			_boxContent.x = CONTENT_OFFSET;
			_boxContent.y = CONTENT_OFFSET;
			addChild(_boxContent);
			
			var tfTagLabel:TextField = TextUtils.getText(Texts.textTag, Color.FONT, 14);
			tfTagLabel.autoSize = TextFieldAutoSize.NONE;
			tfTagLabel.width = tfTagLabel.textWidth + 6;
			tfTagLabel.height = tfTagLabel.textHeight + 8;
			_boxContent.addChild(tfTagLabel);
			
			var tfForInnerTableLabel:TextField = TextUtils.getText(Texts.textForInnerTable, Color.FONT, 14);
			tfForInnerTableLabel.autoSize = TextFieldAutoSize.NONE;
			tfForInnerTableLabel.y = tfTagLabel.y + tfTagLabel.height - 2;
			tfForInnerTableLabel.width = tfForInnerTableLabel.textWidth + 6;
			tfForInnerTableLabel.height = tfForInnerTableLabel.textHeight + 8;
			_boxContent.addChild(tfForInnerTableLabel);	
			
			var tfContainerLabel:TextField = TextUtils.getText(Texts.textContainer, Color.FONT, 14);
			tfContainerLabel.autoSize = TextFieldAutoSize.NONE;
			tfContainerLabel.y = tfForInnerTableLabel.y + tfForInnerTableLabel.height - 2;
			tfContainerLabel.width = tfContainerLabel.textWidth + 6;
			tfContainerLabel.height = tfContainerLabel.textHeight + 8;
			_boxContent.addChild(tfContainerLabel);
			
			var tfCounterLabel:TextField = TextUtils.getText(Texts.textCounter, Color.FONT, 14);
			tfCounterLabel.autoSize = TextFieldAutoSize.NONE;
			tfCounterLabel.y = tfContainerLabel.y + tfContainerLabel.height - 2;
			tfCounterLabel.width = tfCounterLabel.textWidth + 6;
			tfCounterLabel.height = tfCounterLabel.textHeight + 8;
			_boxContent.addChild(tfCounterLabel);
			
			var tfDescriptionLabel:TextField = TextUtils.getText(Texts.textDescription, Color.FONT, 14);
			tfDescriptionLabel.autoSize = TextFieldAutoSize.NONE;
			tfDescriptionLabel.y = tfCounterLabel.y + tfCounterLabel.height - 2;
			tfDescriptionLabel.width = tfDescriptionLabel.textWidth + 6;
			tfDescriptionLabel.height = tfDescriptionLabel.textHeight + 8;
			_boxContent.addChild(tfDescriptionLabel);
			
			var valuesX:int = CONTENT_OFFSET + Math.max(tfTagLabel.width, tfForInnerTableLabel.width, tfDescriptionLabel.width) + 30;
			
			_tfTag = TextUtils.getText('', Color.FONT_IMPORTANT, 14);
			_tfTag.autoSize = TextFieldAutoSize.NONE;
			_tfTag.x = valuesX;
			_tfTag.y = tfTagLabel.y;
			_boxContent.addChild(_tfTag);
			
			_tfForInnerTable = TextUtils.getText('', Color.FONT, 14);
			_tfForInnerTable.autoSize = TextFieldAutoSize.NONE;
			_tfForInnerTable.x = valuesX;
			_tfForInnerTable.y = tfForInnerTableLabel.y;
			_boxContent.addChild(_tfForInnerTable);
			
			_tfContainer = TextUtils.getText('', Color.FONT, 14);
			_tfContainer.autoSize = TextFieldAutoSize.NONE;
			_tfContainer.x = valuesX;
			_tfContainer.y = tfContainerLabel.y;
			_boxContent.addChild(_tfContainer);
			
			_tfCounter = TextUtils.getText('', Color.FONT, 14);
			_tfCounter.autoSize = TextFieldAutoSize.NONE;
			_tfCounter.x = valuesX;
			_tfCounter.y = tfCounterLabel.y;
			_boxContent.addChild(_tfCounter);
			
			_tfDescription = TextUtils.getText('', Color.FONT, 14, null, true, -3);
			_tfDescription.autoSize = TextFieldAutoSize.NONE;
			_tfDescription.x = valuesX;
			_tfDescription.y = tfDescriptionLabel.y;
			_boxContent.addChild(_tfDescription);
		}
		
		private var _tooltipData:*;
		public function get tooltipData():*
		{
			return _tooltipData;
		}
		public function set tooltipData(value:*):void
		{
			_tooltipData = value;
		}
		
		private function get tableData():BaseTable
		{
			return _tooltipData as BaseTable;
		}
		
		public function update():void
		{
			_tfTag.width = MAX_VALUE_WIDTH;
			_tfTag.text = tableData.meta.tag;
			_tfTag.width = _tfTag.textWidth + 6;
			_tfTag.height = _tfTag.textHeight + 8;
			
			_tfForInnerTable.width = MAX_VALUE_WIDTH;
			_tfForInnerTable.text = tableData.meta.forInnerTable ? '+' : '-';
			_tfForInnerTable.width = _tfForInnerTable.textWidth + 6;
			_tfForInnerTable.height = _tfForInnerTable.textHeight + 8;
			
			_tfContainer.width = MAX_VALUE_WIDTH;
			_tfContainer.text = tableData.meta.type == TableType.CONTAINER ? '+' : '-';
			_tfContainer.width = _tfContainer.textWidth + 6;
			_tfContainer.height = _tfContainer.textHeight + 8;
			
			_tfCounter.width = MAX_VALUE_WIDTH;
			_tfCounter.text = tableData.meta.counterId > 0 ? (tableData.meta.counterId + '.' + Main.instance.rootTable.cache.getCounterById(tableData.meta.counterId).name) : '-';
			_tfCounter.width = _tfCounter.textWidth + 6;
			_tfCounter.height = _tfCounter.textHeight + 8;
			
			_tfDescription.width = MAX_VALUE_WIDTH;
			_tfDescription.text = tableData.meta.description;
			_tfDescription.width = _tfDescription.textWidth + 6;
			_tfDescription.height = _tfDescription.textHeight + 8;
			
			_bg.setSize(_boxContent.width + CONTENT_OFFSET * 2, _boxContent.height + CONTENT_OFFSET * 2);
		}
	}
}