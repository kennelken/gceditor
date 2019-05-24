package ru.kennel32.editor.data.serialize
{
	public class JsonIndexedSerializer extends JsonIndexedBeautifiedSerializer
	{
		public function JsonIndexedSerializer()
		{
		}
		
		override public function get type():int
		{
			return SerializerType.JSON_INDEXED;
		}
		
		override protected function get jsonSpace():String
		{
			return null;
		}
	}
}