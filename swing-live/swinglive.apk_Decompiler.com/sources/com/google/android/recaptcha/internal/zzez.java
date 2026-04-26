package com.google.android.recaptcha.internal;

import Q3.C0146s;
import Q3.E0;
import Q3.F;
import Q3.r;
import android.content.Context;
import android.webkit.WebView;
import java.util.LinkedHashMap;
import java.util.Map;
import x3.AbstractC0728h;

/* JADX INFO: loaded from: classes.dex */
public final class zzez implements zza {
    public static final zzep zza = new zzep(null);
    public r zzb;
    public zzbu zzc;
    private final WebView zzd;
    private final String zze;
    private final Context zzf;
    private final zzab zzg;
    private final zzbd zzh;
    private final zzbg zzi;
    private final zzbq zzj;
    private final Map zzk = zzfa.zza();
    private final Map zzl;
    private final Map zzm;
    private final zzfh zzn;
    private final zzeq zzo;
    private final zzbd zzp;
    private final zzt zzq;

    public zzez(WebView webView, String str, Context context, zzab zzabVar, zzbd zzbdVar, zzt zztVar, zzbg zzbgVar, zzbq zzbqVar) {
        this.zzd = webView;
        this.zze = str;
        this.zzf = context;
        this.zzg = zzabVar;
        this.zzh = zzbdVar;
        this.zzq = zztVar;
        this.zzi = zzbgVar;
        this.zzj = zzbqVar;
        LinkedHashMap linkedHashMap = new LinkedHashMap();
        this.zzl = linkedHashMap;
        this.zzm = linkedHashMap;
        this.zzn = zzfh.zzc();
        zzeq zzeqVar = new zzeq(this);
        this.zzo = zzeqVar;
        zzbd zzbdVarZzb = zzbdVar.zzb();
        zzbdVarZzb.zzc(zzbdVar.zzd());
        this.zzp = zzbdVarZzb;
        webView.getSettings().setJavaScriptEnabled(true);
        webView.addJavascriptInterface(zzeqVar, "RN");
        webView.setWebViewClient(new zzeu(this));
    }

    public static final /* synthetic */ void zzl(zzez zzezVar, zzoe zzoeVar) {
        zzezVar.zzd.clearCache(true);
        zzbb zzbbVarZza = zzezVar.zzp.zza(zzne.INIT_NETWORK);
        zzbg zzbgVar = zzezVar.zzi;
        zzbgVar.zze.put(zzbbVarZza, new zzbf(zzbbVarZza, zzbgVar.zza, new zzac()));
        F.s(zzezVar.zzq.zza(), null, new zzey(zzezVar, zzoeVar, zzbbVarZza, null), 3);
    }

    public static final /* synthetic */ void zzm(zzez zzezVar, String str) {
        zzbb zzbbVarZza = zzezVar.zzp.zza(zzne.LOAD_WEBVIEW);
        try {
            zzbg zzbgVar = zzezVar.zzi;
            zzbgVar.zze.put(zzbbVarZza, new zzbf(zzbbVarZza, zzbgVar.zza, new zzac()));
            zzezVar.zzd.loadDataWithBaseURL(zzezVar.zzg.zza(), str, "text/html", "utf-8", null);
        } catch (Exception unused) {
            zzp zzpVar = new zzp(zzn.zzc, zzl.zzag, null);
            zzezVar.zzi.zzb(zzbbVarZza, zzpVar, null);
            ((C0146s) zzezVar.zzk()).d0(zzpVar);
        }
    }

    private final zzp zzp(Exception exc, zzp zzpVar) {
        return exc instanceof E0 ? new zzp(zzn.zzc, zzl.zzj, null) : exc instanceof zzp ? (zzp) exc : zzpVar;
    }

