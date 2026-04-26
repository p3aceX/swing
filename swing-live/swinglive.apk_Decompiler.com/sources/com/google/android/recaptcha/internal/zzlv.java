package com.google.android.recaptcha.internal;

import java.lang.reflect.Field;
import java.nio.Buffer;
import java.security.AccessController;
import java.util.logging.Level;
import java.util.logging.Logger;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
final class zzlv {
    static final long zza;
    static final boolean zzb;
    private static final Unsafe zzc;
    private static final Class zzd;
    private static final boolean zze;
    private static final zzlu zzf;
    private static final boolean zzg;
    private static final boolean zzh;

    /* JADX WARN: Removed duplicated region for block: B:11:0x003d  */
    static {
        /*
            Method dump skipped, instruction units count: 282
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzlv.<clinit>():void");
    }

    private zzlv() {
    }

    private static int zzA(Class cls) {
        if (zzh) {
            return zzf.zza.arrayIndexScale(cls);
        }
        return -1;
    }

    private static Field zzB() {
        int i4 = zzgi.zza;
        Field fieldZzC = zzC(Buffer.class, "effectiveDirectAddress");
        if (fieldZzC != null) {
            return fieldZzC;
        }
        Field fieldZzC2 = zzC(Buffer.class, "address");
        if (fieldZzC2 == null || fieldZzC2.getType() != Long.TYPE) {
            return null;
        }
        return fieldZzC2;
    }

    private static Field zzC(Class cls, String str) {
        try {
            return cls.getDeclaredField(str);
        } catch (Throwable unused) {
            return null;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static void zzD(Object obj, long j4, byte b5) {
        zzlu zzluVar = zzf;
        long j5 = (-4) & j4;
        int i4 = zzluVar.zza.getInt(obj, j5);
        int i5 = ((~((int) j4)) & 3) << 3;
        zzluVar.zza.putInt(obj, j5, ((255 & b5) << i5) | (i4 & (~(255 << i5))));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static void zzE(Object obj, long j4, byte b5) {
        zzlu zzluVar = zzf;
        long j5 = (-4) & j4;
        int i4 = (((int) j4) & 3) << 3;
        zzluVar.zza.putInt(obj, j5, ((255 & b5) << i4) | (zzluVar.zza.getInt(obj, j5) & (~(255 << i4))));
    }

    public static double zza(Object obj, long j4) {
        return zzf.zza(obj, j4);
    }

    public static float zzb(Object obj, long j4) {
        return zzf.zzb(obj, j4);
    }

    public static int zzc(Object obj, long j4) {
        return zzf.zza.getInt(obj, j4);
    }

    public static long zzd(Object obj, long j4) {
        return zzf.zza.getLong(obj, j4);
    }

    public static Object zze(Class cls) {
        try {
            return zzc.allocateInstance(cls);
        } catch (InstantiationException e) {
            throw new IllegalStateException(e);
        }
    }

    public static Object zzf(Object obj, long j4) {
        return zzf.zza.getObject(obj, j4);
    }

    public static Unsafe zzg() {
        try {
            return (Unsafe) AccessController.doPrivileged(new zzlr());
        } catch (Throwable unused) {
            return null;
        }
    }

    public static /* bridge */ /* synthetic */ void zzh(Throwable th) {
        Logger.getLogger(zzlv.class.getName()).logp(Level.WARNING, "com.google.protobuf.UnsafeUtil", "logMissingMethod", "platform method missing - proto runtime falling back to safer methods: ".concat(th.toString()));
    }

    public static void zzm(Object obj, long j4, boolean z4) {
        zzf.zzc(obj, j4, z4);
    }

    public static void zzn(byte[] bArr, long j4, byte b5) {
        zzf.zzd(bArr, zza + j4, b5);
    }

    public static void zzo(Object obj, long j4, double d5) {
        zzf.zze(obj, j4, d5);
    }

    public static void zzp(Object obj, long j4, float f4) {
        zzf.zzf(obj, j4, f4);
    }

    public static void zzq(Object obj, long j4, int i4) {
        zzf.zza.putInt(obj, j4, i4);
    }

    public static void zzr(Object obj, long j4, long j5) {
        zzf.zza.putLong(obj, j4, j5);
    }

    public static void zzs(Object obj, long j4, Object obj2) {
        zzf.zza.putObject(obj, j4, obj2);
    }

    public static /* bridge */ /* synthetic */ boolean zzt(Object obj, long j4) {
        return ((byte) ((zzf.zza.getInt(obj, (-4) & j4) >>> ((int) (((~j4) & 3) << 3))) & 255)) != 0;
    }

    public static /* bridge */ /* synthetic */ boolean zzu(Object obj, long j4) {
        return ((byte) ((zzf.zza.getInt(obj, (-4) & j4) >>> ((int) ((j4 & 3) << 3))) & 255)) != 0;
    }

    public static boolean zzv(Class cls) {
        int i4 = zzgi.zza;
        try {
            Class cls2 = zzd;
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

    public static boolean zzw(Object obj, long j4) {
        return zzf.zzg(obj, j4);
    }

    public static boolean zzx() {
        return zzh;
    }

    public static boolean zzy() {
        return zzg;
    }

    private static int zzz(Class cls) {
        if (zzh) {
            return zzf.zza.arrayBaseOffset(cls);
        }
        return -1;
    }
}
