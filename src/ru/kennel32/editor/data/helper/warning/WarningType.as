package ru.kennel32.editor.data.helper.warning
{
	public class WarningType
	{
		public static const CHECKING_EXCEPTION:WarningType		= new WarningType("check exception", WarningLevel.ERROR);
		public static const MISSING_REFERENCE:WarningType		= new WarningType("missing reference", WarningLevel.ERROR);
		public static const MISSING_TAG:WarningType				= new WarningType("missing tag", WarningLevel.WARNING);
		public static const DUPLICATING_TAG:WarningType			= new WarningType("duplicating tag", WarningLevel.WARNING);
		public static const EMPTY_REFERENCE:WarningType			= new WarningType("empty reference", WarningLevel.WARNING);
		public static const MULTIPLE_USE_AS_NAME:WarningType	= new WarningType("multiple use as name", WarningLevel.WARNING);
		public static const MUST_BE_NON_EMPTY:WarningType		= new WarningType("must be non empty", WarningLevel.WARNING);
		public static const MISSING_LOCALIZATION:WarningType	= new WarningType("missing localization", WarningLevel.MESSAGE);
		public static const MISSING_USE_AS_NAME:WarningType		= new WarningType("missing use as name", WarningLevel.MESSAGE);
		
		public static const ALL:Vector.<WarningType> = Vector.<WarningType>([
			CHECKING_EXCEPTION,
			MISSING_REFERENCE,
			MISSING_TAG,
			DUPLICATING_TAG,
			EMPTY_REFERENCE,
			MULTIPLE_USE_AS_NAME,
			MUST_BE_NON_EMPTY,
			MISSING_LOCALIZATION,
			MISSING_USE_AS_NAME
		]);
		
		public var name:String;
		public var level:WarningLevel;
		
		public function WarningType(name:String, level:WarningLevel)
		{
			this.name = name;
			this.level = level;
		}
	}
}