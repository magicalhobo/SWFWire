package com.swfwire.decompiler
{
	import com.swfwire.decompiler.abc.ABCByteArray;
	import com.swfwire.decompiler.abc.ABCEditor;
	import com.swfwire.decompiler.abc.ABCFile;
	import com.swfwire.decompiler.abc.ABCInstructionReader;
	import com.swfwire.decompiler.abc.ABCInstructionWriter;
	import com.swfwire.decompiler.abc.ABCInstructions;
	import com.swfwire.decompiler.abc.ABCReadResult;
	import com.swfwire.decompiler.abc.ABCReader;
	import com.swfwire.decompiler.abc.ABCReaderContext;
	import com.swfwire.decompiler.abc.ABCReaderMetadata;
	import com.swfwire.decompiler.abc.ABCWriteResult;
	import com.swfwire.decompiler.abc.ABCWriter;
	import com.swfwire.decompiler.abc.ABCWriterContext;
	import com.swfwire.decompiler.abc.ABCWriterMetadata;
	import com.swfwire.decompiler.abc.AVM2;
	import com.swfwire.decompiler.abc.LocalRegisters;
	import com.swfwire.decompiler.abc.MethodBodyReadResult;
	import com.swfwire.decompiler.abc.OperandStack;
	import com.swfwire.decompiler.abc.ScopeStack;
	import com.swfwire.decompiler.abc.instructions.*;
	import com.swfwire.decompiler.abc.tokens.ClassInfoToken;
	import com.swfwire.decompiler.abc.tokens.ConstantPoolToken;
	import com.swfwire.decompiler.abc.tokens.ExceptionInfoToken;
	import com.swfwire.decompiler.abc.tokens.IToken;
	import com.swfwire.decompiler.abc.tokens.InstanceToken;
	import com.swfwire.decompiler.abc.tokens.ItemInfoToken;
	import com.swfwire.decompiler.abc.tokens.MetadataInfoToken;
	import com.swfwire.decompiler.abc.tokens.MethodBodyInfoToken;
	import com.swfwire.decompiler.abc.tokens.MethodInfoToken;
	import com.swfwire.decompiler.abc.tokens.MultinameToken;
	import com.swfwire.decompiler.abc.tokens.NamespaceSetToken;
	import com.swfwire.decompiler.abc.tokens.NamespaceToken;
	import com.swfwire.decompiler.abc.tokens.OptionDetailToken;
	import com.swfwire.decompiler.abc.tokens.OptionInfoToken;
	import com.swfwire.decompiler.abc.tokens.ParamInfoToken;
	import com.swfwire.decompiler.abc.tokens.ScriptInfoToken;
	import com.swfwire.decompiler.abc.tokens.StringToken;
	import com.swfwire.decompiler.abc.tokens.TraitsInfoToken;
	import com.swfwire.decompiler.abc.tokens.cpool.CPoolIndex;
	import com.swfwire.decompiler.abc.tokens.cpool.MultinameIndex;
	import com.swfwire.decompiler.abc.tokens.cpool.NamespaceIndex;
	import com.swfwire.decompiler.abc.tokens.cpool.StringIndex;
	import com.swfwire.decompiler.abc.tokens.multinames.IMultiname;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameMultinameLToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameMultinameToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameQNameToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameRTQNameLToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameRTQNameToken;
	import com.swfwire.decompiler.abc.tokens.multinames.MultinameTypeNameToken;
	import com.swfwire.decompiler.abc.tokens.traits.ITrait;
	import com.swfwire.decompiler.abc.tokens.traits.TraitClassToken;
	import com.swfwire.decompiler.abc.tokens.traits.TraitFunctionToken;
	import com.swfwire.decompiler.abc.tokens.traits.TraitMethodToken;
	import com.swfwire.decompiler.abc.tokens.traits.TraitSlotToken;
	import com.swfwire.decompiler.data.swf.SWF;
	import com.swfwire.decompiler.data.swf.SWFHeader;
	import com.swfwire.decompiler.data.swf.records.BevelFilterRecord;
	import com.swfwire.decompiler.data.swf.records.BlurFilterRecord;
	import com.swfwire.decompiler.data.swf.records.ButtonRecord;
	import com.swfwire.decompiler.data.swf.records.CXFormRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionRecord;
	import com.swfwire.decompiler.data.swf.records.ClipActionsRecord;
	import com.swfwire.decompiler.data.swf.records.ClipEventFlagsRecord;
	import com.swfwire.decompiler.data.swf.records.ColorMatrixFilterRecord;
	import com.swfwire.decompiler.data.swf.records.ConvolutionFilterRecord;
	import com.swfwire.decompiler.data.swf.records.CurvedEdgeRecord;
	import com.swfwire.decompiler.data.swf.records.DropShadowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.EndShapeRecord;
	import com.swfwire.decompiler.data.swf.records.ExportAssetRecord;
	import com.swfwire.decompiler.data.swf.records.FillStyleArrayRecord;
	import com.swfwire.decompiler.data.swf.records.FillStyleRecord;
	import com.swfwire.decompiler.data.swf.records.FilterListRecord;
	import com.swfwire.decompiler.data.swf.records.FrameLabelRecord;
	import com.swfwire.decompiler.data.swf.records.GlowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.GlyphEntryRecord;
	import com.swfwire.decompiler.data.swf.records.GradRecordRGB;
	import com.swfwire.decompiler.data.swf.records.GradRecordRGBA;
	import com.swfwire.decompiler.data.swf.records.GradientBevelFilterRecord;
	import com.swfwire.decompiler.data.swf.records.GradientControlPointRecord;
	import com.swfwire.decompiler.data.swf.records.GradientGlowFilterRecord;
	import com.swfwire.decompiler.data.swf.records.GradientRecord;
	import com.swfwire.decompiler.data.swf.records.IFilterRecord;
	import com.swfwire.decompiler.data.swf.records.IGradientRecord;
	import com.swfwire.decompiler.data.swf.records.IRGBRecord;
	import com.swfwire.decompiler.data.swf.records.IShapeRecord;
	import com.swfwire.decompiler.data.swf.records.ImportAssets2Record;
	import com.swfwire.decompiler.data.swf.records.LanguageCodeRecord;
	import com.swfwire.decompiler.data.swf.records.LineStyleArrayRecord;
	import com.swfwire.decompiler.data.swf.records.LineStyleRecord;
	import com.swfwire.decompiler.data.swf.records.MatrixRecord;
	import com.swfwire.decompiler.data.swf.records.RGBARecord;
	import com.swfwire.decompiler.data.swf.records.RGBRecord;
	import com.swfwire.decompiler.data.swf.records.RectangleRecord;
	import com.swfwire.decompiler.data.swf.records.SceneRecord;
	import com.swfwire.decompiler.data.swf.records.ShapeWithStyleRecord;
	import com.swfwire.decompiler.data.swf.records.StraightEdgeRecord;
	import com.swfwire.decompiler.data.swf.records.StyleChangeRecord;
	import com.swfwire.decompiler.data.swf.records.SymbolClassRecord;
	import com.swfwire.decompiler.data.swf.records.TagHeaderRecord;
	import com.swfwire.decompiler.data.swf.records.TextRecord;
	import com.swfwire.decompiler.data.swf.structures.MatrixRotateStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixScaleStructure;
	import com.swfwire.decompiler.data.swf.structures.MatrixTranslateStructure;
	import com.swfwire.decompiler.data.swf.tags.DefineBitsTag;
	import com.swfwire.decompiler.data.swf.tags.DefineButtonTag;
	import com.swfwire.decompiler.data.swf.tags.DefineFontInfoTag;
	import com.swfwire.decompiler.data.swf.tags.DefineFontTag;
	import com.swfwire.decompiler.data.swf.tags.DefineSceneAndFrameLabelDataTag;
	import com.swfwire.decompiler.data.swf.tags.DefineShapeTag;
	import com.swfwire.decompiler.data.swf.tags.DefineSoundTag;
	import com.swfwire.decompiler.data.swf.tags.DefineTextTag;
	import com.swfwire.decompiler.data.swf.tags.EndTag;
	import com.swfwire.decompiler.data.swf.tags.JPEGTablesTag;
	import com.swfwire.decompiler.data.swf.tags.MetadataTag;
	import com.swfwire.decompiler.data.swf.tags.PlaceObjectTag;
	import com.swfwire.decompiler.data.swf.tags.RemoveObjectTag;
	import com.swfwire.decompiler.data.swf.tags.SWFTag;
	import com.swfwire.decompiler.data.swf.tags.SetBackgroundColorTag;
	import com.swfwire.decompiler.data.swf.tags.ShowFrameTag;
	import com.swfwire.decompiler.data.swf.tags.SoundStreamBlockTag;
	import com.swfwire.decompiler.data.swf.tags.SoundStreamHeadTag;
	import com.swfwire.decompiler.data.swf.tags.StartSoundTag;
	import com.swfwire.decompiler.data.swf.tags.UnknownTag;
	import com.swfwire.decompiler.data.swf10.tags.DefineBitsJPEG4Tag;
	import com.swfwire.decompiler.data.swf10.tags.DefineFont4Tag;
	import com.swfwire.decompiler.data.swf10.tags.DefineShape4Tag;
	import com.swfwire.decompiler.data.swf10.tags.ProductInfoTag;
	import com.swfwire.decompiler.data.swf2.records.BitmapDataRecord;
	import com.swfwire.decompiler.data.swf2.records.BitmapDataRecord2;
	import com.swfwire.decompiler.data.swf2.records.FillStyleArrayRecord2;
	import com.swfwire.decompiler.data.swf2.records.IPixRecord;
	import com.swfwire.decompiler.data.swf2.records.Pix15Record;
	import com.swfwire.decompiler.data.swf2.records.Pix24Record;
	import com.swfwire.decompiler.data.swf2.records.ShapeWithStyleRecord2;
	import com.swfwire.decompiler.data.swf2.records.StyleChangeRecord2;
	import com.swfwire.decompiler.data.swf2.tags.DefineBitsJPEG2Tag;
	import com.swfwire.decompiler.data.swf2.tags.DefineBitsLosslessTag;
	import com.swfwire.decompiler.data.swf2.tags.DefineButtonCxformTag;
	import com.swfwire.decompiler.data.swf2.tags.DefineButtonSoundTag;
	import com.swfwire.decompiler.data.swf2.tags.DefineShape2Tag;
	import com.swfwire.decompiler.data.swf2.tags.ProtectTag;
	import com.swfwire.decompiler.data.swf3.actions.ButtonCondAction;
	import com.swfwire.decompiler.data.swf3.records.ARGBRecord;
	import com.swfwire.decompiler.data.swf3.records.ActionRecord;
	import com.swfwire.decompiler.data.swf3.records.AlphaBitmapDataRecord;
	import com.swfwire.decompiler.data.swf3.records.AlphaColorMapDataRecord;
	import com.swfwire.decompiler.data.swf3.records.ButtonRecord2;
	import com.swfwire.decompiler.data.swf3.records.CXFormWithAlphaRecord;
	import com.swfwire.decompiler.data.swf3.records.FillStyleArrayRecord3;
	import com.swfwire.decompiler.data.swf3.records.FillStyleRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientControlPointRecord2;
	import com.swfwire.decompiler.data.swf3.records.GradientRecord2;
	import com.swfwire.decompiler.data.swf3.records.LineStyleArrayRecord2;
	import com.swfwire.decompiler.data.swf3.records.LineStyleRecord2;
	import com.swfwire.decompiler.data.swf3.records.ShapeWithStyleRecord3;
	import com.swfwire.decompiler.data.swf3.records.StyleChangeRecord3;
	import com.swfwire.decompiler.data.swf3.tags.DefineBitsJPEG3Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineBitsLossless2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineButton2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineFont2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineMorphShapeTag;
	import com.swfwire.decompiler.data.swf3.tags.DefineShape3Tag;
	import com.swfwire.decompiler.data.swf3.tags.DefineSpriteTag;
	import com.swfwire.decompiler.data.swf3.tags.DefineText2Tag;
	import com.swfwire.decompiler.data.swf3.tags.DoActionTag;
	import com.swfwire.decompiler.data.swf3.tags.FrameLabelTag;
	import com.swfwire.decompiler.data.swf3.tags.PlaceObject2Tag;
	import com.swfwire.decompiler.data.swf3.tags.RemoveObject2Tag;
	import com.swfwire.decompiler.data.swf3.tags.SoundStreamHead2Tag;
	import com.swfwire.decompiler.data.swf4.tags.DefineEditTextTag;
	import com.swfwire.decompiler.data.swf5.tags.EnableDebuggerTag;
	import com.swfwire.decompiler.data.swf5.tags.ExportAssetsTag;
	import com.swfwire.decompiler.data.swf5.tags.ImportAssetsTag;
	import com.swfwire.decompiler.data.swf6.tags.DefineFontInfo2Tag;
	import com.swfwire.decompiler.data.swf6.tags.DefineVideoStreamTag;
	import com.swfwire.decompiler.data.swf6.tags.DoInitActionTag;
	import com.swfwire.decompiler.data.swf6.tags.EnableDebugger2Tag;
	import com.swfwire.decompiler.data.swf6.tags.VideoFrameTag;
	import com.swfwire.decompiler.data.swf7.tags.DefineVideoStreamTag;
	import com.swfwire.decompiler.data.swf7.tags.ScriptLimitsTag;
	import com.swfwire.decompiler.data.swf7.tags.SetTabIndexTag;
	import com.swfwire.decompiler.data.swf8.records.FocalGradientRecord;
	import com.swfwire.decompiler.data.swf8.records.FontShapeRecord;
	import com.swfwire.decompiler.data.swf8.records.KerningRecord;
	import com.swfwire.decompiler.data.swf8.records.LineStyle2ArrayRecord;
	import com.swfwire.decompiler.data.swf8.records.LineStyle2Record;
	import com.swfwire.decompiler.data.swf8.records.ShapeWithStyleRecord4;
	import com.swfwire.decompiler.data.swf8.records.StyleChangeRecord4;
	import com.swfwire.decompiler.data.swf8.records.ZoneDataRecord;
	import com.swfwire.decompiler.data.swf8.records.ZoneRecord;
	import com.swfwire.decompiler.data.swf8.tags.CSMTextSettingsTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineBitsJPEG2Tag2;
	import com.swfwire.decompiler.data.swf8.tags.DefineFont3Tag;
	import com.swfwire.decompiler.data.swf8.tags.DefineFontAlignZonesTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineMorphShape2Tag;
	import com.swfwire.decompiler.data.swf8.tags.DefineScalingGridTag;
	import com.swfwire.decompiler.data.swf8.tags.DefineShape4Tag;
	import com.swfwire.decompiler.data.swf8.tags.DefineVideoStreamTag;
	import com.swfwire.decompiler.data.swf8.tags.FileAttributesTag;
	import com.swfwire.decompiler.data.swf8.tags.ImportAssets2Tag;
	import com.swfwire.decompiler.data.swf8.tags.PlaceObject3Tag;
	import com.swfwire.decompiler.data.swf9.tags.DefineBinaryDataTag;
	import com.swfwire.decompiler.data.swf9.tags.DefineFontNameTag;
	import com.swfwire.decompiler.data.swf9.tags.DoABCTag;
	import com.swfwire.decompiler.data.swf9.tags.StartSound2Tag;
	import com.swfwire.decompiler.data.swf9.tags.SymbolClassTag;
	import com.swfwire.decompiler.events.AsyncSWFModifierEvent;
	import com.swfwire.decompiler.events.AsyncSWFReaderEvent;
	import com.swfwire.decompiler.events.AsyncSWFWriterEvent;
	
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	
	import avmplus.getQualifiedClassName;

	public class Serializable
	{
		public static var classes:Vector.<Class> = Vector.<Class>([
			ABCByteArray,
			ABCEditor,
			ABCFile,
			ABCInstructionReader,
			ABCInstructionWriter,
			ABCInstructions,
			ABCReadResult,
			ABCReader,
			ABCReaderContext,
			ABCReaderMetadata,
			ABCWriteResult,
			ABCWriter,
			ABCWriterContext,
			ABCWriterMetadata,
			ARGBRecord,
			AVM2,
			ActionRecord,
			AlphaBitmapDataRecord,
			AlphaColorMapDataRecord,
			AsyncSWFModifier,
			AsyncSWFModifierEvent,
			AsyncSWFReader,
			AsyncSWFReaderEvent,
			AsyncSWFReaderFiltered,
			AsyncSWFWriter,
			AsyncSWFWriterEvent,
			BevelFilterRecord,
			BitmapDataRecord,
			BitmapDataRecord2,
			BlurFilterRecord,
			ButtonCondAction,
			ButtonRecord,
			ButtonRecord2,
			CPoolIndex,
			CSMTextSettingsTag,
			CXFormRecord,
			CXFormWithAlphaRecord,
			ClassInfoToken,
			ClipActionRecord,
			ClipActionsRecord,
			ClipEventFlagsRecord,
			ColorMatrixFilterRecord,
			ConstantPoolToken,
			ConvolutionFilterRecord,
			CurvedEdgeRecord,
			DefineBinaryDataTag,
			DefineBitsJPEG2Tag,
			DefineBitsJPEG2Tag2,
			DefineBitsJPEG3Tag,
			DefineBitsJPEG4Tag,
			DefineBitsLossless2Tag,
			DefineBitsLosslessTag,
			DefineBitsTag,
			DefineButton2Tag,
			DefineButtonCxformTag,
			DefineButtonSoundTag,
			DefineButtonTag,
			DefineEditTextTag,
			DefineFont2Tag,
			DefineFont3Tag,
			DefineFont4Tag,
			DefineFontAlignZonesTag,
			DefineFontInfo2Tag,
			DefineFontInfoTag,
			DefineFontNameTag,
			DefineFontTag,
			DefineMorphShape2Tag,
			DefineMorphShapeTag,
			DefineScalingGridTag,
			DefineSceneAndFrameLabelDataTag,
			DefineShape2Tag,
			DefineShape3Tag,
			com.swfwire.decompiler.data.swf8.tags.DefineShape4Tag,
			com.swfwire.decompiler.data.swf10.tags.DefineShape4Tag,
			DefineShapeTag,
			DefineSoundTag,
			DefineSpriteTag,
			DefineText2Tag,
			DefineTextTag,
			com.swfwire.decompiler.data.swf6.tags.DefineVideoStreamTag,
			com.swfwire.decompiler.data.swf7.tags.DefineVideoStreamTag,
			com.swfwire.decompiler.data.swf8.tags.DefineVideoStreamTag,
			DoABCTag,
			DoActionTag,
			DoInitActionTag,
			DropShadowFilterRecord,
			EnableDebugger2Tag,
			EnableDebuggerTag,
			EndInstruction,
			EndShapeRecord,
			EndTag,
			ExceptionInfoToken,
			ExportAssetRecord,
			ExportAssetsTag,
			FileAttributesTag,
			FillStyleArrayRecord,
			FillStyleArrayRecord2,
			FillStyleArrayRecord3,
			FillStyleRecord,
			FillStyleRecord2,
			FilterListRecord,
			FocalGradientRecord,
			FontShapeRecord,
			FrameLabelRecord,
			FrameLabelTag,
			GlowFilterRecord,
			GlyphEntryRecord,
			GradRecordRGB,
			GradRecordRGBA,
			GradientBevelFilterRecord,
			GradientControlPointRecord,
			GradientControlPointRecord2,
			GradientGlowFilterRecord,
			GradientRecord,
			GradientRecord2,
			IFilterRecord,
			IGradientRecord,
			IInstruction,
			IMultiname,
			IPixRecord,
			IRGBRecord,
			IShapeRecord,
			IToken,
			ITrait,
			ImportAssets2Record,
			ImportAssets2Tag,
			ImportAssetsTag,
			InstanceToken,
			Instruction_0x01,
			Instruction_0xF2,
			Instruction_add,
			Instruction_add_i,
			Instruction_applytype,
			Instruction_astype,
			Instruction_astypelate,
			Instruction_bitand,
			Instruction_bitnot,
			Instruction_bitor,
			Instruction_bitxor,
			Instruction_call,
			Instruction_callmethod,
			Instruction_callproperty,
			Instruction_callproplex,
			Instruction_callpropvoid,
			Instruction_callstatic,
			Instruction_callsuper,
			Instruction_callsupervoid,
			Instruction_checkfilter,
			Instruction_coerce,
			Instruction_coerce_a,
			Instruction_coerce_b,
			Instruction_coerce_d,
			Instruction_coerce_i,
			Instruction_coerce_o,
			Instruction_coerce_s,
			Instruction_coerce_u,
			Instruction_construct,
			Instruction_constructprop,
			Instruction_constructsuper,
			Instruction_convert_b,
			Instruction_convert_d,
			Instruction_convert_i,
			Instruction_convert_o,
			Instruction_convert_s,
			Instruction_convert_u,
			Instruction_debug,
			Instruction_debugfile,
			Instruction_debugline,
			Instruction_declocal,
			Instruction_declocal_i,
			Instruction_decrement,
			Instruction_decrement_i,
			Instruction_deleteproperty,
			Instruction_divide,
			Instruction_dup,
			Instruction_dxns,
			Instruction_dxnslate,
			Instruction_equals,
			Instruction_esc_xattr,
			Instruction_esc_xelem,
			Instruction_finddef,
			Instruction_findproperty,
			Instruction_findpropglobal,
			Instruction_findpropglobalstrict,
			Instruction_findpropstrict,
			Instruction_getdescendants,
			Instruction_getglobalscope,
			Instruction_getglobalslot,
			Instruction_getlex,
			Instruction_getlocal,
			Instruction_getlocal0,
			Instruction_getlocal1,
			Instruction_getlocal2,
			Instruction_getlocal3,
			Instruction_getouterscope,
			Instruction_getproperty,
			Instruction_getscopeobject,
			Instruction_getslot,
			Instruction_getsuper,
			Instruction_greaterequals,
			Instruction_greaterthan,
			Instruction_hasnext,
			Instruction_hasnext2,
			Instruction_ifeq,
			Instruction_iffalse,
			Instruction_ifge,
			Instruction_ifgt,
			Instruction_ifle,
			Instruction_iflt,
			Instruction_ifne,
			Instruction_ifnge,
			Instruction_ifngt,
			Instruction_ifnle,
			Instruction_ifnlt,
			Instruction_ifstricteq,
			Instruction_ifstrictne,
			Instruction_iftrue,
			Instruction_in,
			Instruction_inclocal,
			Instruction_inclocal_i,
			Instruction_increment,
			Instruction_increment_i,
			Instruction_initproperty,
			Instruction_instanceof,
			Instruction_istype,
			Instruction_istypelate,
			Instruction_jump,
			Instruction_kill,
			Instruction_label,
			Instruction_lessequals,
			Instruction_lessthan,
			Instruction_lf32,
			Instruction_lf64,
			Instruction_li16,
			Instruction_li32,
			Instruction_li8,
			Instruction_lookupswitch,
			Instruction_lshift,
			Instruction_modulo,
			Instruction_multiply,
			Instruction_multiply_i,
			Instruction_negate,
			Instruction_negate_i,
			Instruction_newactivation,
			Instruction_newarray,
			Instruction_newcatch,
			Instruction_newclass,
			Instruction_newfunction,
			Instruction_newobject,
			Instruction_nextname,
			Instruction_nextvalue,
			Instruction_nop,
			Instruction_not,
			Instruction_pop,
			Instruction_popscope,
			Instruction_pushbyte,
			Instruction_pushdouble,
			Instruction_pushfalse,
			Instruction_pushint,
			Instruction_pushnamespace,
			Instruction_pushnan,
			Instruction_pushnull,
			Instruction_pushscope,
			Instruction_pushshort,
			Instruction_pushstring,
			Instruction_pushtrue,
			Instruction_pushuint,
			Instruction_pushundefined,
			Instruction_pushwith,
			Instruction_returnvalue,
			Instruction_returnvoid,
			Instruction_rshift,
			Instruction_setglobalslot,
			Instruction_setlocal,
			Instruction_setlocal0,
			Instruction_setlocal1,
			Instruction_setlocal2,
			Instruction_setlocal3,
			Instruction_setproperty,
			Instruction_setslot,
			Instruction_setsuper,
			Instruction_sf32,
			Instruction_sf64,
			Instruction_si16,
			Instruction_si32,
			Instruction_si8,
			Instruction_strictequals,
			Instruction_subtract,
			Instruction_subtract_i,
			Instruction_swap,
			Instruction_sxi1,
			Instruction_sxi16,
			Instruction_sxi8,
			Instruction_throw,
			Instruction_typeof,
			Instruction_urshift,
			ItemInfoToken,
			JPEGTablesTag,
			KerningRecord,
			LanguageCodeRecord,
			LineStyle2ArrayRecord,
			LineStyle2Record,
			LineStyleArrayRecord,
			LineStyleArrayRecord2,
			LineStyleRecord,
			LineStyleRecord2,
			LocalRegisters,
			MatrixRecord,
			MatrixRotateStructure,
			MatrixScaleStructure,
			MatrixTranslateStructure,
			MetadataInfoToken,
			MetadataTag,
			MethodBodyInfoToken,
			MethodBodyReadResult,
			MethodInfoToken,
			MultinameIndex,
			MultinameMultinameLToken,
			MultinameMultinameToken,
			MultinameQNameToken,
			MultinameRTQNameLToken,
			MultinameRTQNameToken,
			MultinameToken,
			MultinameTypeNameToken,
			NamespaceIndex,
			NamespaceSetToken,
			NamespaceToken,
			OperandStack,
			OptionDetailToken,
			OptionInfoToken,
			ParamInfoToken,
			Pix15Record,
			Pix24Record,
			PlaceObject2Tag,
			PlaceObject3Tag,
			PlaceObjectTag,
			ProductInfoTag,
			ProtectTag,
			RGBARecord,
			RGBRecord,
			RectangleRecord,
			RemoveObject2Tag,
			RemoveObjectTag,
			SWF,
			SWF10Reader,
			SWF10Writer,
			SWF2Reader,
			SWF2Writer,
			SWF3Reader,
			SWF3Writer,
			SWF4Reader,
			SWF4Writer,
			SWF5Reader,
			SWF5Writer,
			SWF6Reader,
			SWF6Writer,
			SWF7Reader,
			SWF7Writer,
			SWF8Reader,
			SWF8Writer,
			SWF9Reader,
			SWF9Writer,
			SWFByteArray,
			SWFHeader,
			SWFNormalizer,
			SWFReadResult,
			SWFReader,
			SWFReaderContext,
			SWFReaderTagMetadata,
			SWFTag,
			SWFWireDecompilerConfig,
			SWFWriteResult,
			SWFWriter,
			SWFWriterContext,
			SceneRecord,
			ScopeStack,
			ScriptInfoToken,
			ScriptLimitsTag,
			SetBackgroundColorTag,
			SetTabIndexTag,
			ShapeWithStyleRecord,
			ShapeWithStyleRecord2,
			ShapeWithStyleRecord3,
			ShapeWithStyleRecord4,
			ShowFrameTag,
			SoundStreamBlockTag,
			SoundStreamHead2Tag,
			SoundStreamHeadTag,
			StartSound2Tag,
			StartSoundTag,
			StraightEdgeRecord,
			StringIndex,
			StringToken,
			StyleChangeRecord,
			StyleChangeRecord2,
			StyleChangeRecord3,
			StyleChangeRecord4,
			SymbolClassRecord,
			SymbolClassTag,
			TagHeaderRecord,
			TextRecord,
			TraitClassToken,
			TraitFunctionToken,
			TraitMethodToken,
			TraitSlotToken,
			TraitsInfoToken,
			UnknownInstruction,
			UnknownTag,
			VideoFrameTag,
			ZoneDataRecord,
			ZoneRecord
		]);
		
		public static function registerAll():void
		{
			register(Array);
			register(Dictionary);
			register(String);
			for each(var c:Class in classes)
			{
				register(c);
			}
		}
		
		private static function register(c:Class):void
		{
			registerClassAlias(getQualifiedClassName(c), c);
		}
	}
}