package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.f;
import com.google.android.gms.internal.firebase-auth-api.zzaja.zzb;
import com.google.android.gms.internal.p002firebaseauthapi.zzaja;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzaja<MessageType extends zzaja<MessageType, BuilderType>, BuilderType extends zzb<MessageType, BuilderType>> extends zzahd<MessageType, BuilderType> {
    private static Map<Object, zzaja<?, ?>> zzc = new ConcurrentHashMap();
    private int zzd = -1;
    protected zzame zzb = zzame.zzc();

    public static class zza<T extends zzaja<T, ?>> extends zzahh<T> {
        private final T zza;

        public zza(T t4) {
            this.zza = t4;
        }
    }

    public static final class zzc implements zzaiu<zzc> {
        @Override // java.lang.Comparable
        public final /* synthetic */ int compareTo(Object obj) {
            throw new NoSuchMethodError();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaiu
        public final int zza() {
            throw new NoSuchMethodError();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaiu
        public final zzamo zzb() {
            throw new NoSuchMethodError();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaiu
        public final zzamy zzc() {
            throw new NoSuchMethodError();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaiu
        public final boolean zzd() {
            throw new NoSuchMethodError();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaiu
        public final boolean zze() {
            throw new NoSuchMethodError();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaiu
        public final zzakn zza(zzakn zzaknVar, zzakk zzakkVar) {
            throw new NoSuchMethodError();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaiu
        public final zzakt zza(zzakt zzaktVar, zzakt zzaktVar2) {
            throw new NoSuchMethodError();
        }
    }

    public static abstract class zzd<MessageType extends zzd<MessageType, BuilderType>, BuilderType> extends zzaja<MessageType, BuilderType> implements zzakm {
        protected zzais<zzc> zzc = zzais.zzb();

        public final zzais<zzc> zza() {
            if (this.zzc.zzf()) {
                this.zzc = (zzais) this.zzc.clone();
            }
            return this.zzc;
        }
    }

    public enum zze {
        public static final int zza = 1;
        public static final int zzb = 2;
        public static final int zzc = 3;
        public static final int zzd = 4;
        public static final int zze = 5;
        public static final int zzf = 6;
        public static final int zzg = 7;
        private static final /* synthetic */ int[] zzh = {1, 2, 3, 4, 5, 6, 7};

        public static int[] zza() {
            return (int[]) zzh.clone();
        }
    }

    public static class zzf<ContainingType extends zzakk, Type> extends zzaim<ContainingType, Type> {
    }

    private final int zza() {
        return zzaky.zza().zza(this).zzb(this);
    }

    private final int zzb(zzalc<?> zzalcVar) {
        return zzalcVar == null ? zzaky.zza().zza(this).zza(this) : zzalcVar.zza(this);
    }

    public static <E> zzajg<E> zzo() {
        return zzalb.zzd();
    }

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && getClass() == obj.getClass()) {
            return zzaky.zza().zza(this).zzb(this, (zzaja) obj);
        }
        return false;
    }

    public int hashCode() {
        if (zzv()) {
            return zza();
        }
        if (this.zza == 0) {
            this.zza = zza();
        }
        return this.zza;
    }

    public String toString() {
        return zzakp.zza(this, super.toString());
    }

    public abstract Object zza(int i4, Object obj, Object obj2);

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahd
    public final int zzh() {
        return this.zzd & f.API_PRIORITY_OTHER;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakk
    public final int zzk() {
        return zza((zzalc) null);
    }

    public final <MessageType extends zzaja<MessageType, BuilderType>, BuilderType extends zzb<MessageType, BuilderType>> BuilderType zzl() {
        return (BuilderType) zza(zze.zze, (Object) null, (Object) null);
    }

    public final BuilderType zzm() {
        return (BuilderType) ((zzb) zza(zze.zze, (Object) null, (Object) null)).zza(this);
    }

    public final MessageType zzn() {
        return (MessageType) zza(zze.zzd, (Object) null, (Object) null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakk
    public final /* synthetic */ zzakn zzp() {
        return (zzb) zza(zze.zze, (Object) null, (Object) null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakk
    public final /* synthetic */ zzakn zzq() {
        return ((zzb) zza(zze.zze, (Object) null, (Object) null)).zza(this);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakm
    public final /* synthetic */ zzakk zzr() {
        return (zzaja) zza(zze.zzf, (Object) null, (Object) null);
    }

    public final void zzs() {
        zzaky.zza().zza(this).zzc(this);
        zzt();
    }

    public final void zzt() {
        this.zzd &= f.API_PRIORITY_OTHER;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakm
    public final boolean zzu() {
        return zza(this, true);
    }

    public final boolean zzv() {
        return (this.zzd & Integer.MIN_VALUE) != 0;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahd
    public final int zza(zzalc zzalcVar) {
        if (zzv()) {
            int iZzb = zzb((zzalc<?>) zzalcVar);
            if (iZzb >= 0) {
                return iZzb;
            }
            throw new IllegalStateException(S.d(iZzb, "serialized size must be non-negative, was "));
        }
        if (zzh() != Integer.MAX_VALUE) {
            return zzh();
        }
        int iZzb2 = zzb((zzalc<?>) zzalcVar);
        zzb(iZzb2);
        return iZzb2;
    }

    private static <T extends zzaja<T, ?>> T zzb(T t4, zzahm zzahmVar, zzaip zzaipVar) throws zzajj {
        zzaib zzaibVarZzc = zzahmVar.zzc();
        T t5 = (T) zza(t4, zzaibVarZzc, zzaipVar);
        try {
            zzaibVarZzc.zzb(0);
            return t5;
        } catch (zzajj e) {
            throw e.zza(t5);
        }
    }

    public static abstract class zzb<MessageType extends zzaja<MessageType, BuilderType>, BuilderType extends zzb<MessageType, BuilderType>> extends zzahf<MessageType, BuilderType> {
        protected MessageType zza;
        private final MessageType zzb;

        public zzb(MessageType messagetype) {
            this.zzb = messagetype;
            if (messagetype.zzv()) {
                throw new IllegalArgumentException("Default instance must be immutable.");
            }
            this.zza = (MessageType) messagetype.zzn();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahf
        public /* synthetic */ Object clone() {
            zzb zzbVar = (zzb) this.zzb.zza(zze.zze, null, null);
            zzbVar.zza = (MessageType) zzg();
            return zzbVar;
        }

        public final BuilderType zza(MessageType messagetype) {
            if (this.zzb.equals(messagetype)) {
                return this;
            }
            if (!this.zza.zzv()) {
                zzi();
            }
            zza(this.zza, messagetype);
            return this;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahf
        /* JADX INFO: renamed from: zzc */
        public final /* synthetic */ zzahf clone() {
            return (zzb) clone();
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakn
        /* JADX INFO: renamed from: zzd, reason: merged with bridge method [inline-methods] */
        public final MessageType zzf() {
            MessageType messagetype = (MessageType) zzg();
            if (messagetype.zzu()) {
                return messagetype;
            }
            throw new zzamc(messagetype);
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakn
        /* JADX INFO: renamed from: zze, reason: merged with bridge method [inline-methods] */
        public MessageType zzg() {
            if (!this.zza.zzv()) {
                return this.zza;
            }
            this.zza.zzs();
            return this.zza;
        }

        public final void zzh() {
            if (this.zza.zzv()) {
                return;
            }
            zzi();
        }

        public void zzi() {
            MessageType messagetype = (MessageType) this.zzb.zzn();
            zza(messagetype, this.zza);
            this.zza = messagetype;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakm
        public final /* synthetic */ zzakk zzr() {
            return this.zzb;
        }

        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakm
        public final boolean zzu() {
            return zzaja.zza(this.zza, false);
        }

        private static <MessageType> void zza(MessageType messagetype, MessageType messagetype2) {
            zzaky.zza().zza(messagetype).zza(messagetype, messagetype2);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahd
    public final void zzb(int i4) {
        if (i4 >= 0) {
            this.zzd = (i4 & f.API_PRIORITY_OTHER) | (this.zzd & Integer.MIN_VALUE);
            return;
        }
        throw new IllegalStateException(S.d(i4, "serialized size must be non-negative, was "));
    }

    private static <T extends zzaja<T, ?>> T zza(T t4) throws zzajj {
        if (t4 == null || t4.zzu()) {
            return t4;
        }
        throw new zzamc(t4).zza().zza(t4);
    }

    public static <T extends zzaja<?, ?>> T zza(Class<T> cls) {
        T t4 = (T) zzc.get(cls);
        if (t4 == null) {
            try {
                Class.forName(cls.getName(), true, cls.getClassLoader());
                t4 = (T) zzc.get(cls);
            } catch (ClassNotFoundException e) {
                throw new IllegalStateException("Class initialization cannot fail.", e);
            }
        }
        if (t4 != null) {
            return t4;
        }
        T t5 = (T) ((zzaja) zzamh.zza(cls)).zza(zze.zzf, (Object) null, (Object) null);
        if (t5 != null) {
            zzc.put(cls, t5);
            return t5;
        }
        throw new IllegalStateException();
    }

    public static <T extends zzaja<T, ?>> T zza(T t4, zzahm zzahmVar, zzaip zzaipVar) {
        return (T) zza(zzb(t4, zzahmVar, zzaipVar));
    }

    public static <T extends zzaja<T, ?>> T zza(T t4, InputStream inputStream, zzaip zzaipVar) {
        zzaib zzaicVar;
        if (inputStream == null) {
            byte[] bArr = zzajc.zzb;
            zzaicVar = zzaib.zza(bArr, 0, bArr.length, false);
        } else {
            zzaicVar = new zzaic(inputStream);
        }
        return (T) zza(zza(t4, zzaicVar, zzaipVar));
    }

    public static <T extends zzaja<T, ?>> T zza(T t4, byte[] bArr, zzaip zzaipVar) {
        return (T) zza(zza(t4, bArr, 0, bArr.length, zzaipVar));
    }

    private static <T extends zzaja<T, ?>> T zza(T t4, zzaib zzaibVar, zzaip zzaipVar) throws zzajj {
        T t5 = (T) t4.zzn();
        try {
            zzalc zzalcVarZza = zzaky.zza().zza(t5);
            zzalcVarZza.zza(t5, zzaig.zza(zzaibVar), zzaipVar);
            zzalcVarZza.zzc(t5);
            return t5;
        } catch (zzajj e) {
            e = e;
            if (e.zzk()) {
                e = new zzajj(e);
            }
            throw e.zza(t5);
        } catch (zzamc e4) {
            throw e4.zza().zza(t5);
        } catch (IOException e5) {
            if (e5.getCause() instanceof zzajj) {
                throw ((zzajj) e5.getCause());
            }
            throw new zzajj(e5).zza(t5);
        } catch (RuntimeException e6) {
            if (e6.getCause() instanceof zzajj) {
                throw ((zzajj) e6.getCause());
            }
            throw e6;
        }
    }

    private static <T extends zzaja<T, ?>> T zza(T t4, byte[] bArr, int i4, int i5, zzaip zzaipVar) throws zzajj {
        T t5 = (T) t4.zzn();
        try {
            zzalc zzalcVarZza = zzaky.zza().zza(t5);
            zzalcVarZza.zza(t5, bArr, 0, i5, new zzahl(zzaipVar));
            zzalcVarZza.zzc(t5);
            return t5;
        } catch (zzajj e) {
            zzajj zzajjVar = e;
            if (zzajjVar.zzk()) {
                zzajjVar = new zzajj(zzajjVar);
            }
            throw zzajjVar.zza(t5);
        } catch (zzamc e4) {
            throw e4.zza().zza(t5);
        } catch (IOException e5) {
            if (e5.getCause() instanceof zzajj) {
                throw ((zzajj) e5.getCause());
            }
            throw new zzajj(e5).zza(t5);
        } catch (IndexOutOfBoundsException unused) {
            throw zzajj.zzi().zza(t5);
        }
    }

    public static <E> zzajg<E> zza(zzajg<E> zzajgVar) {
        int size = zzajgVar.size();
        return zzajgVar.zza(size == 0 ? 10 : size << 1);
    }

    public static Object zza(Method method, Object obj, Object... objArr) {
        try {
            return method.invoke(obj, objArr);
        } catch (IllegalAccessException e) {
            throw new RuntimeException("Couldn't use Java reflection to implement protocol message reflection.", e);
        } catch (InvocationTargetException e4) {
            Throwable cause = e4.getCause();
            if (!(cause instanceof RuntimeException)) {
                if (cause instanceof Error) {
                    throw ((Error) cause);
                }
                throw new RuntimeException("Unexpected exception thrown by generated accessor method.", cause);
            }
            throw ((RuntimeException) cause);
        }
    }

    public static Object zza(zzakk zzakkVar, String str, Object[] objArr) {
        return new zzala(zzakkVar, str, objArr);
    }

    public static <T extends zzaja<?, ?>> void zza(Class<T> cls, T t4) {
        t4.zzt();
        zzc.put(cls, t4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakk
    public final void zza(zzaii zzaiiVar) {
        zzaky.zza().zza(this).zza(this, zzaik.zza(zzaiiVar));
    }

    public static final <T extends zzaja<T, ?>> boolean zza(T t4, boolean z4) {
        byte bByteValue = ((Byte) t4.zza(zze.zza, null, null)).byteValue();
        if (bByteValue == 1) {
            return true;
        }
        if (bByteValue == 0) {
            return false;
        }
        boolean zZzd = zzaky.zza().zza(t4).zzd(t4);
        if (z4) {
            t4.zza(zze.zzb, zZzd ? t4 : null, null);
        }
        return zZzd;
    }
}
