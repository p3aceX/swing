package com.google.android.gms.internal.p002firebaseauthapi;

import B.k;
import android.app.Activity;
import android.net.Uri;
import android.text.TextUtils;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import e1.AbstractC0367g;
import g1.f;
import j1.AbstractC0458c;
import j1.C0451A;
import j1.C0456a;
import j1.C0459d;
import j1.l;
import j1.q;
import j1.t;
import j1.u;
import j1.w;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.ScheduledExecutorService;
import k1.c;
import k1.e;
import k1.g;
import k1.i;
import k1.j;
import k1.p;
import k1.s;

/* JADX INFO: loaded from: classes.dex */
public final class zzaag extends zzadf {
    public zzaag(f fVar, Executor executor, ScheduledExecutorService scheduledExecutorService) {
        this.zza = new zzace(fVar, scheduledExecutorService);
        this.zzb = executor;
    }

    public final Task<Void> zza(f fVar, String str, String str2) {
        return zza((zzaaj) new zzaaj(str, str2).zza(fVar));
    }

    public final Task<Object> zzb(f fVar, String str, String str2) {
        return zza((zzaai) new zzaai(str, str2).zza(fVar));
    }

    public final Task<Object> zzc(f fVar, String str, String str2) {
        return zza((zzaam) new zzaam(str, str2).zza(fVar));
    }

