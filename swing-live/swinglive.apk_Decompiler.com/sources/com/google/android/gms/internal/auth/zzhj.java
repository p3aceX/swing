package com.google.android.gms.internal.auth;

import java.lang.reflect.Field;
import java.nio.Buffer;
import java.security.AccessController;
import java.util.logging.Level;
import java.util.logging.Logger;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
final class zzhj {
    static final boolean zza;
    private static final Unsafe zzb;
    private static final Class zzc;
    private static final boolean zzd;
    private static final zzhi zze;
    private static final boolean zzf;
    private static final boolean zzg;

    /* JADX WARN: Removed duplicated region for block: B:11:0x003d  */
    static {
        /*
            Method dump skipped, instruction units count: 278
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.auth.zzhj.<clinit>():void");
    }

    private zzhj() {
    }

    public static double zza(Object obj, long j4) {
        return zze.zza(obj, j4);
    }

    public static float zzb(Object obj, long j4) {
        return zze.zzb(obj, j4);
    }

    public static int zzc(Object obj, long j4) {
        return zze.zza.getInt(obj, j4);
    }

    public static long zzd(Object obj, long j4) {
        return zze.zza.getLong(obj, j4);
    }

    public static Object zze(Class cls) {
        try {
            return zzb.allocateInstance(cls);
        } catch (InstantiationException e) {
            throw new IllegalStateException(e);
        }
    }

    public static Object zzf(Object obj, long j4) {
        return zze.zza.getObject(obj, j4);
    }

    public static Unsafe zzg() {
        try {
            return (Unsafe) AccessController.doPrivileged(new zzhf());
        } catch (Throwable unused) {
            return null;
        }
    }

    public static /* bridge */ /* synthetic */ void zzh(Throwable th) {
        Logger.getLogger(zzhj.class.getName()).logp(Level.WARNING, "com.google.protobuf.UnsafeUtil", "logMissingMethod", "platform method missing - proto runtime falling back to safer methods: ".concat(th.toString()));
    }

    public static /* synthetic */ void zzi(Object obj, long j4, boolean z4) {
        zzhi zzhiVar = zze;
        long j5 = (-4) & j4;
        int i4 = zzhiVar.zza.getInt(obj, j5);
        int i5 = ((~((int) j4)) & 3) << 3;
        zzhiVar.zza.putInt(obj, j5, ((z4 ? 1 : 0) << i5) | ((~(255 << i5)) & i4));
    }

    public static /* synthetic */ void zzj(Object obj, long j4, boolean z4) {
        zzhi zzhiVar = zze;
        long j5 = (-4) & j4;
        int i4 = (((int) j4) & 3) << 3;
        zzhiVar.zza.putInt(obj, j5, ((z4 ? 1 : 0) << i4) | ((~(255 << i4)) & zzhiVar.zza.getInt(obj, j5)));
    }

    public static void zzk(Object obj, long j4, boolean z4) {
        zze.zzc(obj, j4, z4);
    }

    public static void zzl(Object obj, long j4, double d5) {
        zze.zzd(obj, j4, d5);
    }

    public static void zzm(Object obj, long j4, float f4) {
        zze.zze(obj, j4, f4);
    }

    public static void zzn(Object obj, long j4, int i4) {
        zze.zza.putInt(obj, j4, i4);
    }

    public static void zzo(Object obj, long j4, long j5) {
        zze.zza.putLong(obj, j4, j5);
    }

    public static void zzp(Object obj, long j4, Object obj2) {
        zze.zza.putObject(obj, j4, obj2);
    }

    public static /* bridge */ /* synthetic */ boolean zzq(Object obj, long j4) {
        return ((byte) ((zze.zza.getInt(obj, (-4) & j4) >>> ((int) (((~j4) & 3) << 3))) & 255)) != 0;
    }

    public static /* bridge */ /* synthetic */ boolean zzr(Object obj, long j4) {
        return ((byte) ((zze.zza.getInt(obj, (-4) & j4) >>> ((int) ((j4 & 3) << 3))) & 255)) != 0;
    }

    public static boolean zzs(Class cls) {
        int i4 = zzds.zza;
        try {
            Class cls2 = zzc;
            Class cls3 = Boolean.TYPE;
            cls2.getMethod("peekLong", cls, cls3);
            cls2.getMethod("pokeLong", cls, Long.TYPE, cls3);
            Class cls4 = Integer.TYPE;
            cls2.getMethod("pokeInt", cls, cls4, cls3);
            cls2.getMethod("peekInt", cls, cls3);
            cls2.getMethod("pokeByte", cls, Byte.TYPE);
            cls2.getMethod("peekByte", cls);
            cls2.getMethod("pokeByteArray", cls, byte[].class, cls4, cls4);
            cls2.getMethod("peekByteArray", cls, byte[].class, cls4, cls4);
            return true;
        } catch (Throwable unused) {
            return false;
        }
    }

    public static boolean zzt(Object obj, long j4) {
        return zze.zzf(obj, j4);
    }

    public static boolean zzu() {
        return zzg;
    }

    public static boolean zzv() {
        return zzf;
    }

    private static int zzw(Class cls) {
        if (zzg) {
            return zze.zza.arrayBaseOffset(cls);
        }
        return -1;
    }

    private static int zzx(Class cls) {
        if (zzg) {
            return zze.zza.arrayIndexScale(cls);
        }
        return -1;
    }

    private static Field zzy() {
        int i4 = zzds.zza;
        Field fieldZzz = zzz(Buffer.class, "effectiveDirectAddress");
        if (fieldZzz != null) {
            return fieldZzz;
        }
        Field fieldZzz2 = zzz(Buffer.class, "address");
        if (fieldZzz2 == null || fieldZzz2.getType() != Long.TYPE) {
            return null;
        }
        return fieldZzz2;
    }

    private static Field zzz(Class cls, String str) {
        try {
            return cls.getDeclaredField(str);
        } catch (Throwable unused) {
            return null;
        }
    }
}
