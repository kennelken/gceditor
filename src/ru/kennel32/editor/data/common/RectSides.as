package ru.kennel32.editor.data.common 
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public class RectSides extends Proxy
	{
		public static const SIDES_0000:RectSides = new RectSides(false, false, false, false);
		public static const SIDES_0001:RectSides = new RectSides(false, false, false, true);
		public static const SIDES_0100:RectSides = new RectSides(false, true, false, false);
		public static const SIDES_0101:RectSides = new RectSides(false, true, false, true);
		public static const SIDES_0110:RectSides = new RectSides(false, true, true, false);
		public static const SIDES_0111:RectSides = new RectSides(false, true, true, true);
		public static const SIDES_1000:RectSides = new RectSides(true, false, false, false);
		public static const SIDES_1111:RectSides = new RectSides(true, true, true, true);
		
		public static const LEFT:int =		0;
		public static const RIGHT:int =		1;
		public static const TOP:int =		2;
		public static const BOTTOM:int = 	3;
		
		public static const MAX_INDEX:int = 3;
		
		public static const ALL:Vector.<int> = Vector.<int>([LEFT, RIGHT, TOP, BOTTOM]);
		
		public function get left():Boolean
		{
			return _sides[LEFT];
		}
		public function set left(value:Boolean):void
		{
			_sides[LEFT] = value;
		}
		
		public function get right():Boolean
		{
			return _sides[RIGHT];
		}
		public function set right(value:Boolean):void
		{
			_sides[RIGHT] = value;
		}
		
		public function get top():Boolean
		{
			return _sides[TOP];
		}
		public function set top(value:Boolean):void
		{
			_sides[TOP] = value;
		}
		
		public function get bottom():Boolean
		{
			return _sides[BOTTOM];
		}
		public function set bottom(value:Boolean):void
		{
			_sides[BOTTOM] = value;
		}
		
		private var _sides:Vector.<Boolean>;
		public function get sides():Vector.<Boolean>
		{
			return _sides;
		}
		public function set sides(value:Vector.<Boolean>):void
		{
			_sides = value;
		}
		
		public function RectSides(left:Boolean = true, right:Boolean = true, top:Boolean = true, bottom:Boolean = true):void
		{
			_sides = new Vector.<Boolean>(MAX_INDEX+1);
			
			_sides[LEFT] = left;
			_sides[RIGHT] = right;
			_sides[TOP] = top;
			_sides[BOTTOM] = bottom;
		}
		
		public function get isEmpty():Boolean
		{
			return !_sides[LEFT] && !_sides[RIGHT] && !_sides[TOP] && !_sides[BOTTOM];
		}
		
		////////////////////////////////
		
		override flash_proxy function getProperty(name:*):*
		{
			if (name is QName)
				name = name.localName;
			
			return _sides[int(name)];
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (name is QName)
				name = name.localName;
			
			_sides[int(name)] = Boolean(value);
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			if (name is QName)
				name = name.localName;
			
			if (!(name is int))
				return false;
			
			return name < _sides.length && name > -1;
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			return 0;
		}
		override flash_proxy function nextName(index:int):String
		{
			return null;
		}
		override flash_proxy function nextValue(index:int):*
		{
			return null;
		}
		override flash_proxy function callProperty(name:*, ... rest):*
		{
			return null;
		}
	}
}