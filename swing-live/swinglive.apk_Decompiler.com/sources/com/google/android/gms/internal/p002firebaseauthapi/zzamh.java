package com.google.android.gms.internal.p002firebaseauthapi;

import java.lang.reflect.Field;
import java.nio.Buffer;
import java.security.AccessController;
import java.util.logging.Level;
import java.util.logging.Logger;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
final class zzamh {
    static final boolean zza;
    private static final Unsafe zzb;
    private static final Class<?> zzc;
    private static final boolean zzd;
    private static final boolean zze;
    private static final zzb zzf;
    private static final boolean zzg;
    private static final boolean zzh;
    private static final long zzi;
    private static final long zzj;
    private static final long zzk;
    private static final long zzl;
    private static final long zzm;
    private static final long zzn;
    private static final long zzo;
    private static final long zzp;
    private static final long zzq;
    private static final long zzr;
    private static final long zzs;
    private static final long zzt;
    private static final long zzu;
    private static final long zzv;
    private static final int zzw;

    public static final class zza extends zzb {
        public zza(Unsafe unsafe) {
            super(unsafe);
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final double zza(Object obj, long j4) {
            return Double.longBitsToDouble(zze(obj, j4));
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final float zzb(Object obj, long j4) {
            return Float.intBitsToFloat(zzd(obj, j4));
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final boolean zzc(Object obj, long j4) {
            return zzamh.zza ? zzamh.zzf(obj, j4) : zzamh.zzg(obj, j4);
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, boolean z4) {
            if (zzamh.zza) {
                zzamh.zza(obj, j4, z4);
            } else {
                zzamh.zzb(obj, j4, z4);
            }
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, byte b5) {
            if (!zzamh.zza) {
                zzamh.zzd(obj, j4, b5);
            } else {
                zzamh.zzc(obj, j4, b5);
            }
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, double d5) {
            zza(obj, j4, Double.doubleToLongBits(d5));
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, float f4) {
            zza(obj, j4, Float.floatToIntBits(f4));
        }
    }

    public static abstract class zzb {
        Unsafe zza;

        public zzb(Unsafe unsafe) {
            this.zza = unsafe;
        }

        public abstract double zza(Object obj, long j4);

        public abstract void zza(Object obj, long j4, byte b5);

        public abstract void zza(Object obj, long j4, double d5);

        public abstract void zza(Object obj, long j4, float f4);

        public final void zza(Object obj, long j4, int i4) {
            this.zza.putInt(obj, j4, i4);
        }

        public abstract void zza(Object obj, long j4, boolean z4);

        public abstract float zzb(Object obj, long j4);

        public final boolean zzb() {
            Unsafe unsafe = this.zza;
            if (unsafe == null) {
                return false;
            }
            try {
                Class<?> cls = unsafe.getClass();
                cls.getMethod("objectFieldOffset", Field.class);
                cls.getMethod("getLong", Object.class, Long.TYPE);
                return zzamh.zze() != null;
            } catch (Throwable th) {
                zzamh.zza(th);
                return false;
            }
        }

        public abstract boolean zzc(Object obj, long j4);

        public final int zzd(Object obj, long j4) {
            return this.zza.getInt(obj, j4);
        }

        public final long zze(Object obj, long j4) {
            return this.zza.getLong(obj, j4);
        }

        public final void zza(Object obj, long j4, long j5) {
            this.zza.putLong(obj, j4, j5);
        }

        public final boolean zza() {
            Unsafe unsafe = this.zza;
            if (unsafe == null) {
                return false;
            }
            try {
                Class<?> cls = unsafe.getClass();
                cls.getMethod("objectFieldOffset", Field.class);
                cls.getMethod("arrayBaseOffset", Class.class);
                cls.getMethod("arrayIndexScale", Class.class);
                Class cls2 = Long.TYPE;
                cls.getMethod("getInt", Object.class, cls2);
                cls.getMethod("putInt", Object.class, cls2, Integer.TYPE);
                cls.getMethod("getLong", Object.class, cls2);
                cls.getMethod("putLong", Object.class, cls2, cls2);
                cls.getMethod("getObject", Object.class, cls2);
                cls.getMethod("putObject", Object.class, cls2, Object.class);
                return true;
            } catch (Throwable th) {
                zzamh.zza(th);
                return false;
            }
        }
    }

    public static final class zzc extends zzb {
        public zzc(Unsafe unsafe) {
            super(unsafe);
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final double zza(Object obj, long j4) {
            return Double.longBitsToDouble(zze(obj, j4));
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final float zzb(Object obj, long j4) {
            return Float.intBitsToFloat(zzd(obj, j4));
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final boolean zzc(Object obj, long j4) {
            return zzamh.zza ? zzamh.zzf(obj, j4) : zzamh.zzg(obj, j4);
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, boolean z4) {
            if (zzamh.zza) {
                zzamh.zza(obj, j4, z4);
            } else {
                zzamh.zzb(obj, j4, z4);
            }
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, byte b5) {
            if (!zzamh.zza) {
                zzamh.zzd(obj, j4, b5);
            } else {
                zzamh.zzc(obj, j4, b5);
            }
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, double d5) {
            zza(obj, j4, Double.doubleToLongBits(d5));
        }

        @Override // com.google.android.gms.internal.firebase-auth-api.zzamh.zzb
        public final void zza(Object obj, long j4, float f4) {
            zza(obj, j4, Float.floatToIntBits(f4));
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:8:0x002e  */
    static {
        /*
            Method dump skipped, instruction units count: 214
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.p002firebaseauthapi.zzamh.<clinit>():void");
    }

    private zzamh() {
    }

    private static int zzc(Class<?> cls) {
        if (zzh) {
            return zzf.zza.arrayIndexScale(cls);
        }
        return -1;
    }

    public static long zzd(Object obj, long j4) {
        return zzf.zze(obj, j4);
    }

    public static Object zze(Object obj, long j4) {
        return zzf.zza.getObject(obj, j4);
    }

    public static /* synthetic */ boolean zzf(Object obj, long j4) {
        return ((byte) (zzc(obj, (-4) & j4) >>> ((int) (((~j4) & 3) << 3)))) != 0;
    }

    public static /* synthetic */ boolean zzg(Object obj, long j4) {
        return ((byte) (zzc(obj, (-4) & j4) >>> ((int) ((j4 & 3) << 3)))) != 0;
    }

    public static boolean zzh(Object obj, long j4) {
        return zzf.zzc(obj, j4);
    }

    public static float zzb(Object obj, long j4) {
        return zzf.zzb(obj, j4);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static void zzd(Object obj, long j4, byte b5) {
        long j5 = (-4) & j4;
        int i4 = (((int) j4) & 3) << 3;
        zza(obj, j5, ((255 & b5) << i4) | (zzc(obj, j5) & (~(255 << i4))));
    }

    public static double zza(Object obj, long j4) {
        return zzf.zza(obj, j4);
    }

    private static int zzb(Class<?> cls) {
        if (zzh) {
            return zzf.zza.arrayBaseOffset(cls);
        }
        return -1;
    }

    public static int zzc(Object obj, long j4) {
        return zzf.zzd(obj, j4);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static Field zze() {
        Field fieldZza = zza((Class<?>) Buffer.class, "effectiveDirectAddress");
        if (fieldZza != null) {
            return fieldZza;
        }
        Field fieldZza2 = zza((Class<?>) Buffer.class, "address");
        if (fieldZza2 == null || fieldZza2.getType() != Long.TYPE) {
            return null;
        }
        return fieldZza2;
    }

    public static <T> T zza(Class<T> cls) {
        try {
            return (T) zzb.allocateInstance(cls);
        } catch (InstantiationException e) {
            throw new IllegalStateException(e);
        }
    }

    public static void zzc(Object obj, long j4, boolean z4) {
        zzf.zza(obj, j4, z4);
    }

    private static boolean zzd(Class<?> cls) {
        try {
            Class<?> cls2 = zzc;
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

    public static Unsafe zzb() {
        try {
            return (Unsafe) AccessController.doPrivileged(new zzamj());
        } catch (Throwable unused) {
            return null;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static void zzc(Object obj, long j4, byte b5) {
        long j5 = (-4) & j4;
        int iZzc = zzc(obj, j5);
        int i4 = ((~((int) j4)) & 3) << 3;
        zza(obj, j5, ((255 & b5) << i4) | (iZzc & (~(255 << i4))));
    }

    private static Field zza(Class<?> cls, String str) {
        try {
            return cls.getDeclaredField(str);
        } catch (Throwable unused) {
            return null;
        }
    }

    public static /* synthetic */ void zza(Throwable th) {
        Logger.getLogger(zzamh.class.getName()).logp(Level.WARNING, "com.google.protobuf.UnsafeUtil", "logMissingMethod", "platform method missing - proto runtime falling back to safer methods: ".concat(String.valueOf(th)));
    }

    public static /* synthetic */ void zzb(Object obj, long j4, boolean z4) {
        zzd(obj, j4, z4 ? (byte) 1 : (byte) 0);
    }

    public static boolean zzc() {
        return zzh;
    }

    public static /* synthetic */ void zza(Object obj, long j4, boolean z4) {
        zzc(obj, j4, z4 ? (byte) 1 : (byte) 0);
    }

    public static void zza(byte[] bArr, long j4, byte b5) {
        zzf.zza((Object) bArr, zzi + j4, b5);
    }

    public static void zza(Object obj, long j4, double d5) {
        zzf.zza(obj, j4, d5);
    }

    public static void zza(Object obj, long j4, float f4) {
        zzf.zza(obj, j4, f4);
    }

    public static void zza(Object obj, long j4, int i4) {
        zzf.zza(obj, j4, i4);
    }

    public static boolean zzd() {
        return zzg;
    }

    public static void zza(Object obj, long j4, long j5) {
        zzf.zza(obj, j4, j5);
    }

    public static void zza(Object obj, long j4, Object obj2) {
        zzf.zza.putObject(obj, j4, obj2);
    }
}