    /* JADX WARN: Removed duplicated region for block: B:31:0x0073  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // com.google.android.recaptcha.internal.zza
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object zza(java.lang.String r5, long r6, y3.InterfaceC0762c r8) {
        /*
            r4 = this;
            boolean r0 = r8 instanceof com.google.android.recaptcha.internal.zzer
            if (r0 == 0) goto L13
            r0 = r8
            com.google.android.recaptcha.internal.zzer r0 = (com.google.android.recaptcha.internal.zzer) r0
            int r1 = r0.zzc
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.zzc = r1
            goto L18
        L13:
            com.google.android.recaptcha.internal.zzer r0 = new com.google.android.recaptcha.internal.zzer
            r0.<init>(r4, r8)
        L18:
            java.lang.Object r8 = r0.zza
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.zzc
            r3 = 1
            if (r2 == 0) goto L35
            if (r2 != r3) goto L2d
            java.lang.String r5 = r0.zze
            com.google.android.recaptcha.internal.zzez r6 = r0.zzd
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Exception -> L2b
            goto L4c
        L2b:
            r7 = move-exception
            goto L54
        L2d:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r6 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r6)
            throw r5
        L35:
            e1.AbstractC0367g.M(r8)
            com.google.android.recaptcha.internal.zzet r8 = new com.google.android.recaptcha.internal.zzet     // Catch: java.lang.Exception -> L51
            r2 = 0
            r8.<init>(r5, r4, r2)     // Catch: java.lang.Exception -> L51
            r0.zzd = r4     // Catch: java.lang.Exception -> L51
            r0.zze = r5     // Catch: java.lang.Exception -> L51
            r0.zzc = r3     // Catch: java.lang.Exception -> L51
            java.lang.Object r8 = Q3.F.C(r6, r8, r0)     // Catch: java.lang.Exception -> L51
            if (r8 != r1) goto L4b
            return r1
        L4b:
            r6 = r4
        L4c:
            com.google.android.recaptcha.internal.zzog r8 = (com.google.android.recaptcha.internal.zzog) r8     // Catch: java.lang.Exception -> L2b
            return r8
        L4f:
            r7 = r6
            goto L53
        L51:
            r6 = move-exception
            goto L4f
        L53:
            r6 = r4
        L54:
            java.lang.Class r8 = r7.getClass()
            com.google.android.recaptcha.internal.zzp r0 = new com.google.android.recaptcha.internal.zzp
            com.google.android.recaptcha.internal.zzn r1 = com.google.android.recaptcha.internal.zzn.zzc
            com.google.android.recaptcha.internal.zzl r2 = com.google.android.recaptcha.internal.zzl.zzai
            java.lang.String r8 = r8.getSimpleName()
            r0.<init>(r1, r2, r8)
            com.google.android.recaptcha.internal.zzp r7 = r6.zzp(r7, r0)
            java.util.Map r6 = r6.zzl
            java.lang.Object r5 = r6.remove(r5)
            Q3.r r5 = (Q3.r) r5
            if (r5 == 0) goto L78
            Q3.s r5 = (Q3.C0146s) r5
            r5.d0(r7)
        L78:
            w3.d r5 = e1.AbstractC0367g.h(r7)
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzez.zza(java.lang.String, long, y3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:31:0x008b  */
    /* JADX WARN: Removed duplicated region for block: B:32:0x0098  */
    /* JADX WARN: Removed duplicated region for block: B:36:0x00a7  */
    /* JADX WARN: Removed duplicated region for block: B:41:0x00bf  */
    /* JADX WARN: Removed duplicated region for block: B:45:0x00de A[LOOP:0: B:43:0x00d8->B:45:0x00de, LOOP_END] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // com.google.android.recaptcha.internal.zza
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object zzb(long r8, com.google.android.recaptcha.internal.zzoe r10, y3.InterfaceC0762c r11) {
        /*
            Method dump skipped, instruction units count: 249
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzez.zzb(long, com.google.android.recaptcha.internal.zzoe, y3.c):java.lang.Object");
    }

    public final WebView zzc() {
        return this.zzd;
    }

    public final zzbq zzf() {
        return this.zzj;
    }

    public final zzeq zzg() {
        return this.zzo;
    }

    public final r zzk() {
        r rVar = this.zzb;
        if (rVar != null) {
            return rVar;
        }
        return null;
    }

    public final zzca zzo(zzoe zzoeVar, zzag zzagVar) {
        zzcd zzcdVar = new zzcd(this.zzd, this.zzq.zzb());
        zzef zzefVar = new zzef();
        zzefVar.zzb(AbstractC0728h.j0(zzoeVar.zzK()));
        zzcl zzclVar = new zzcl(zzcdVar, zzagVar, new zzaa());
        zzeg zzegVar = new zzeg(zzefVar, new zzed());
        zzclVar.zzf(3, this.zzf);
        zzclVar.zzf(5, zzen.class.getMethod("cs", new Object[0].getClass()));
        zzclVar.zzf(6, new zzeh(this.zzf));
        zzclVar.zzf(7, new zzej());
        zzclVar.zzf(8, new zzeo(this.zzf));
        zzclVar.zzf(9, new zzek(this.zzf));
        zzclVar.zzf(10, new zzei(this.zzf));
        return new zzca(this.zzq.zzc(), zzclVar, zzegVar, zzbt.zza());
    }
}
