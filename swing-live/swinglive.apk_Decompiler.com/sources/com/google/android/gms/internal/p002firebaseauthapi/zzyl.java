package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import e1.k;
import j1.C0451A;
import j1.C0455E;
import j1.C0456a;
import j1.C0459d;

/* JADX INFO: loaded from: classes.dex */
public final class zzyl {
    private final zzadk zza;

    public zzyl(zzadk zzadkVar) {
        F.g(zzadkVar);
        this.zza = zzadkVar;
    }

    public final void zzb(String str, String str2, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.g(zzacfVar);
        zza(str, new zzaad(this, str2, zzacfVar));
    }

    public final void zzc(String str, String str2, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.g(zzacfVar);
        zza(str, new zzaac(this, str2, zzacfVar));
    }

    public final void zzd(String str, String str2, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        this.zza.zza(new zzafw(str, null, str2), new zzyu(this, zzacfVar));
    }

    public final void zze(String str, String str2, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        this.zza.zza(new zzaej(str, str2), new zzys(this, zzacfVar));
    }

    public final void zzf(String str, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        zza(str, new zzzh(this, zzacfVar));
    }

    public static void zza(zzyl zzylVar, zzagu zzaguVar, zzacf zzacfVar, zzadj zzadjVar) {
        Status statusO;
        if (zzaguVar.zzo()) {
            C0455E c0455eZzb = zzaguVar.zzb();
            String strZzc = zzaguVar.zzc();
            String strZzj = zzaguVar.zzj();
            if (zzaguVar.zzm()) {
                statusO = new Status(17012, null);
            } else {
                statusO = k.O(zzaguVar.zzd());
            }
            zzacfVar.zza(new zzyj(statusO, c0455eZzb, strZzc, strZzj));
            return;
        }
        zzylVar.zza(new zzafm(zzaguVar.zzi(), zzaguVar.zze(), Long.valueOf(zzaguVar.zza()), "Bearer"), zzaguVar.zzh(), zzaguVar.zzg(), Boolean.valueOf(zzaguVar.zzn()), zzaguVar.zzb(), zzacfVar, zzadjVar);
    }

    public final void zzf(String str, String str2, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.g(zzacfVar);
        zza(str2, new zzzg(this, str, zzacfVar));
    }

    public final void zzb(String str, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        this.zza.zza(new zzafa(str), new zzyk(this, zzacfVar));
    }

    public final void zzc(String str, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        zza(str, new zzzs(this, zzacfVar));
    }

    public final void zzd(String str, zzacf zzacfVar) {
        F.g(zzacfVar);
        this.zza.zza(str, new zzzw(this, zzacfVar));
    }

    public final void zze(String str, zzacf zzacfVar) {
        F.g(zzacfVar);
        this.zza.zza(new zzagd(str), new zzzy(this, zzacfVar));
    }

    private final void zzb(zzafd zzafdVar, zzacf zzacfVar) {
        F.g(zzafdVar);
        F.g(zzacfVar);
        this.zza.zza(zzafdVar, new zzzz(this, zzacfVar));
    }

    public final void zzb(String str, String str2, String str3, String str4, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.g(zzacfVar);
        this.zza.zza(new zzagv(str, str2, str3, str4), new zzym(this, zzacfVar));
    }

    public final void zzb(String str, String str2, String str3, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.g(zzacfVar);
        zza(str, new zzzi(this, str2, str3, zzacfVar));
    }

    public static /* synthetic */ void zza(zzyl zzylVar, zzacf zzacfVar, zzagd zzagdVar, zzadj zzadjVar) {
        F.g(zzacfVar);
        F.g(zzagdVar);
        F.g(zzadjVar);
        zzylVar.zza.zza(zzagdVar, new zzza(zzylVar, zzacfVar, zzadjVar));
    }

    public static /* synthetic */ void zza(zzyl zzylVar, zzacf zzacfVar, zzafm zzafmVar, zzagb zzagbVar, zzadj zzadjVar) {
        F.g(zzacfVar);
        F.g(zzafmVar);
        F.g(zzagbVar);
        F.g(zzadjVar);
        zzylVar.zza.zza(new zzaez(zzafmVar.zzc()), new zzyr(zzylVar, zzadjVar, zzacfVar, zzafmVar, zzagbVar));
    }

    public static /* synthetic */ void zza(zzyl zzylVar, zzacf zzacfVar, zzafm zzafmVar, zzafb zzafbVar, zzagb zzagbVar, zzadj zzadjVar) {
        F.g(zzacfVar);
        F.g(zzafmVar);
        F.g(zzafbVar);
        F.g(zzagbVar);
        F.g(zzadjVar);
        zzylVar.zza.zza(zzagbVar, new zzyq(zzylVar, zzagbVar, zzafbVar, zzacfVar, zzafmVar, zzadjVar));
    }

    public final void zza(String str, String str2, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        zzagb zzagbVar = new zzagb();
        zzagbVar.zze(str);
        zzagbVar.zzh(str2);
        this.zza.zza(zzagbVar, new zzaaf(this, zzacfVar));
    }

    public final void zza(String str, String str2, String str3, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.g(zzacfVar);
        this.zza.zza(new zzafw(str, str2, str3), new zzyw(this, zzacfVar));
    }

    public final void zza(String str, String str2, String str3, String str4, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.g(zzacfVar);
        this.zza.zza(new zzagd(str, str2, null, str3, str4, null), new zzyn(this, zzacfVar));
    }

    public final void zza(String str, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        zza(str, new zzzu(this, zzacfVar));
    }

