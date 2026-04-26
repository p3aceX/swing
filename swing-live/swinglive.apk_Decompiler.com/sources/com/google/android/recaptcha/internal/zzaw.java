package com.google.android.recaptcha.internal;

import J3.i;
import P3.e;
import Q3.F;
import android.app.Application;
import com.google.android.gms.tasks.Task;
import com.google.android.recaptcha.RecaptchaAction;
import com.google.android.recaptcha.RecaptchaClient;
import com.google.android.recaptcha.RecaptchaTasksClient;
import java.util.LinkedHashMap;
import java.util.List;
import x3.AbstractC0730j;
import x3.s;

/* JADX INFO: loaded from: classes.dex */
public final class zzaw implements RecaptchaClient, RecaptchaTasksClient {
    public static final zzan zza = new zzan(null);
    private static final e zzb = new e("^[a-zA-Z0-9/_]{0,100}$");
    private final Application zzc;
    private final zzg zzd;
    private final String zze;
    private final zzab zzf;
    private final zzoe zzg;
    private final zzbd zzh;
    private final zzbg zzi;
    private final zzq zzj;
    private final zzbs zzk;
    private final zzt zzl;

    public zzaw(Application application, zzg zzgVar, String str, zzt zztVar, zzab zzabVar, zzoe zzoeVar, zzbd zzbdVar, zzbg zzbgVar, zzq zzqVar, zzbs zzbsVar) {
        this.zzc = application;
        this.zzd = zzgVar;
        this.zze = str;
        this.zzl = zztVar;
        this.zzf = zzabVar;
        this.zzg = zzoeVar;
        this.zzh = zzbdVar;
        this.zzi = zzbgVar;
        this.zzj = zzqVar;
        this.zzk = zzbsVar;
    }

