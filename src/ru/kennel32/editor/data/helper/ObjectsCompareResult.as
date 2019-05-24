package ru.kennel32.editor.data.helper
{
	import ru.kennel32.editor.data.utils.ObjectUtils;
	
	public class ObjectsCompareResult
	{
		private var _numAddedProps:int;
		public function get numAddedProps():int { return _numAddedProps; }
		
		private var _numDeletedProps:int;
		public function get numDeletedProps():int { return _numDeletedProps; }
		
		private var _numChangedProps:int;
		public function get numChangedProps():int { return _numChangedProps; }
		
		private var _hasChanges:Boolean;
		public function get hasChanges():Boolean
		{
			return _hasChanges;
		}
		
		public function ObjectsCompareResult()
		{
		}
		
		public static function compare(objA:Object, objB:Object):ObjectsCompareResult
		{
			var res:ObjectsCompareResult = new ObjectsCompareResult();
			
			doCompare(objA, objB, res)
			
			return res;
		}
		
		private static function doCompare(objA:Object, objB:Object, result:ObjectsCompareResult):Boolean
		{
			var res:Boolean = true;
			
			for (var prop:Object in objA)
			{
				if (objB[prop] === undefined)
				{
					result._numDeletedProps++;
					res = false;
				}
			}
			for (prop in objB)
			{
				if (objA[prop] === undefined)
				{
					result._numAddedProps++;
					res = false;
					continue;
				}
				
				var isPrimitiveA:Boolean = ObjectUtils.isPrimitive(objA[prop]);
				var isPrimitiveB:Boolean = ObjectUtils.isPrimitive(objB[prop]);
				
				if (isPrimitiveA != isPrimitiveB)
				{
					result._numChangedProps++;
					res = false;
					continue;
				}
				else
				{
					if (isPrimitiveA)
					{
						if (objA[prop] !== objB[prop])
						{
							result._numChangedProps++;
							res = false;
							continue;
						}
					}
					else
					{
						if (!doCompare(objA[prop], objB[prop], result))
						{
							//result._numChangedProps++;
							res = false;
							continue;
						}
					}
				}
			}
			
			result._hasChanges ||= !res;
			return res;
		}
	}
}