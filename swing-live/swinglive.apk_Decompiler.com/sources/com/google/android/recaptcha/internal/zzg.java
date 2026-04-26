package com.google.android.recaptcha.internal;

import J3.f;
import Q3.F;
import java.util.ArrayList;
import java.util.List;
import x3.p;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class zzg {
    private final List zza;

    /* JADX WARN: Multi-variable type inference failed */
    public zzg() {
        this(null, 1, 0 == true ? 1 : 0);
    }

    public final Object zza(String str, long j4, InterfaceC0762c interfaceC0762c) {
        return F.g(new zzc(this, str, j4, null), interfaceC0762c);
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object zzb(long r11, com.google.android.recaptcha.internal.zzoe r13, y3.InterfaceC0762c r14) {
        /*
            r10 = this;
            boolean r0 = r14 instanceof com.google.android.recaptcha.internal.zzd
            if (r0 == 0) goto L13
            r0 = r14
            com.google.android.recaptcha.internal.zzd r0 = (com.google.android.recaptcha.internal.zzd) r0
            int r1 = r0.zzc
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.zzc = r1
            goto L18
        L13:
            com.google.android.recaptcha.internal.zzd r0 = new com.google.android.recaptcha.internal.zzd
            r0.<init>(r10, r14)
        L18:
            java.lang.Object r14 = r0.zza
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.zzc
            r3 = 1
            if (r2 == 0) goto L2f
            if (r2 != r3) goto L27
            e1.AbstractC0367g.M(r14)
            goto L44
        L27:
            java.lang.IllegalStateException r11 = new java.lang.IllegalStateException
            java.lang.String r12 = "call to 'resume' before 'invoke' with coroutine"
            r11.<init>(r12)
            throw r11
        L2f:
            e1.AbstractC0367g.M(r14)
            com.google.android.recaptcha.internal.zzf r4 = new com.google.android.recaptcha.internal.zzf
            r9 = 0
            r5 = r10
            r6 = r11
            r8 = r13
            r4.<init>(r5, r6, r8, r9)
            r0.zzc = r3
            java.lang.Object r14 = Q3.F.g(r4, r0)
            if (r14 != r1) goto L44
            return r1
        L44:
            w3.e r14 = (w3.e) r14
            java.lang.Object r11 = r14.f6721a
            return r11
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzg.zzb(long, com.google.android.recaptcha.internal.zzoe, y3.c):java.lang.Object");
    }

    public final List zzc() {
        return this.zza;
    }

    public final void zzd(zza zzaVar) {
        this.zza.add(zzaVar);
    }

    public /* synthetic */ zzg(List list, int i4, f fVar) {
        p pVar = p.f6784a;
        ArrayList arrayList = new ArrayList();
        this.zza = arrayList;
        arrayList.addAll(pVar);
    }
}
