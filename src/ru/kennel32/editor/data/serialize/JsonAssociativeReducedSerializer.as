package ru.kennel32.editor.data.serialize
{
	import ru.kennel32.editor.data.table.TableMeta;
	import ru.kennel32.editor.data.utils.Hardcode;
	
	public class JsonAssociativeReducedSerializer extends JsonAssociativeSerializer
	{
		public function JsonAssociativeReducedSerializer()
		{
		}
		
		override public function get type():int
		{
			return SerializerType.JSON_ASSOCIATIVE_REDUCED;
		}
		
		override public function serializeMeta(src:TableMeta):Object 
		{
			if (!Hardcode.isRootMeta(src))
			{
				return null;
			}
			
			return {'serializer': type};
		}
		
		override public function deserializeTable(src:SerializerParams, onlyBasic:Boolean = false):SerializerParams 
		{
			if (!onlyBasic)
			{
				return src;
			}
			
			return super.deserializeTable(src, onlyBasic);
		}
	}
}