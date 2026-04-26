package com.google.android.recaptcha.internal;

import android.content.Context;
import java.util.Locale;
import java.util.MissingResourceException;

/* JADX INFO: loaded from: classes.dex */
public final class zzbf {
    public static final zzbe zza = new zzbe(null);
    private static zzmo zzb;
    private final String zzc;
    private final zzac zzd;
    private final zznc zze;
    private final long zzf;

    public zzbf(zzbb zzbbVar, String str, zzac zzacVar) {
        this.zzc = str;
        this.zzd = zzacVar;
        zznc zzncVarZzi = zznf.zzi();
        this.zze = zzncVarZzi;
        this.zzf = System.currentTimeMillis();
        zzncVarZzi.zzp(zzbbVar.zza());
        zzncVarZzi.zzd(zzbbVar.zzb());
        zzncVarZzi.zzr(zzbbVar.zzc());
        if (zzbbVar.zzd() != null) {
            zzncVarZzi.zzu(zzbbVar.zzd());
        }
        zzncVarZzi.zzt(zzmg.zzc(zzmg.zzb(System.currentTimeMillis())));
    }

    /* JADX WARN: Path cross not found for [B:6:0x000b, B:10:0x002a], limit reached: 29 */
    /* JADX WARN: Removed duplicated region for block: B:16:0x0049 A[Catch: NameNotFoundException -> 0x008e, TryCatch #1 {NameNotFoundException -> 0x008e, blocks: (B:14:0x0045, B:16:0x0049, B:19:0x0067, B:20:0x007c), top: B:27:0x0045 }] */
    /* JADX WARN: Removed duplicated region for block: B:17:0x0062  */
    /*  JADX ERROR: JadxRuntimeException in pass: RegionMakerVisitor
        jadx.core.utils.exceptions.JadxRuntimeException: Can't find top splitter block for handler:B:24:0x0023
        	at jadx.core.utils.BlockUtils.getTopSplitterForHandler(BlockUtils.java:1182)
        	at jadx.core.dex.visitors.regions.maker.ExcHandlersRegionMaker.collectHandlerRegions(ExcHandlersRegionMaker.java:53)
        	at jadx.core.dex.visitors.regions.maker.ExcHandlersRegionMaker.process(ExcHandlersRegionMaker.java:38)
        	at jadx.core.dex.visitors.regions.RegionMakerVisitor.visit(RegionMakerVisitor.java:27)
        */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private static final com.google.android.recaptcha.internal.zzmo zzb(android.content.Context r7) {
        /*
            java.lang.String r0 = "unknown"
            r1 = 33
            int r2 = android.os.Build.VERSION.SDK_INT     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            java.lang.String r3 = "com.google.android.gms.version"
            r4 = -1
            if (r2 < r1) goto L2a
            android.content.pm.PackageManager r2 = r7.getPackageManager()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            java.lang.String r5 = r7.getPackageName()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            android.content.pm.PackageManager$ApplicationInfoFlags r6 = B.c.c()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            android.content.pm.ApplicationInfo r2 = B.c.a(r2, r5, r6)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            android.os.Bundle r2 = r2.metaData     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            int r2 = r2.getInt(r3, r4)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            if (r2 != r4) goto L25
        L23:
            r2 = r0
            goto L45
        L25:
            java.lang.String r2 = java.lang.String.valueOf(r2)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            goto L45
        L2a:
            android.content.pm.PackageManager r2 = r7.getPackageManager()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            java.lang.String r5 = r7.getPackageName()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            r6 = 128(0x80, float:1.8E-43)
            android.content.pm.ApplicationInfo r2 = r2.getApplicationInfo(r5, r6)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            android.os.Bundle r2 = r2.metaData     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            int r2 = r2.getInt(r3, r4)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
            if (r2 != r4) goto L41
            goto L23
        L41:
            java.lang.String r2 = java.lang.String.valueOf(r2)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L23
        L45:
            int r3 = android.os.Build.VERSION.SDK_INT     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            if (r3 < r1) goto L62
            android.content.pm.PackageManager r1 = r7.getPackageManager()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            java.lang.String r7 = r7.getPackageName()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            android.content.pm.PackageManager$PackageInfoFlags r3 = B.c.d()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            android.content.pm.PackageInfo r7 = B.c.b(r1, r7, r3)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            long r3 = A.AbstractC0005e.b(r7)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            java.lang.String r0 = java.lang.String.valueOf(r3)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            goto L8e
        L62:
            r1 = 28
            r4 = 0
            if (r3 < r1) goto L7c
            android.content.pm.PackageManager r1 = r7.getPackageManager()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            java.lang.String r7 = r7.getPackageName()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            android.content.pm.PackageInfo r7 = r1.getPackageInfo(r7, r4)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            long r3 = A.AbstractC0005e.b(r7)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            java.lang.String r0 = java.lang.String.valueOf(r3)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            goto L8e
        L7c:
            android.content.pm.PackageManager r1 = r7.getPackageManager()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            java.lang.String r7 = r7.getPackageName()     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            android.content.pm.PackageInfo r7 = r1.getPackageInfo(r7, r4)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            int r7 = r7.versionCode     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
            java.lang.String r0 = java.lang.String.valueOf(r7)     // Catch: android.content.pm.PackageManager.NameNotFoundException -> L8e
        L8e:
            com.google.android.recaptcha.internal.zzmn r7 = com.google.android.recaptcha.internal.zzmo.zzf()
            int r1 = android.os.Build.VERSION.SDK_INT
            r7.zzd(r1)
            r7.zzq(r2)
            java.lang.String r1 = "18.4.0"
            r7.zzs(r1)
            java.lang.String r1 = android.os.Build.MODEL
            r7.zzp(r1)
            java.lang.String r1 = android.os.Build.MANUFACTURER
            r7.zzr(r1)
            r7.zze(r0)
            com.google.android.recaptcha.internal.zzit r7 = r7.zzj()
            com.google.android.recaptcha.internal.zzmo r7 = (com.google.android.recaptcha.internal.zzmo) r7
            return r7
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzbf.zzb(android.content.Context):com.google.android.recaptcha.internal.zzmo");
    }

    public final zznf zza(int i4, zzmr zzmrVar, Context context) {
        String iSO3Language;
        String iSO3Country = "";
        long jCurrentTimeMillis = System.currentTimeMillis() - this.zzf;
        zznc zzncVar = this.zze;
        zzncVar.zze(jCurrentTimeMillis);
        zzncVar.zzv(i4);
        if (zzmrVar != null) {
            this.zze.zzq(zzmrVar);
        }
        if (zzb == null) {
            zzb = zzb(context);
        }
        try {
            iSO3Language = Locale.getDefault().getISO3Language();
        } catch (MissingResourceException unused) {
            iSO3Language = "";
        }
        try {
            iSO3Country = Locale.getDefault().getISO3Country();
        } catch (MissingResourceException unused2) {
        }
        zznc zzncVar2 = this.zze;
        String str = this.zzc;
        zznq zznqVarZzf = zznr.zzf();
        zznqVarZzf.zzq(str);
        zzmo zzmoVarZzb = zzb;
        if (zzmoVarZzb == null) {
            zzmoVarZzb = zzb(context);
        }
        zznqVarZzf.zzd(zzmoVarZzb);
        zznqVarZzf.zzp(iSO3Language);
        zznqVarZzf.zze(iSO3Country);
        zzncVar2.zzs((zznr) zznqVarZzf.zzj());
        return (zznf) this.zze.zzj();
    }
}
