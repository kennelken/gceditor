package ru.kennel32.editor.view.components.style 
{
	import ru.kennel32.editor.view.enum.Color;
	
	public class ExpandableRegionStyle 
	{
		public static const MAJOR:ExpandableRegionStyle =				new ExpandableRegionStyle(Color.SEPARATOR_MAJOR, 2, 0, 0);
		public static const OUT_OF_TABLE:ExpandableRegionStyle =		new ExpandableRegionStyle(Color.SEPARATOR_MAJOR, 2, Color.OUT_OF_TABLE, 1);
		public static const MINOR:ExpandableRegionStyle =				new ExpandableRegionStyle(Color.SEPARATOR_MINOR, 1, 0, 0);
		public static const COLUMN_HEAD:ExpandableRegionStyle =			new ExpandableRegionStyle(Color.SEPARATOR_MAJOR, 2, Color.COLUMN_HEAD, 1);
		public static const COLUMN_HEAD_STATIC:ExpandableRegionStyle =	new ExpandableRegionStyle(Color.SEPARATOR_MAJOR, 2, Color.COLUMN_HEAD_STATIC, 1);
		public static const COLUMN_HEAD_LOCKED:ExpandableRegionStyle =	new ExpandableRegionStyle(Color.SEPARATOR_MAJOR, 2, Color.COLUMN_HEAD_LOCKED, 1);
		public static const CELL_REGULAR:ExpandableRegionStyle =		new ExpandableRegionStyle(Color.SEPARATOR_MINOR, 1, Color.CELL_REGULAR, 1);
		public static const SELECT_ITEM_LIST:ExpandableRegionStyle =	new ExpandableRegionStyle(Color.SEPARATOR_MINOR, 1, Color.WHITE, 1);
		public static const FIND_ENTRY:ExpandableRegionStyle =			new ExpandableRegionStyle(Color.SEPARATOR_MINOR, 1, Color.COLUMN_HEAD, 1);
		
		public static const TAB_UNSELECTED:ExpandableRegionStyle =		new ExpandableRegionStyle(Color.SEPARATOR_MINOR, 1, Color.FORM_BODY, 0);
		public static const TAB_SELECTED:ExpandableRegionStyle =		new ExpandableRegionStyle(Color.SEPARATOR_MAJOR, 2, Color.WHITE, 0.3);
		
		public static const SEARCH_RESULTS:ExpandableRegionStyle =		new ExpandableRegionStyle(Color.BORDER_LIGHT, 1, Color.WHITE, 1);
		
		public var borderColor:uint;
		public var borderThickness:uint;
		public var fillColor:uint;
		public var fillAlpha:Number;
		
		public function ExpandableRegionStyle(borderColor:uint = 0, borderThickness:uint = 1, fillColor:uint = 0, fillAlpha:Number = 1) 
		{
			this.borderColor = borderColor;
			this.borderThickness = borderThickness;
			this.fillColor = fillColor;
			this.fillAlpha = fillAlpha;
		}
	}
}