    private final void zza(String str, zzadm<zzafm> zzadmVar) {
        F.g(zzadmVar);
        F.d(str);
        zzafm zzafmVarZzb = zzafm.zzb(str);
        if (zzafmVarZzb.zzg()) {
            zzadmVar.zza(zzafmVarZzb);
        } else {
            this.zza.zza(new zzafa(zzafmVarZzb.zzd()), new zzaae(this, zzadmVar));
        }
    }

    public final void zza(zzaeq zzaeqVar, String str, zzacf zzacfVar) {
        F.g(zzaeqVar);
        F.g(zzacfVar);
        zza(str, new zzzm(this, zzaeqVar, zzacfVar));
    }

    public final void zza(zzaes zzaesVar, zzacf zzacfVar) {
        F.g(zzaesVar);
        F.g(zzacfVar);
        this.zza.zza(zzaesVar, new zzzo(this, zzacfVar));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzaeo zzaeoVar, zzacf zzacfVar) {
        F.g(zzaeoVar);
        F.g(zzacfVar);
        this.zza.zza(zzaeoVar, new zzyo(this, zzacfVar));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zza(zzafm zzafmVar, String str, String str2, Boolean bool, C0455E c0455e, zzacf zzacfVar, zzadj zzadjVar) {
        F.g(zzafmVar);
        F.g(zzadjVar);
        F.g(zzacfVar);
        this.zza.zza(new zzaez(zzafmVar.zzc()), new zzyt(this, zzadjVar, str2, str, bool, c0455e, zzacfVar, zzafmVar));
    }

    public final void zza(zzaff zzaffVar, zzacf zzacfVar) {
        F.g(zzaffVar);
        F.g(zzacfVar);
        this.zza.zza(zzaffVar, new zzzt(this, zzacfVar));
    }

    public final void zza(zzafk zzafkVar, zzacf zzacfVar) {
        F.g(zzafkVar);
        F.g(zzacfVar);
        this.zza.zza(zzafkVar, new zzzq(this, zzacfVar));
    }

    public final void zza(String str, String str2, String str3, String str4, String str5, zzacf zzacfVar) {
        F.d(str);
        F.d(str2);
        F.d(str3);
        F.g(zzacfVar);
        zza(str3, new zzzb(this, str, str2, str4, str5, zzacfVar));
    }

    public final void zza(String str, zzags zzagsVar, zzacf zzacfVar) {
        F.d(str);
        F.g(zzagsVar);
        F.g(zzacfVar);
        zza(str, new zzzf(this, zzagsVar, zzacfVar));
    }

    public final void zza(String str, zzagx zzagxVar, zzacf zzacfVar) {
        F.d(str);
        F.g(zzagxVar);
        F.g(zzacfVar);
        zza(str, new zzzd(this, zzagxVar, zzacfVar));
    }

    public final void zza(zzafy zzafyVar, zzacf zzacfVar) {
        this.zza.zza(zzafyVar, new zzaab(this, zzacfVar));
    }

    public final void zza(String str, C0456a c0456a, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        zzafd zzafdVar = new zzafd(4);
        zzafdVar.zzd(str);
        if (c0456a != null) {
            zzafdVar.zza(c0456a);
        }
        zzb(zzafdVar, zzacfVar);
    }

    public final void zza(String str, C0456a c0456a, String str2, String str3, zzacf zzacfVar) {
        F.d(str);
        F.g(zzacfVar);
        zzafd zzafdVar = new zzafd(c0456a.f5188o);
        zzafdVar.zzb(str);
        zzafdVar.zza(c0456a);
        zzafdVar.zzc(str2);
        zzafdVar.zza(str3);
        this.zza.zza(zzafdVar, new zzyv(this, zzacfVar));
    }

    public final void zza(zzafz zzafzVar, zzacf zzacfVar) {
        F.d(zzafzVar.zzd());
        F.g(zzacfVar);
        this.zza.zza(zzafzVar, new zzyz(this, zzacfVar));
    }

    public final void zza(zzags zzagsVar, zzacf zzacfVar) {
        F.g(zzagsVar);
        F.g(zzacfVar);
        zzagsVar.zzb(true);
        this.zza.zza(zzagsVar, new zzzk(this, zzacfVar));
    }

    public final void zza(zzagt zzagtVar, zzacf zzacfVar) {
        F.g(zzagtVar);
        F.g(zzacfVar);
        this.zza.zza(zzagtVar, new zzyx(this, zzacfVar));
    }

    public final void zza(C0459d c0459d, String str, zzacf zzacfVar) {
        F.g(c0459d);
        F.g(zzacfVar);
        if (c0459d.e) {
            zza(c0459d.f5196d, new zzyp(this, c0459d, str, zzacfVar));
        } else {
            zza(new zzaeo(c0459d, null, str), zzacfVar);
        }
    }

    public final void zza(zzagx zzagxVar, zzacf zzacfVar) {
        F.g(zzagxVar);
        F.g(zzacfVar);
        this.zza.zza(zzagxVar, new zzyy(this, zzacfVar));
    }

    public final void zza(zzagf zzagfVar, zzacf zzacfVar) {
        F.g(zzagfVar);
        F.g(zzacfVar);
        this.zza.zza(zzagfVar, new zzzn(this, zzagfVar, zzacfVar));
    }

    public final void zza(zzagh zzaghVar, zzacf zzacfVar) {
        F.g(zzaghVar);
        F.g(zzacfVar);
        this.zza.zza(zzaghVar, new zzzr(this, zzacfVar));
    }

    public final void zza(String str, C0451A c0451a, zzacf zzacfVar) {
        F.d(str);
        F.g(c0451a);
        F.g(zzacfVar);
        zza(str, new zzaaa(this, c0451a, zzacfVar));
    }

    public final void zza(zzafd zzafdVar, zzacf zzacfVar) {
        zzb(zzafdVar, zzacfVar);
    }
}
