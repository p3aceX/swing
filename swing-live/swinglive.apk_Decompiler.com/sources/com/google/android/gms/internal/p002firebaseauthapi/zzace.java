package com.google.android.gms.internal.p002firebaseauthapi;

import C0.a;
import android.content.Context;
import com.google.android.gms.common.internal.F;
import g1.f;
import j1.C0451A;
import j1.o;
import j1.q;
import java.util.concurrent.ScheduledExecutorService;

/* JADX INFO: loaded from: classes.dex */
public final class zzace {
    private static final a zza = new a("FirebaseAuth", "FirebaseAuthFallback:");
    private final zzyl zzb;
    private final zzadt zzc;

    public zzace(f fVar, ScheduledExecutorService scheduledExecutorService) {
        F.g(fVar);
        fVar.a();
        Context context = fVar.f4307a;
        F.g(context);
        this.zzb = new zzyl(new zzacs(fVar, zzact.zza()));
        this.zzc = new zzadt(context, scheduledExecutorService);
    }

    public final void zza(String str, String str2, zzacc zzaccVar) {
        F.d(str);
        F.g(zzaccVar);
        this.zzb.zza(str, str2, new zzacf(zzaccVar, zza));
    }

    public final void zzb(String str, String str2, zzacc zzaccVar) {
        F.d(str);
        F.d(str2);
        F.g(zzaccVar);
        this.zzb.zzb(str, str2, new zzacf(zzaccVar, zza));
    }

    public final void zzc(String str, String str2, zzacc zzaccVar) {
        F.d(str);
        F.d(str2);
        F.g(zzaccVar);
        this.zzb.zzc(str, str2, new zzacf(zzaccVar, zza));
    }

    public final void zzd(String str, String str2, zzacc zzaccVar) {
        F.d(str);
        F.g(zzaccVar);
        this.zzb.zzd(str, str2, new zzacf(zzaccVar, zza));
    }

    public final void zze(String str, String str2, zzacc zzaccVar) {
        F.d(str);
        this.zzb.zze(str, str2, new zzacf(zzaccVar, zza));
    }

    public final void zzf(String str, String str2, zzacc zzaccVar) {
        F.d(str);
        F.d(str2);
        F.g(zzaccVar);
        this.zzb.zzf(str, str2, new zzacf(zzaccVar, zza));
    }

    public final void zze(String str, zzacc zzaccVar) {
        F.d(str);
        F.g(zzaccVar);
        this.zzb.zzf(str, new zzacf(zzaccVar, zza));
    }

    public final void zza(zzxx zzxxVar, zzacc zzaccVar) {
        F.g(zzxxVar);
        F.d(zzxxVar.zza());
        F.d(zzxxVar.zzb());
        F.g(zzaccVar);
        this.zzb.zza(zzxxVar.zza(), zzxxVar.zzb(), zzxxVar.zzc(), new zzacf(zzaccVar, zza));
    }

    public final void zzd(String str, zzacc zzaccVar) {
        F.g(zzaccVar);
        this.zzb.zze(str, new zzacf(zzaccVar, zza));
    }

    public final void zzb(String str, zzacc zzaccVar) {
        F.d(str);
        F.g(zzaccVar);
        this.zzb.zzb(str, new zzacf(zzaccVar, zza));
    }

    public final void zzc(String str, zzacc zzaccVar) {
        F.d(str);
        F.g(zzaccVar);
        this.zzb.zzc(str, new zzacf(zzaccVar, zza));
    }

    public final void zzb(String str, String str2, String str3, String str4, zzacc zzaccVar) {
        F.d(str);
        F.d(str2);
        F.g(zzaccVar);
        this.zzb.zzb(str, str2, str3, str4, new zzacf(zzaccVar, zza));
    }

    public final void zza(String str, String str2, String str3, String str4, zzacc zzaccVar) {
        F.d(str);
        F.d(str2);
        F.g(zzaccVar);
        this.zzb.zza(str, str2, str3, str4, new zzacf(zzaccVar, zza));
    }

    public final void zza(String str, zzacc zzaccVar) {
        F.d(str);
        F.g(zzaccVar);
        this.zzb.zza(str, new zzacf(zzaccVar, zza));
    }