    public static final void zzi(zzaw zzawVar, long j4, RecaptchaAction recaptchaAction, zzbd zzbdVar) throws zzp {
        zzbb zzbbVarZza = zzbdVar.zza(zzne.EXECUTE_NATIVE);
        zzbg zzbgVar = zzawVar.zzi;
        zzbgVar.zze.put(zzbbVarZza, new zzbf(zzbbVarZza, zzbgVar.zza, new zzac()));
        e eVar = zzb;
        String action = recaptchaAction.getAction();
        eVar.getClass();
        i.e(action, "input");
        zzp zzpVar = !eVar.f1505a.matcher(action).matches() ? new zzp(zzn.zzi, zzl.zzq, null) : null;
        if (j4 < 5000) {
            zzpVar = new zzp(zzn.zzc, zzl.zzT, null);
        }
        if (zzpVar == null) {
            zzawVar.zzi.zza(zzbbVarZza);
        } else {
            zzawVar.zzi.zzb(zzbbVarZza, zzpVar, null);
            throw zzpVar;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* JADX WARN: Removed duplicated region for block: B:29:0x0066  */
    /* JADX WARN: Removed duplicated region for block: B:30:0x0069  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object zzj(long r6, java.lang.String r8, com.google.android.recaptcha.internal.zzbd r9, y3.InterfaceC0762c r10) throws com.google.android.recaptcha.internal.zzp {
        /*
            r5 = this;
            boolean r0 = r10 instanceof com.google.android.recaptcha.internal.zzao
            if (r0 == 0) goto L13
            r0 = r10
            com.google.android.recaptcha.internal.zzao r0 = (com.google.android.recaptcha.internal.zzao) r0
            int r1 = r0.zzc
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.zzc = r1
            goto L18
        L13:
            com.google.android.recaptcha.internal.zzao r0 = new com.google.android.recaptcha.internal.zzao
            r0.<init>(r5, r10)
        L18:
            java.lang.Object r10 = r0.zza
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.zzc
            r3 = 1
            r4 = 0
            if (r2 == 0) goto L36
            if (r2 != r3) goto L2e
            com.google.android.recaptcha.internal.zzbb r6 = r0.zze
            com.google.android.recaptcha.internal.zzaw r7 = r0.zzd
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Exception -> L2c
            goto L55
        L2c:
            r8 = move-exception
            goto L62
        L2e:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L36:
            e1.AbstractC0367g.M(r10)
            com.google.android.recaptcha.internal.zzne r10 = com.google.android.recaptcha.internal.zzne.COLLECT_SIGNALS
            com.google.android.recaptcha.internal.zzbb r9 = r9.zza(r10)
            com.google.android.recaptcha.internal.zzbg r10 = r5.zzi
            r2 = 2
            com.google.android.recaptcha.internal.zzbg.zzc(r10, r9, r4, r2, r4)
            com.google.android.recaptcha.internal.zzg r10 = r5.zzd     // Catch: java.lang.Exception -> L5e
            r0.zzd = r5     // Catch: java.lang.Exception -> L5e
            r0.zze = r9     // Catch: java.lang.Exception -> L5e
            r0.zzc = r3     // Catch: java.lang.Exception -> L5e
            java.lang.Object r10 = r10.zza(r8, r6, r0)     // Catch: java.lang.Exception -> L5e
            if (r10 == r1) goto L5d
            r7 = r5
            r6 = r9
        L55:
            com.google.android.recaptcha.internal.zzog r10 = (com.google.android.recaptcha.internal.zzog) r10     // Catch: java.lang.Exception -> L2c
            com.google.android.recaptcha.internal.zzbg r8 = r7.zzi     // Catch: java.lang.Exception -> L2c
            r8.zza(r6)     // Catch: java.lang.Exception -> L2c
            return r10
        L5d:
            return r1
        L5e:
            r6 = move-exception
            r8 = r6
            r7 = r5
            r6 = r9
        L62:
            boolean r9 = r8 instanceof com.google.android.recaptcha.internal.zzp
            if (r9 == 0) goto L69
            com.google.android.recaptcha.internal.zzp r8 = (com.google.android.recaptcha.internal.zzp) r8
            goto L72
        L69:
            com.google.android.recaptcha.internal.zzp r8 = new com.google.android.recaptcha.internal.zzp
            com.google.android.recaptcha.internal.zzn r9 = com.google.android.recaptcha.internal.zzn.zzc
            com.google.android.recaptcha.internal.zzl r10 = com.google.android.recaptcha.internal.zzl.zzan
            r8.<init>(r9, r10, r4)
        L72:
            com.google.android.recaptcha.internal.zzbg r7 = r7.zzi
            r7.zzb(r6, r8, r4)
            throw r8
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzaw.zzj(long, java.lang.String, com.google.android.recaptcha.internal.zzbd, y3.c):java.lang.Object");
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* JADX WARN: Removed duplicated region for block: B:30:0x007e  */
    /* JADX WARN: Removed duplicated region for block: B:31:0x0081  */
    /* JADX WARN: Removed duplicated region for block: B:8:0x0016  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object zzk(com.google.android.recaptcha.RecaptchaAction r13, long r14, y3.InterfaceC0762c r16) {
        /*
            r12 = this;
            r0 = r16
            boolean r2 = r0 instanceof com.google.android.recaptcha.internal.zzas
            if (r2 == 0) goto L16
            r2 = r0
            com.google.android.recaptcha.internal.zzas r2 = (com.google.android.recaptcha.internal.zzas) r2
            int r3 = r2.zzc
            r4 = -2147483648(0xffffffff80000000, float:-0.0)
            r5 = r3 & r4
            if (r5 == 0) goto L16
            int r3 = r3 - r4
            r2.zzc = r3
        L14:
            r8 = r2
            goto L1c
        L16:
            com.google.android.recaptcha.internal.zzas r2 = new com.google.android.recaptcha.internal.zzas
            r2.<init>(r12, r0)
            goto L14
        L1c:
            java.lang.Object r0 = r8.zza
            z3.a r9 = z3.EnumC0789a.f6999a
            int r2 = r8.zzc
            r10 = 1
            r11 = 0
            if (r2 == 0) goto L3a
            if (r2 != r10) goto L32
            com.google.android.recaptcha.internal.zzbd r2 = r8.zze
            com.google.android.recaptcha.internal.zzaw r3 = r8.zzd
            e1.AbstractC0367g.M(r0)     // Catch: java.lang.Exception -> L30
            goto L71
        L30:
            r0 = move-exception
            goto L7a
        L32:
            java.lang.IllegalStateException r0 = new java.lang.IllegalStateException
            java.lang.String r2 = "call to 'resume' before 'invoke' with coroutine"
            r0.<init>(r2)
            throw r0
        L3a:
            e1.AbstractC0367g.M(r0)
            java.util.UUID r0 = java.util.UUID.randomUUID()
            java.lang.String r6 = r0.toString()
            com.google.android.recaptcha.internal.zzbd r0 = r12.zzh
            com.google.android.recaptcha.internal.zzbd r5 = r0.zzb()
            r5.zzc(r6)
            com.google.android.recaptcha.internal.zzbg r0 = r12.zzi
            com.google.android.recaptcha.internal.zzne r2 = com.google.android.recaptcha.internal.zzne.EXECUTE_TOTAL
            com.google.android.recaptcha.internal.zzbb r2 = r5.zza(r2)
            r3 = 2
            com.google.android.recaptcha.internal.zzbg.zzc(r0, r2, r11, r3, r11)
            com.google.android.recaptcha.internal.zzat r0 = new com.google.android.recaptcha.internal.zzat     // Catch: java.lang.Exception -> L77
            r7 = 0
            r1 = r12
            r4 = r13
            r2 = r14
            r0.<init>(r1, r2, r4, r5, r6, r7)     // Catch: java.lang.Exception -> L77
            r8.zzd = r12     // Catch: java.lang.Exception -> L77
            r8.zze = r5     // Catch: java.lang.Exception -> L77
            r8.zzc = r10     // Catch: java.lang.Exception -> L77
            java.lang.Object r0 = Q3.F.C(r14, r0, r8)     // Catch: java.lang.Exception -> L77
            if (r0 == r9) goto L76
            r3 = r12
            r2 = r5
        L71:
            w3.e r0 = (w3.e) r0     // Catch: java.lang.Exception -> L30
            java.lang.Object r0 = r0.f6721a     // Catch: java.lang.Exception -> L30
            return r0
        L76:
            return r9
        L77:
            r0 = move-exception
            r3 = r12
            r2 = r5
        L7a:
            boolean r4 = r0 instanceof com.google.android.recaptcha.internal.zzp
            if (r4 == 0) goto L81
            com.google.android.recaptcha.internal.zzp r0 = (com.google.android.recaptcha.internal.zzp) r0
            goto L93
        L81:
            java.lang.Class r0 = r0.getClass()
            com.google.android.recaptcha.internal.zzp r4 = new com.google.android.recaptcha.internal.zzp
            com.google.android.recaptcha.internal.zzn r5 = com.google.android.recaptcha.internal.zzn.zzc
            com.google.android.recaptcha.internal.zzl r6 = com.google.android.recaptcha.internal.zzl.zzaj
            java.lang.String r0 = r0.getSimpleName()
            r4.<init>(r5, r6, r0)
            r0 = r4
        L93:
            com.google.android.recaptcha.internal.zzbg r3 = r3.zzi
            com.google.android.recaptcha.internal.zzne r4 = com.google.android.recaptcha.internal.zzne.EXECUTE_TOTAL
            com.google.android.recaptcha.internal.zzbb r2 = r2.zza(r4)
            r3.zzb(r2, r0, r11)
            com.google.android.recaptcha.RecaptchaException r0 = r0.zzc()
            w3.d r0 = e1.AbstractC0367g.h(r0)
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzaw.zzk(com.google.android.recaptcha.RecaptchaAction, long, y3.c):java.lang.Object");
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zzl(zzol zzolVar, zzbd zzbdVar) throws zzp {
        zzbb zzbbVarZza = zzbdVar.zza(zzne.POST_EXECUTE);
        zzbg zzbgVar = this.zzi;
        zzbgVar.zze.put(zzbbVarZza, new zzbf(zzbbVarZza, zzbgVar.zza, new zzac()));
        try {
            List<zzon> listZzj = zzolVar.zzj();
            int iC0 = s.c0(AbstractC0730j.V(listZzj));
            if (iC0 < 16) {
                iC0 = 16;
            }
            LinkedHashMap linkedHashMap = new LinkedHashMap(iC0);
            for (zzon zzonVar : listZzj) {
                linkedHashMap.put(zzonVar.zzg(), zzonVar.zzi());
            }
            this.zzj.zzb(linkedHashMap);
            this.zzi.zza(zzbbVarZza);
        } catch (Exception e) {
            zzp zzpVar = e instanceof zzp ? (zzp) e : new zzp(zzn.zzc, zzl.zzan, null);
            this.zzi.zzb(zzbbVarZza, zzpVar, null);
            throw zzpVar;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // com.google.android.recaptcha.RecaptchaClient
    /* JADX INFO: renamed from: execute-0E7RQCE */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object mo2execute0E7RQCE(com.google.android.recaptcha.RecaptchaAction r11, long r12, y3.InterfaceC0762c r14) throws java.lang.Throwable {
        /*
            r10 = this;
            boolean r0 = r14 instanceof com.google.android.recaptcha.internal.zzap
            if (r0 == 0) goto L13
            r0 = r14
            com.google.android.recaptcha.internal.zzap r0 = (com.google.android.recaptcha.internal.zzap) r0
            int r1 = r0.zzc
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.zzc = r1
            goto L18
        L13:
            com.google.android.recaptcha.internal.zzap r0 = new com.google.android.recaptcha.internal.zzap
            r0.<init>(r10, r14)
        L18:
            java.lang.Object r14 = r0.zza
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.zzc
            r3 = 1
            if (r2 == 0) goto L2f
            if (r2 != r3) goto L27
            e1.AbstractC0367g.M(r14)
            goto L4e
        L27:
            java.lang.IllegalStateException r11 = new java.lang.IllegalStateException
            java.lang.String r12 = "call to 'resume' before 'invoke' with coroutine"
            r11.<init>(r12)
            throw r11
        L2f:
            e1.AbstractC0367g.M(r14)
            com.google.android.recaptcha.internal.zzt r14 = r10.zzl
            Q3.D r14 = r14.zzb()
            y3.h r14 = r14.n()
            com.google.android.recaptcha.internal.zzaq r4 = new com.google.android.recaptcha.internal.zzaq
            r9 = 0
            r5 = r10
            r6 = r11
            r7 = r12
            r4.<init>(r5, r6, r7, r9)
            r0.zzc = r3
            java.lang.Object r14 = Q3.F.B(r14, r4, r0)
            if (r14 != r1) goto L4e
            return r1
        L4e:
            w3.e r14 = (w3.e) r14
            java.lang.Object r11 = r14.f6721a
            return r11
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzaw.mo2execute0E7RQCE(com.google.android.recaptcha.RecaptchaAction, long, y3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // com.google.android.recaptcha.RecaptchaClient
    /* JADX INFO: renamed from: execute-gIAlu-s */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object mo3executegIAlus(com.google.android.recaptcha.RecaptchaAction r5, y3.InterfaceC0762c r6) throws java.lang.Throwable {
        /*
            r4 = this;
            boolean r0 = r6 instanceof com.google.android.recaptcha.internal.zzar
            if (r0 == 0) goto L13
            r0 = r6
            com.google.android.recaptcha.internal.zzar r0 = (com.google.android.recaptcha.internal.zzar) r0
            int r1 = r0.zzc
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.zzc = r1
            goto L18
        L13:
            com.google.android.recaptcha.internal.zzar r0 = new com.google.android.recaptcha.internal.zzar
            r0.<init>(r4, r6)
        L18:
            java.lang.Object r6 = r0.zza
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.zzc
            r3 = 1
            if (r2 == 0) goto L33
            if (r2 != r3) goto L2b
            e1.AbstractC0367g.M(r6)
            w3.e r6 = (w3.e) r6
            java.lang.Object r5 = r6.f6721a
            return r5
        L2b:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r6 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r6)
            throw r5
        L33:
            e1.AbstractC0367g.M(r6)
            r0.zzc = r3
            r2 = 10000(0x2710, double:4.9407E-320)
            java.lang.Object r5 = r4.mo2execute0E7RQCE(r5, r2, r0)
            if (r5 != r1) goto L41
            return r1
        L41:
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzaw.mo3executegIAlus(com.google.android.recaptcha.RecaptchaAction, y3.c):java.lang.Object");
    }

    @Override // com.google.android.recaptcha.RecaptchaTasksClient
    public final Task<String> executeTask(RecaptchaAction recaptchaAction) {
        return zzj.zza(F.d(this.zzl.zzb(), new zzau(this, recaptchaAction, 10000L, null)));
    }

    public final String zzg() {
        return this.zze;
    }

    @Override // com.google.android.recaptcha.RecaptchaTasksClient
    public final Task<String> executeTask(RecaptchaAction recaptchaAction, long j4) {
        return zzj.zza(F.d(this.zzl.zzb(), new zzau(this, recaptchaAction, j4, null)));
    }
}
