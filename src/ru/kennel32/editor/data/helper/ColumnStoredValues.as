package ru.kennel32.editor.data.helper
{
	import ru.kennel32.editor.data.utils.ObjectUtils;
	
	public class ColumnStoredValues
	{
		private var _valuesByTableId:Object;
		
		public function ColumnStoredValues()
		{
			_valuesByTableId = new Object();
		}
		
		public function getValuesForTable(id:uint, index:int, createEmptyIfRequired:Boolean = true):Vector.<Object>
		{
			if (createEmptyIfRequired)
			{
				if (_valuesByTableId[id] === undefined)
				{
					_valuesByTableId[id] = new Object();
				}
				if (_valuesByTableId[id][index] === undefined)
				{
					_valuesByTableId[id][index] = new Vector.<Object>();
				}
			}
			
			return _valuesByTableId[id] == null ? null : _valuesByTableId[id][index];
		}
		
		public function clone():ColumnStoredValues
		{
			var res:ColumnStoredValues = new ColumnStoredValues();
			for (var id:Object in _valuesByTableId)
			{
				res._valuesByTableId[id] = new Object();
				for (var index:Object in _valuesByTableId[id])
				{
					res._valuesByTableId[id][index] = new Vector.<Object>();
					
					for (var i:int = 0; i < _valuesByTableId[id][index].length; i++)
					{
						res._valuesByTableId[id][index].push(ObjectUtils.clone(_valuesByTableId[id][index][i]));
					}
				}
			}
			return res;
		}
		
		public function doForEveryValue(func:Function, params:Array = null):ColumnStoredValues
		{
			var funcParams:Array = [null];
			if (params != null)
			{
				funcParams = funcParams.concat(params);
			}
			for (var id:Object in _valuesByTableId)
			{
				var values:Object = _valuesByTableId[id];
				for (var index:Object in values)
				{
					for (var i:int = 0; i < values[index].length; i++)
					{
						funcParams[0] = values[index][i];
						values[index][i] = func.apply(null, funcParams);
					}
				}
			}
			
			return this;
		}
	}
}