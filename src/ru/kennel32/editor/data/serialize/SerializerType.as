package ru.kennel32.editor.data.serialize
{
	public class SerializerType
	{
		public static const JSON_INDEXED_BEAUTIFIED:int		= 0;
		public static const JSON_INDEXED:int				= 1;
		public static const JSON_ASSOCIATIVE:int			= 2;
		public static const JSON_ASSOCIATIVE_REDUCED:int	= 3;
		
		public static const ALL:Vector.<int>					= Vector.<int>([JSON_INDEXED_BEAUTIFIED, JSON_INDEXED, JSON_ASSOCIATIVE, JSON_ASSOCIATIVE_REDUCED]);
		public static const ALL_DESERIALIZABLE:Vector.<int>		= Vector.<int>([JSON_INDEXED_BEAUTIFIED, JSON_INDEXED]);
	}
}