    public final Task<Void> zzd(f fVar, l lVar, String str, p pVar) {
        return zza((zzabw) new zzabw(str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, String str, String str2, String str3) {
        return zza((zzaal) new zzaal(str, str2, str3).zza(fVar));
    }

    public final Task<Void> zzb(f fVar, String str, C0456a c0456a, String str2, String str3) {
        c0456a.f5188o = 6;
        return zza((zzabj) new zzabj(str, c0456a, str2, str3, "sendSignInLinkToEmail").zza(fVar));
    }

    public final Task<Object> zzc(f fVar, l lVar, AbstractC0458c abstractC0458c, String str, p pVar) {
        return zza((zzaaz) new zzaaz(abstractC0458c, str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Object> zza(f fVar, String str, String str2, String str3, String str4, s sVar) {
        return zza((zzaak) new zzaak(str, str2, str3, str4).zza(fVar).zza(sVar));
    }

    public final Task<String> zzd(f fVar, String str, String str2) {
        return zza((zzaca) new zzaca(str, str2).zza(fVar));
    }

    public final Task<Void> zzb(f fVar, l lVar, AbstractC0458c abstractC0458c, String str, p pVar) {
        return zza((zzaaw) new zzaaw(abstractC0458c, str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zzc(f fVar, l lVar, String str, p pVar) {
        return zza((zzabx) new zzabx(str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(l lVar, j jVar) {
        return zza((zzaan) new zzaan().zza(lVar).zza(jVar).zza((i) jVar));
    }

    public final Task<Object> zzb(f fVar, l lVar, C0459d c0459d, String str, p pVar) {
        return zza((zzabb) new zzabb(c0459d, str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, t tVar, l lVar, String str, s sVar) {
        zzads.zza();
        zzaap zzaapVar = new zzaap(tVar, ((e) lVar).f5512a.zzf(), str, null);
        zzaapVar.zza(fVar).zza(sVar);
        return zza(zzaapVar);
    }

    public final Task<Object> zzb(f fVar, l lVar, String str, String str2, String str3, String str4, p pVar) {
        return zza((zzabd) new zzabd(str, str2, str3, str4).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, w wVar, l lVar, String str, String str2, s sVar) {
        zzaap zzaapVar = new zzaap(wVar, ((e) lVar).f5512a.zzf(), str, str2);
        zzaapVar.zza(fVar).zza(sVar);
        return zza(zzaapVar);
    }

    public final Task<Object> zzb(f fVar, l lVar, q qVar, String str, p pVar) {
        zzads.zza();
        return zza((zzabf) new zzabf(qVar, str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Object> zza(f fVar, l lVar, t tVar, String str, s sVar) {
        zzads.zza();
        zzaao zzaaoVar = new zzaao(tVar, str, null);
        zzaaoVar.zza(fVar).zza(sVar);
        if (lVar != null) {
            zzaaoVar.zza(lVar);
        }
        return zza(zzaaoVar);
    }

    public final Task<Object> zzb(f fVar, String str, String str2, String str3, String str4, s sVar) {
        return zza((zzabm) new zzabm(str, str2, str3, str4).zza(fVar).zza(sVar));
    }

    public final Task<Object> zza(f fVar, l lVar, w wVar, String str, String str2, s sVar) {
        zzaao zzaaoVar = new zzaao(wVar, str, str2);
        zzaaoVar.zza(fVar).zza(sVar);
        if (lVar != null) {
            zzaaoVar.zza(lVar);
        }
        return zza(zzaaoVar);
    }

    public final Task<Object> zzb(f fVar, l lVar, String str, p pVar) {
        F.g(fVar);
        F.d(str);
        F.g(lVar);
        F.g(pVar);
        ArrayList arrayList = ((e) lVar).f5516f;
        if ((arrayList != null && !arrayList.contains(str)) || lVar.c()) {
            return Tasks.forException(zzach.zza(new Status(17016, str)));
        }
        str.getClass();
        if (!str.equals("password")) {
            return zza((zzabu) new zzabu(str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
        }
        return zza((zzabv) new zzabv().zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, String str, C0456a c0456a, String str2, String str3) {
        c0456a.f5188o = 1;
        return zza((zzabj) new zzabj(str, c0456a, str2, str3, "sendPasswordResetEmail").zza(fVar));
    }

    public final Task<Void> zza(String str, String str2, C0456a c0456a) {
        c0456a.f5188o = 7;
        return zza(new zzacb(str, str2, c0456a));
    }

    public final Task<k> zza(f fVar, l lVar, String str, p pVar) {
        return zza((zzaar) new zzaar(str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<zzafi> zza() {
        return zza(new zzaaq());
    }

    public final Task<zzafj> zza(String str, String str2) {
        return zza(new zzaat(str, str2));
    }

    public final Task<Object> zza(f fVar, l lVar, AbstractC0458c abstractC0458c, String str, p pVar) {
        F.g(fVar);
        F.g(abstractC0458c);
        F.g(lVar);
        F.g(pVar);
        ArrayList arrayList = ((e) lVar).f5516f;
        if (arrayList != null && arrayList.contains(abstractC0458c.b())) {
            return Tasks.forException(zzach.zza(new Status(17015, null)));
        }
        if (abstractC0458c instanceof C0459d) {
            C0459d c0459d = (C0459d) abstractC0458c;
            if (TextUtils.isEmpty(c0459d.f5195c)) {
                return zza((zzaas) new zzaas(c0459d, str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
            }
            return zza((zzaax) new zzaax(c0459d).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
        }
        if (abstractC0458c instanceof q) {
            zzads.zza();
            return zza((zzaau) new zzaau((q) abstractC0458c).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
        }
        return zza((zzaav) new zzaav(abstractC0458c).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, l lVar, C0459d c0459d, String str, p pVar) {
        return zza((zzaay) new zzaay(c0459d, str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, l lVar, String str, String str2, String str3, String str4, p pVar) {
        return zza((zzaba) new zzaba(str, str2, str3, str4).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, l lVar, q qVar, String str, p pVar) {
        zzads.zza();
        return zza((zzabc) new zzabc(qVar, str).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, l lVar, p pVar) {
        return zza((zzabe) new zzabe().zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(String str, String str2, String str3, String str4) {
        return zza(new zzabh(str, str2, str3, str4));
    }

    public final Task<Void> zza(f fVar, C0456a c0456a, String str) {
        return zza((zzabg) new zzabg(str, c0456a).zza(fVar));
    }

    public final Task<Void> zza(String str) {
        return zza(new zzabi(str));
    }

    public final Task<Object> zza(f fVar, s sVar, String str) {
        return zza((zzabl) new zzabl(str).zza(fVar).zza(sVar));
    }

    public final Task<Object> zza(f fVar, AbstractC0458c abstractC0458c, String str, s sVar) {
        return zza((zzabk) new zzabk(abstractC0458c, str).zza(fVar).zza(sVar));
    }

    public final Task<Object> zza(f fVar, String str, String str2, s sVar) {
        return zza((zzabn) new zzabn(str, str2).zza(fVar).zza(sVar));
    }

    public final Task<Object> zza(f fVar, C0459d c0459d, String str, s sVar) {
        return zza((zzabp) new zzabp(c0459d, str).zza(fVar).zza(sVar));
    }

    public final Task<Object> zza(f fVar, q qVar, String str, s sVar) {
        zzads.zza();
        return zza((zzabo) new zzabo(qVar, str).zza(fVar).zza(sVar));
    }

    public final Task<Void> zza(g gVar, String str, String str2, long j4, boolean z4, boolean z5, String str3, String str4, boolean z6, j1.s sVar, Executor executor, Activity activity) {
        zzabr zzabrVar = new zzabr(gVar, str, str2, j4, z4, z5, str3, str4, z6);
        zzabrVar.zza(sVar, activity, executor, str);
        return zza(zzabrVar);
    }

    public final Task<zzagi> zza(g gVar, String str) {
        return zza(new zzabq(gVar, str));
    }

    public final Task<Void> zza(g gVar, u uVar, String str, long j4, boolean z4, boolean z5, String str2, String str3, boolean z6, j1.s sVar, Executor executor, Activity activity) {
        String str4 = gVar.f5527b;
        F.d(str4);
        zzabt zzabtVar = new zzabt(uVar, str4, str, j4, z4, z5, str2, str3, z6);
        zzabtVar.zza(sVar, activity, executor, uVar.f5209a);
        return zza(zzabtVar);
    }

    public final Task<Void> zza(f fVar, l lVar, String str, String str2, p pVar) {
        return zza((zzabs) new zzabs(((e) lVar).f5512a.zzf(), str, str2).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, l lVar, q qVar, p pVar) {
        zzads.zza();
        return zza((zzabz) new zzabz(qVar).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public final Task<Void> zza(f fVar, l lVar, C0451A c0451a, p pVar) {
        return zza((zzaby) new zzaby(c0451a).zza(fVar).zza(lVar).zza(pVar).zza((i) pVar));
    }

    public static e zza(f fVar, zzafb zzafbVar) {
        F.g(fVar);
        F.g(zzafbVar);
        ArrayList arrayList = new ArrayList();
        c cVar = new c();
        F.d("firebase");
        String strZzi = zzafbVar.zzi();
        F.d(strZzi);
        cVar.f5505a = strZzi;
        cVar.f5506b = "firebase";
        cVar.e = zzafbVar.zzh();
        cVar.f5507c = zzafbVar.zzg();
        Uri uriZzc = zzafbVar.zzc();
        if (uriZzc != null) {
            cVar.f5508d = uriZzc.toString();
        }
        cVar.f5510m = zzafbVar.zzm();
        cVar.f5511n = null;
        cVar.f5509f = zzafbVar.zzj();
        arrayList.add(cVar);
        List<zzafr> listZzl = zzafbVar.zzl();
        if (listZzl != null && !listZzl.isEmpty()) {
            for (int i4 = 0; i4 < listZzl.size(); i4++) {
                zzafr zzafrVar = listZzl.get(i4);
                c cVar2 = new c();
                F.g(zzafrVar);
                cVar2.f5505a = zzafrVar.zzd();
                String strZzf = zzafrVar.zzf();
                F.d(strZzf);
                cVar2.f5506b = strZzf;
                cVar2.f5507c = zzafrVar.zzb();
                Uri uriZza = zzafrVar.zza();
                if (uriZza != null) {
                    cVar2.f5508d = uriZza.toString();
                }
                cVar2.e = zzafrVar.zzc();
                cVar2.f5509f = zzafrVar.zze();
                cVar2.f5510m = false;
                cVar2.f5511n = zzafrVar.zzg();
                arrayList.add(cVar2);
            }
        }
        e eVar = new e(fVar, arrayList);
        eVar.f5519o = new k1.f(zzafbVar.zzb(), zzafbVar.zza());
        eVar.f5520p = zzafbVar.zzn();
        eVar.f5521q = zzafbVar.zze();
        eVar.e(AbstractC0367g.b0(zzafbVar.zzk()));
        zzaq<zzafp> zzaqVarZzd = zzafbVar.zzd();
        F.g(zzaqVarZzd);
        eVar.f5523s = zzaqVarZzd;
        return eVar;
    }

    public final void zza(f fVar, zzafz zzafzVar, j1.s sVar, Activity activity, Executor executor) {
        zza((zzacd) new zzacd(zzafzVar).zza(fVar).zza(sVar, activity, executor, zzafzVar.zzd()));
    }
}