    public final void zza(o oVar, String str, String str2, String str3, zzacc zzaccVar) {
        F.g(oVar);
        throw null;
    }

    public final void zza(String str, o oVar, String str2, zzacc zzaccVar) {
        F.d(str);
        F.g(oVar);
        throw null;
    }

    public final void zza(zzxw zzxwVar, zzacc zzaccVar) {
        F.g(zzxwVar);
        this.zzb.zza(zzaff.zzb(), new zzacf(zzaccVar, zza));
    }

    public final void zza(zzxz zzxzVar, zzacc zzaccVar) {
        F.g(zzxzVar);
        this.zzb.zza(zzafk.zza(zzxzVar.zzb(), zzxzVar.zza()), new zzacf(zzaccVar, zza));
    }

    public final void zza(String str, String str2, String str3, String str4, String str5, zzacc zzaccVar) {
        F.d(str);
        F.d(str2);
        F.d(str3);
        F.g(zzaccVar);
        this.zzb.zza(str, str2, str3, str4, str5, new zzacf(zzaccVar, zza));
    }

    public final void zza(String str, zzags zzagsVar, zzacc zzaccVar) {
        F.d(str);
        F.g(zzagsVar);
        F.g(zzaccVar);
        this.zzb.zza(str, zzagsVar, new zzacf(zzaccVar, zza));
    }

    public final void zza(zzxy zzxyVar, zzacc zzaccVar) {
        F.g(zzaccVar);
        F.g(zzxyVar);
        q qVarZza = zzxyVar.zza();
        F.g(qVarZza);
        String strZzb = zzxyVar.zzb();
        F.d(strZzb);
        this.zzb.zza(strZzb, zzadn.zza(qVarZza), new zzacf(zzaccVar, zza));
    }

    public final void zza(zzafy zzafyVar, zzacc zzaccVar) {
        F.g(zzafyVar);
        this.zzb.zza(zzafyVar, new zzacf(zzaccVar, zza));
    }

    public final void zza(zzyb zzybVar, zzacc zzaccVar) {
        F.g(zzybVar);
        F.d(zzybVar.zzb());
        F.g(zzaccVar);
        this.zzb.zza(zzybVar.zzb(), zzybVar.zza(), new zzacf(zzaccVar, zza));
    }

    public final void zza(zzya zzyaVar, zzacc zzaccVar) {
        F.g(zzyaVar);
        F.d(zzyaVar.zzc());
        F.g(zzaccVar);
        this.zzb.zza(zzyaVar.zzc(), zzyaVar.zza(), zzyaVar.zzd(), zzyaVar.zzb(), new zzacf(zzaccVar, zza));
    }

    public final void zza(zzyd zzydVar, zzacc zzaccVar) {
        F.g(zzaccVar);
        F.g(zzydVar);
        zzafz zzafzVarZza = zzydVar.zza();
        F.g(zzafzVarZza);
        String strZzd = zzafzVarZza.zzd();
        zzacf zzacfVar = new zzacf(zzaccVar, zza);
        if (this.zzc.zzd(strZzd)) {
            if (zzafzVarZza.zze()) {
                this.zzc.zzc(strZzd);
            } else {
                this.zzc.zzb(zzacfVar, strZzd);
                return;
            }
        }
        long jZzb = zzafzVarZza.zzb();
        boolean zZzf = zzafzVarZza.zzf();
        if (zza(jZzb, zZzf)) {
            zzafzVarZza.zza(new zzaed(this.zzc.zzb()));
        }
        this.zzc.zza(strZzd, zzacfVar, jZzb, zZzf);
        this.zzb.zza(zzafzVarZza, this.zzc.zza(zzacfVar, strZzd));
    }

    public final void zza(zzyc zzycVar, zzacc zzaccVar) {
        F.g(zzycVar);
        F.g(zzaccVar);
        this.zzb.zzd(zzycVar.zza(), new zzacf(zzaccVar, zza));
    }

    public final void zza(zzags zzagsVar, zzacc zzaccVar) {
        F.g(zzagsVar);
        F.g(zzaccVar);
        this.zzb.zza(zzagsVar, new zzacf(zzaccVar, zza));
    }

