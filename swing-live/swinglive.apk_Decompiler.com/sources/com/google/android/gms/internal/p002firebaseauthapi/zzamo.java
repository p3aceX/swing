package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX WARN: Enum visitor error
jadx.core.utils.exceptions.JadxRuntimeException: Init of enum field 'zzc' uses external variables
	at jadx.core.dex.visitors.EnumVisitor.createEnumFieldByConstructor(EnumVisitor.java:451)
	at jadx.core.dex.visitors.EnumVisitor.processEnumFieldByRegister(EnumVisitor.java:395)
	at jadx.core.dex.visitors.EnumVisitor.extractEnumFieldsFromFilledArray(EnumVisitor.java:324)
	at jadx.core.dex.visitors.EnumVisitor.extractEnumFieldsFromInsn(EnumVisitor.java:262)
	at jadx.core.dex.visitors.EnumVisitor.convertToEnum(EnumVisitor.java:151)
	at jadx.core.dex.visitors.EnumVisitor.visit(EnumVisitor.java:100)
 */
/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX INFO: loaded from: classes.dex */
public class zzamo {
    public static final zzamo zza;
    public static final zzamo zzb;
    public static final zzamo zzc;
    public static final zzamo zzd;
    public static final zzamo zze;
    public static final zzamo zzf;
    public static final zzamo zzg;
    public static final zzamo zzh;
    public static final zzamo zzi;
    public static final zzamo zzj;
    public static final zzamo zzk;
    public static final zzamo zzl;
    public static final zzamo zzm;
    public static final zzamo zzn;
    public static final zzamo zzo;
    public static final zzamo zzp;
    public static final zzamo zzq;
    public static final zzamo zzr;
    private static final /* synthetic */ zzamo[] zzs;
    private final zzamy zzt;
    private final int zzu;

    static {
        zzamo zzamoVar = new zzamo("DOUBLE", 0, zzamy.DOUBLE, 1);
        zza = zzamoVar;
        zzamo zzamoVar2 = new zzamo("FLOAT", 1, zzamy.FLOAT, 5);
        zzb = zzamoVar2;
        zzamy zzamyVar = zzamy.LONG;
        zzamo zzamoVar3 = new zzamo("INT64", 2, zzamyVar, 0);
        zzc = zzamoVar3;
        zzamo zzamoVar4 = new zzamo("UINT64", 3, zzamyVar, 0);
        zzd = zzamoVar4;
        zzamy zzamyVar2 = zzamy.INT;
        zzamo zzamoVar5 = new zzamo("INT32", 4, zzamyVar2, 0);
        zze = zzamoVar5;
        zzamo zzamoVar6 = new zzamo("FIXED64", 5, zzamyVar, 1);
        zzf = zzamoVar6;
        zzamo zzamoVar7 = new zzamo("FIXED32", 6, zzamyVar2, 5);
        zzg = zzamoVar7;
        zzamo zzamoVar8 = new zzamo("BOOL", 7, zzamy.BOOLEAN, 0);
        zzh = zzamoVar8;
        zzamr zzamrVar = new zzamr("STRING", zzamy.STRING);
        zzi = zzamrVar;
        zzamy zzamyVar3 = zzamy.MESSAGE;
        zzamt zzamtVar = new zzamt("GROUP", zzamyVar3);
        zzj = zzamtVar;
        zzamv zzamvVar = new zzamv("MESSAGE", zzamyVar3);
        zzk = zzamvVar;
        zzamx zzamxVar = new zzamx("BYTES", zzamy.BYTE_STRING);
        zzl = zzamxVar;
        zzamo zzamoVar9 = new zzamo("UINT32", 12, zzamyVar2, 0);
        zzm = zzamoVar9;
        zzamo zzamoVar10 = new zzamo("ENUM", 13, zzamy.ENUM, 0);
        zzn = zzamoVar10;
        zzamo zzamoVar11 = new zzamo("SFIXED32", 14, zzamyVar2, 5);
        zzo = zzamoVar11;
        zzamo zzamoVar12 = new zzamo("SFIXED64", 15, zzamyVar, 1);
        zzp = zzamoVar12;
        zzamo zzamoVar13 = new zzamo("SINT32", 16, zzamyVar2, 0);
        zzq = zzamoVar13;
        zzamo zzamoVar14 = new zzamo("SINT64", 17, zzamyVar, 0);
        zzr = zzamoVar14;
        zzs = new zzamo[]{zzamoVar, zzamoVar2, zzamoVar3, zzamoVar4, zzamoVar5, zzamoVar6, zzamoVar7, zzamoVar8, zzamrVar, zzamtVar, zzamvVar, zzamxVar, zzamoVar9, zzamoVar10, zzamoVar11, zzamoVar12, zzamoVar13, zzamoVar14};
    }

    public static zzamo[] values() {
        return (zzamo[]) zzs.clone();
    }

    public final int zza() {
        return this.zzu;
    }

    public final zzamy zzb() {
        return this.zzt;
    }

    private zzamo(String str, int i4, zzamy zzamyVar, int i5) {
        this.zzt = zzamyVar;
        this.zzu = i5;
    }
}
