package ru.kennel32.editor.view.components.tooltip 
{
	import flash.display.Sprite;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.utils.ParseUtils;
	import ru.kennel32.editor.view.components.SimpleBackground;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.utils.FormsUtils;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class ColumnHeadTooltipView extends Sprite implements ICustomTooltipView
	{
		private static const CONTENT_OFFSET:int = 2;
		private static const MAX_VALUE_WIDTH:int = 500;
		
		private var _bg:SimpleBackground;
		
		private var _boxContent:Sprite;
		
		private var _rowTag:HintRow;
		private var _rowType:HintRow;
		private var _rowDefaultValue:HintRow;
		private var _rowDescription:HintRow;
		private var _rowMeta:HintRow;
		private var _rowCounter:HintRow;
		
		public function ColumnHeadTooltipView()
		{
			_bg = new SimpleBackground();
			addChild(_bg);
			
			_boxContent = new Sprite();
			_boxContent.x = CONTENT_OFFSET;
			_boxContent.y = CONTENT_OFFSET;
			addChild(_boxContent);
			
			_rowTag = new HintRow(Texts.textTag, '', Color.FONT_IMPORTANT);
			_boxContent.addChild(_rowTag);
			
			_rowType = new HintRow(Texts.textType);
			_boxContent.addChild(_rowType);
			
			_rowDefaultValue = new HintRow(Texts.textDefaultValue);
			_boxContent.addChild(_rowDefaultValue);
			
			_rowMeta = new HintRow(Texts.textMeta, '', Color.FONT_IMPORTANT);
			_rowCounter = new HintRow(Texts.textCounter, '', Color.FONT_IMPORTANT);
			
			_rowDescription = new HintRow(Texts.textDescription);
			_boxContent.addChild(_rowDescription);
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
		
		private function get columnDescription():TableColumnDescription
		{
			return _tooltipData as TableColumnDescription;
		}
		
		public function update():void
		{
			ViewUtils.setParent(_rowMeta, _boxContent, columnDescription.type == TableColumnDescriptionType.INNER_TABLE);
			if (_rowMeta.parent != null)
			{
				_rowMeta.tfValue.text = ViewUtils.getTableName(columnDescription.metaId);
			}
			
			ViewUtils.setParent(_rowCounter, _boxContent, columnDescription.type == TableColumnDescriptionType.SELECT_SINGLE_ID);
			if (_rowCounter.parent != null)
			{
				_rowCounter.tfValue.text = ViewUtils.getCounterName(columnDescription.idFrom);
			}
			
			_rowTag.tfValue.text = columnDescription.tag == null ? "" : columnDescription.tag;
			_rowType.tfValue.text = FormsUtils.getTableColumnDescriptionTypesNames(Vector.<uint>([columnDescription.type]))[0];
			_rowDefaultValue.tfValue.text = ViewUtils.parseColumnDefaultValue(columnDescription);
			_rowDescription.tfValue.text = columnDescription.description === null ? '' : columnDescription.description;
			
			var yPos:int = 0;
			for (var i:int = 0; i < _boxContent.numChildren; i++)
			{
				var row:HintRow = _boxContent.getChildAt(i) as HintRow;
				
				row.y = yPos;
				
				row.tfValue.width = MAX_VALUE_WIDTH;
				row.tfValue.width = row.tfValue.textWidth + 6;
				row.tfValue.height = row.tfValue.textHeight + 8;
				
				var valuesX:int = Math.max(valuesX, row.tfLabel.width);
				yPos += row.height;
			}
			valuesX += 30;
			for (i = 0; i < _boxContent.numChildren; i++)
			{
				row = _boxContent.getChildAt(i) as HintRow;
				
				row.tfValue.x = valuesX;
			}
			
			_bg.setSize(_boxContent.width + CONTENT_OFFSET * 2, _boxContent.height + CONTENT_OFFSET * 2);
		}
	}
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import ru.kennel32.editor.view.enum.Color;
import ru.kennel32.editor.view.utils.TextUtils;

internal class HintRow extends Sprite
{
	public var tfLabel:TextField;
	public var tfValue:TextField;
	
	public function HintRow(label:String, value:String = '', color:uint = Color.FONT)
	{
		tfLabel = TextUtils.getText(label, Color.FONT, 14, null, false, -1);
		tfLabel.autoSize = TextFieldAutoSize.NONE;
		tfLabel.width = tfLabel.textWidth + 6;
		tfLabel.height = tfLabel.textHeight + 8;
		addChild(tfLabel);
		
		tfValue = TextUtils.getText(value, color, 14, null, true, -1);
		tfValue.autoSize = TextFieldAutoSize.NONE;
		tfValue.x = 200;
		tfValue.y = tfLabel.y;
		addChild(tfValue);
	}
}