    public final void zza(zzagt zzagtVar, zzacc zzaccVar) {
        F.g(zzagtVar);
        F.g(zzaccVar);
        this.zzb.zza(zzagtVar, new zzacf(zzaccVar, zza));
    }

    public final void zza(zzyf zzyfVar, zzacc zzaccVar) {
        F.g(zzyfVar);
        F.g(zzyfVar.zza());
        F.g(zzaccVar);
        this.zzb.zza(zzyfVar.zza(), zzyfVar.zzb(), new zzacf(zzaccVar, zza));
    }

    public final void zza(zzye zzyeVar, zzacc zzaccVar) {
        F.g(zzaccVar);
        F.g(zzyeVar);
        q qVarZza = zzyeVar.zza();
        F.g(qVarZza);
        this.zzb.zza(zzadn.zza(qVarZza), new zzacf(zzaccVar, zza));
    }

    public final void zza(String str, String str2, String str3, long j4, boolean z4, boolean z5, String str4, String str5, boolean z6, zzacc zzaccVar) {
        F.e(str, "idToken should not be empty.");
        F.g(zzaccVar);
        zzacf zzacfVar = new zzacf(zzaccVar, zza);
        if (this.zzc.zzd(str2)) {
            if (z4) {
                this.zzc.zzc(str2);
            } else {
                this.zzc.zzb(zzacfVar, str2);
                return;
            }
        }
        zzagj zzagjVarZza = zzagj.zza(str, str2, str3, str4, str5, null);
        if (zza(j4, z6)) {
            zzagjVarZza.zza(new zzaed(this.zzc.zzb()));
        }
        this.zzc.zza(str2, zzacfVar, j4, z6);
        this.zzb.zza(zzagjVarZza, this.zzc.zza(zzacfVar, str2));
    }

    public final void zza(zzyh zzyhVar, zzacc zzaccVar) {
        F.g(zzyhVar);
        F.g(zzaccVar);
        String str = zzyhVar.zzb().f5212d;
        zzacf zzacfVar = new zzacf(zzaccVar, zza);
        if (this.zzc.zzd(str)) {
            if (zzyhVar.zzg()) {
                this.zzc.zzc(str);
            } else {
                this.zzc.zzb(zzacfVar, str);
                return;
            }
        }
        long jZza = zzyhVar.zza();
        boolean zZzh = zzyhVar.zzh();
        zzagh zzaghVarZza = zzagh.zza(zzyhVar.zzd(), zzyhVar.zzb().f5209a, zzyhVar.zzb().f5212d, zzyhVar.zzc(), zzyhVar.zzf(), zzyhVar.zze());
        if (zza(jZza, zZzh)) {
            zzaghVarZza.zza(new zzaed(this.zzc.zzb()));
        }
        this.zzc.zza(str, zzacfVar, jZza, zZzh);
        this.zzb.zza(zzaghVarZza, this.zzc.zza(zzacfVar, str));
    }

    public final void zza(zzagl zzaglVar, zzacc zzaccVar) {
        F.g(zzaccVar);
        this.zzb.zza(zzaglVar, new zzacf(zzaccVar, zza));
    }

    public final void zza(String str, String str2, String str3, zzacc zzaccVar) {
        F.e(str, "cachedTokenState should not be empty.");
        F.e(str2, "uid should not be empty.");
        F.g(zzaccVar);
        this.zzb.zzb(str, str2, str3, new zzacf(zzaccVar, zza));
    }

    public final void zza(String str, C0451A c0451a, zzacc zzaccVar) {
        F.d(str);
        F.g(c0451a);
        F.g(zzaccVar);
        this.zzb.zza(str, c0451a, new zzacf(zzaccVar, zza));
    }

    public final void zza(zzyg zzygVar, zzacc zzaccVar) {
        F.g(zzygVar);
        this.zzb.zza(zzafd.zza(zzygVar.zza(), zzygVar.zzb(), zzygVar.zzc()), new zzacf(zzaccVar, zza));
    }

    private static boolean zza(long j4, boolean z4) {
        if (j4 > 0 && z4) {
            return true;
        }
        zza.f("App hash will not be appended to the request.", new Object[0]);
        return false;
    }
}
