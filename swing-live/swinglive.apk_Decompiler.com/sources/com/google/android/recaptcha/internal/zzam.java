package com.google.android.recaptcha.internal;

import Q3.F;
import Y3.a;
import Y3.d;
import android.app.Application;
import com.google.android.gms.tasks.Task;
import java.util.UUID;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class zzam {
    private static zzaw zzb;
    public static final zzam zza = new zzam();
    private static final String zzc = UUID.randomUUID().toString();
    private static final a zzd = new d();
    private static final zzt zze = new zzt();
    private static zzg zzf = new zzg(null, 1, 0 == true ? 1 : 0);

    private zzam() {
    }

    public static final Object zzc(Application application, String str, long j4, zzbq zzbqVar, InterfaceC0762c interfaceC0762c) {
        return F.B(zze.zzb().n(), new zzah(application, str, j4, null, null), interfaceC0762c);
    }

    public static final Task zzd(Application application, String str, long j4) {
        return zzj.zza(F.d(zze.zzb(), new zzak(application, str, j4, null)));
    }

    public static final zzg zze() {
        return zzf;
    }

    public static final void zzf(zzg zzgVar) {
        zzf = zzgVar;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0019  */
    /* JADX WARN: Type inference failed for: r0v5, types: [Y3.d] */
    /* JADX WARN: Type inference failed for: r2v12 */
    /* JADX WARN: Type inference failed for: r2v16 */
    /* JADX WARN: Type inference failed for: r2v2, types: [A3.c, com.google.android.recaptcha.internal.zzai] */
    /* JADX WARN: Type inference failed for: r2v21 */
    /* JADX WARN: Type inference failed for: r2v22 */
    /* JADX WARN: Type inference failed for: r2v23 */
    /* JADX WARN: Type inference failed for: r2v3 */
    /* JADX WARN: Type inference failed for: r2v5 */
    /* JADX WARN: Type inference failed for: r2v6 */
    /* JADX WARN: Type inference failed for: r2v7 */
    /* JADX WARN: Type inference failed for: r5v10 */
    /* JADX WARN: Type inference failed for: r5v2 */
    /* JADX WARN: Type inference failed for: r5v3, types: [java.lang.Object] */
    /* JADX WARN: Type inference failed for: r5v4 */
    /* JADX WARN: Type inference failed for: r5v6 */
    /* JADX WARN: Type inference failed for: r5v8 */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object zza(android.app.Application r22, java.lang.String r23, long r24, com.google.android.recaptcha.internal.zzab r26, android.webkit.WebView r27, com.google.android.recaptcha.internal.zzbq r28, com.google.android.recaptcha.internal.zzt r29, y3.InterfaceC0762c r30) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 430
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzam.zza(android.app.Application, java.lang.String, long, com.google.android.recaptcha.internal.zzab, android.webkit.WebView, com.google.android.recaptcha.internal.zzbq, com.google.android.recaptcha.internal.zzt, y3.c):java.lang.Object");
    }
}
