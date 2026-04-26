package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzakq<T> implements zzalc<T> {
    private final zzakk zza;
    private final zzamb<?, ?> zzb;
    private final boolean zzc;
    private final zzair<?> zzd;

    private zzakq(zzamb<?, ?> zzambVar, zzair<?> zzairVar, zzakk zzakkVar) {
        this.zzb = zzambVar;
        this.zzc = zzairVar.zza(zzakkVar);
        this.zzd = zzairVar;
        this.zza = zzakkVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final int zza(T t4) {
        zzamb<?, ?> zzambVar = this.zzb;
        int iZzb = zzambVar.zzb(zzambVar.zzd(t4));
        return this.zzc ? iZzb + this.zzd.zza(t4).zza() : iZzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final int zzb(T t4) {
        int iHashCode = this.zzb.zzd(t4).hashCode();
        return this.zzc ? (iHashCode * 53) + this.zzd.zza(t4).hashCode() : iHashCode;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final void zzc(T t4) {
        this.zzb.zzf(t4);
        this.zzd.zzc(t4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final boolean zzd(T t4) {
        return this.zzd.zza(t4).zzg();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final boolean zzb(T t4, T t5) {
        if (!this.zzb.zzd(t4).equals(this.zzb.zzd(t5))) {
            return false;
        }
        if (this.zzc) {
            return this.zzd.zza(t4).equals(this.zzd.zza(t5));
        }
        return true;
    }

    public static <T> zzakq<T> zza(zzamb<?, ?> zzambVar, zzair<?> zzairVar, zzakk zzakkVar) {
        return new zzakq<>(zzambVar, zzairVar, zzakkVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final T zza() {
        zzakk zzakkVar = this.zza;
        if (zzakkVar instanceof zzaja) {
            return (T) ((zzaja) zzakkVar).zzn();
        }
        return (T) zzakkVar.zzp().zzg();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final void zza(T t4, T t5) {
        zzale.zza(this.zzb, t4, t5);
        if (this.zzc) {
            zzale.zza(this.zzd, t4, t5);
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:50:0x0088 A[SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:54:? A[LOOP:0: B:46:0x000c->B:54:?, LOOP_END, SYNTHETIC] */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void zza(T r11, com.google.android.gms.internal.p002firebaseauthapi.zzald r12, com.google.android.gms.internal.p002firebaseauthapi.zzaip r13) {
        /*
            r10 = this;
            com.google.android.gms.internal.firebase-auth-api.zzamb<?, ?> r0 = r10.zzb
            com.google.android.gms.internal.firebase-auth-api.zzair<?> r1 = r10.zzd
            java.lang.Object r2 = r0.zzc(r11)
            com.google.android.gms.internal.firebase-auth-api.zzais r3 = r1.zzb(r11)
        Lc:
            int r4 = r12.zzc()     // Catch: java.lang.Throwable -> L34
            r5 = 2147483647(0x7fffffff, float:NaN)
            if (r4 != r5) goto L19
            r0.zzb(r11, r2)
            return
        L19:
            int r4 = r12.zzd()     // Catch: java.lang.Throwable -> L34
            r6 = 11
            if (r4 == r6) goto L40
            r5 = r4 & 7
            r6 = 2
            if (r5 != r6) goto L3b
            com.google.android.gms.internal.firebase-auth-api.zzakk r5 = r10.zza     // Catch: java.lang.Throwable -> L34
            int r4 = r4 >>> 3
            java.lang.Object r4 = r1.zza(r13, r5, r4)     // Catch: java.lang.Throwable -> L34
            if (r4 == 0) goto L36
            r1.zza(r12, r4, r13, r3)     // Catch: java.lang.Throwable -> L34
            goto L85
        L34:
            r12 = move-exception
            goto L91
        L36:
            boolean r4 = r0.zza(r2, r12)     // Catch: java.lang.Throwable -> L34
            goto L86
        L3b:
            boolean r4 = r12.zzt()     // Catch: java.lang.Throwable -> L34
            goto L86
        L40:
            r4 = 0
            r6 = 0
            r7 = r6
            r6 = r4
        L44:
            int r8 = r12.zzc()     // Catch: java.lang.Throwable -> L34
            if (r8 == r5) goto L72
            int r8 = r12.zzd()     // Catch: java.lang.Throwable -> L34
            r9 = 16
            if (r8 != r9) goto L5d
            int r7 = r12.zzj()     // Catch: java.lang.Throwable -> L34
            com.google.android.gms.internal.firebase-auth-api.zzakk r4 = r10.zza     // Catch: java.lang.Throwable -> L34
            java.lang.Object r4 = r1.zza(r13, r4, r7)     // Catch: java.lang.Throwable -> L34
            goto L44
        L5d:
            r9 = 26
            if (r8 != r9) goto L6c
            if (r4 == 0) goto L67
            r1.zza(r12, r4, r13, r3)     // Catch: java.lang.Throwable -> L34
            goto L44
        L67:
            com.google.android.gms.internal.firebase-auth-api.zzahm r6 = r12.zzp()     // Catch: java.lang.Throwable -> L34
            goto L44
        L6c:
            boolean r8 = r12.zzt()     // Catch: java.lang.Throwable -> L34
            if (r8 != 0) goto L44
        L72:
            int r5 = r12.zzd()     // Catch: java.lang.Throwable -> L34
            r8 = 12
            if (r5 != r8) goto L8c
            if (r6 == 0) goto L85
            if (r4 == 0) goto L82
            r1.zza(r6, r4, r13, r3)     // Catch: java.lang.Throwable -> L34
            goto L85
        L82:
            r0.zza(r2, r7, r6)     // Catch: java.lang.Throwable -> L34
        L85:
            r4 = 1
        L86:
            if (r4 != 0) goto Lc
            r0.zzb(r11, r2)
            return
        L8c:
            com.google.android.gms.internal.firebase-auth-api.zzajj r12 = com.google.android.gms.internal.p002firebaseauthapi.zzajj.zzb()     // Catch: java.lang.Throwable -> L34
            throw r12     // Catch: java.lang.Throwable -> L34
        L91:
            r0.zzb(r11, r2)
            throw r12
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.p002firebaseauthapi.zzakq.zza(java.lang.Object, com.google.android.gms.internal.firebase-auth-api.zzald, com.google.android.gms.internal.firebase-auth-api.zzaip):void");
    }

    /* JADX WARN: Code restructure failed: missing block: B:35:0x00a1, code lost:
    
        if (r12 == null) goto L37;
     */
    /* JADX WARN: Code restructure failed: missing block: B:36:0x00a3, code lost:
    
        r6.zza((r11 << 3) | 2, r12);
     */
    /* JADX WARN: Code restructure failed: missing block: B:37:0x00a9, code lost:
    
        r12 = r13;
        r11 = r3;
        r13 = r5;
        r14 = r7;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:33:0x009b  */
    /* JADX WARN: Removed duplicated region for block: B:58:0x00a1 A[EDGE_INSN: B:58:0x00a1->B:35:0x00a1 BREAK  A[LOOP:1: B:18:0x0059->B:63:0x0059], SYNTHETIC] */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void zza(T r10, byte[] r11, int r12, int r13, com.google.android.gms.internal.p002firebaseauthapi.zzahl r14) throws com.google.android.gms.internal.p002firebaseauthapi.zzajj {
        /*
            r9 = this;
            r0 = r10
            com.google.android.gms.internal.firebase-auth-api.zzaja r0 = (com.google.android.gms.internal.p002firebaseauthapi.zzaja) r0
            com.google.android.gms.internal.firebase-auth-api.zzame r1 = r0.zzb
            com.google.android.gms.internal.firebase-auth-api.zzame r2 = com.google.android.gms.internal.p002firebaseauthapi.zzame.zzc()
            if (r1 != r2) goto L11
            com.google.android.gms.internal.firebase-auth-api.zzame r1 = com.google.android.gms.internal.p002firebaseauthapi.zzame.zzd()
            r0.zzb = r1
        L11:
            r6 = r1
            com.google.android.gms.internal.firebase-auth-api.zzaja$zzd r10 = (com.google.android.gms.internal.firebase-auth-api.zzaja.zzd) r10
            r10.zza()
            r10 = 0
            r0 = r10
        L19:
            if (r12 >= r13) goto Laf
            int r4 = com.google.android.gms.internal.p002firebaseauthapi.zzahi.zzc(r11, r12, r14)
            int r2 = r14.zza
            r12 = 11
            r1 = 2
            if (r2 == r12) goto L54
            r12 = r2 & 7
            if (r12 != r1) goto L4c
            com.google.android.gms.internal.firebase-auth-api.zzair<?> r12 = r9.zzd
            com.google.android.gms.internal.firebase-auth-api.zzaip r0 = r14.zzd
            com.google.android.gms.internal.firebase-auth-api.zzakk r1 = r9.zza
            int r3 = r2 >>> 3
            java.lang.Object r12 = r12.zza(r0, r1, r3)
            r0 = r12
            com.google.android.gms.internal.firebase-auth-api.zzaja$zzf r0 = (com.google.android.gms.internal.firebase-auth-api.zzaja.zzf) r0
            if (r0 != 0) goto L43
            r3 = r11
            r5 = r13
            r7 = r14
            int r12 = com.google.android.gms.internal.p002firebaseauthapi.zzahi.zza(r2, r3, r4, r5, r6, r7)
            goto L19
        L43:
            com.google.android.gms.internal.p002firebaseauthapi.zzaky.zza()
            java.lang.NoSuchMethodError r10 = new java.lang.NoSuchMethodError
            r10.<init>()
            throw r10
        L4c:
            r3 = r11
            r5 = r13
            r7 = r14
            int r12 = com.google.android.gms.internal.p002firebaseauthapi.zzahi.zza(r2, r3, r4, r5, r7)
            goto L19
        L54:
            r3 = r11
            r5 = r13
            r7 = r14
            r11 = 0
            r12 = r10
        L59:
            if (r4 >= r5) goto La0
            int r13 = com.google.android.gms.internal.p002firebaseauthapi.zzahi.zzc(r3, r4, r7)
            int r14 = r7.zza
            int r2 = r14 >>> 3
            r4 = r14 & 7
            if (r2 == r1) goto L81
            r8 = 3
            if (r2 == r8) goto L6b
            goto L97
        L6b:
            if (r0 != 0) goto L78
            if (r4 != r1) goto L97
            int r4 = com.google.android.gms.internal.p002firebaseauthapi.zzahi.zza(r3, r13, r7)
            java.lang.Object r12 = r7.zzc
            com.google.android.gms.internal.firebase-auth-api.zzahm r12 = (com.google.android.gms.internal.p002firebaseauthapi.zzahm) r12
            goto L59
        L78:
            com.google.android.gms.internal.p002firebaseauthapi.zzaky.zza()
            java.lang.NoSuchMethodError r10 = new java.lang.NoSuchMethodError
            r10.<init>()
            throw r10
        L81:
            if (r4 != 0) goto L97
            int r4 = com.google.android.gms.internal.p002firebaseauthapi.zzahi.zzc(r3, r13, r7)
            int r11 = r7.zza
            com.google.android.gms.internal.firebase-auth-api.zzair<?> r13 = r9.zzd
            com.google.android.gms.internal.firebase-auth-api.zzaip r14 = r7.zzd
            com.google.android.gms.internal.firebase-auth-api.zzakk r0 = r9.zza
            java.lang.Object r13 = r13.zza(r14, r0, r11)
            r0 = r13
            com.google.android.gms.internal.firebase-auth-api.zzaja$zzf r0 = (com.google.android.gms.internal.firebase-auth-api.zzaja.zzf) r0
            goto L59
        L97:
            r2 = 12
            if (r14 == r2) goto La1
            int r4 = com.google.android.gms.internal.p002firebaseauthapi.zzahi.zza(r14, r3, r13, r5, r7)
            goto L59
        La0:
            r13 = r4
        La1:
            if (r12 == 0) goto La9
            int r11 = r11 << 3
            r11 = r11 | r1
            r6.zza(r11, r12)
        La9:
            r12 = r13
            r11 = r3
            r13 = r5
            r14 = r7
            goto L19
        Laf:
            r5 = r13
            if (r12 != r5) goto Lb3
            return
        Lb3:
            com.google.android.gms.internal.firebase-auth-api.zzajj r10 = com.google.android.gms.internal.p002firebaseauthapi.zzajj.zzg()
            throw r10
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.p002firebaseauthapi.zzakq.zza(java.lang.Object, byte[], int, int, com.google.android.gms.internal.firebase-auth-api.zzahl):void");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalc
    public final void zza(T t4, zzanb zzanbVar) {
        Iterator itZzd = this.zzd.zza(t4).zzd();
        while (itZzd.hasNext()) {
            Map.Entry entry = (Map.Entry) itZzd.next();
            zzaiu zzaiuVar = (zzaiu) entry.getKey();
            if (zzaiuVar.zzc() == zzamy.MESSAGE && !zzaiuVar.zze() && !zzaiuVar.zzd()) {
                if (entry instanceof zzajn) {
                    zzanbVar.zza(zzaiuVar.zza(), (Object) ((zzajn) entry).zza().zzc());
                } else {
                    zzanbVar.zza(zzaiuVar.zza(), entry.getValue());
                }
            } else {
                throw new IllegalStateException("Found invalid MessageSet item.");
            }
        }
        zzamb<?, ?> zzambVar = this.zzb;
        zzambVar.zza(zzambVar.zzd(t4), zzanbVar);
    }
}
