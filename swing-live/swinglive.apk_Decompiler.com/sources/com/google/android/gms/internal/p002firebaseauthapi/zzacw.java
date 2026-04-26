package com.google.android.gms.internal.p002firebaseauthapi;

import android.app.Activity;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.InterfaceC0263k;
import com.google.android.gms.common.api.internal.LifecycleCallback;
import com.google.android.gms.common.internal.F;
import g1.f;
import j1.AbstractC0458c;
import j1.l;
import j1.s;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import k1.i;

/* JADX INFO: loaded from: classes.dex */
abstract class zzacw<ResultT, CallbackT> implements zzadh<ResultT> {
    protected final int zza;
    private ResultT zzaa;
    private Status zzab;
    protected f zzc;
    protected l zzd;
    protected CallbackT zze;
    protected i zzf;
    protected zzacx<ResultT> zzg;
    protected Executor zzi;
    protected zzafm zzj;
    protected zzafb zzk;
    protected zzaem zzl;
    protected zzafv zzm;
    protected String zzn;
    protected String zzo;
    protected AbstractC0458c zzp;
    protected String zzq;
    protected String zzr;
    protected zzyi zzs;
    protected zzafj zzt;
    protected zzafi zzu;
    protected zzagi zzv;
    protected zzaga zzw;
    boolean zzx;
    private boolean zzz;
    protected final zzacy zzb = new zzacy(this);
    protected final List<s> zzh = new ArrayList();
    private boolean zzy = true;

    public static class zza extends LifecycleCallback {
        private final List<s> zza;

        private zza(InterfaceC0263k interfaceC0263k, List<s> list) {
            super(interfaceC0263k);
            this.mLifecycleFragment.d("PhoneAuthActivityStopCallback", this);
            this.zza = list;
        }

        public static void zza(Activity activity, List<s> list) {
            InterfaceC0263k fragment = LifecycleCallback.getFragment(activity);
            if (((zza) fragment.e(zza.class, "PhoneAuthActivityStopCallback")) == null) {
                new zza(fragment, list);
            }
        }

        @Override // com.google.android.gms.common.api.internal.LifecycleCallback
        public void onStop() {
            synchronized (this.zza) {
                this.zza.clear();
            }
        }
    }

    public zzacw(int i4) {
        this.zza = i4;
    }

    public abstract void zzb();

    public final void zzb(ResultT resultt) {
        this.zzz = true;
        this.zzx = true;
        this.zzaa = resultt;
        this.zzg.zza(resultt, null);
    }

    public final zzacw<ResultT, CallbackT> zza(CallbackT callbackt) {
        F.h(callbackt, "external callback cannot be null");
        this.zze = callbackt;
        return this;
    }

    public final zzacw<ResultT, CallbackT> zza(i iVar) {
        F.h(iVar, "external failure callback cannot be null");
        this.zzf = iVar;
        return this;
    }

    public final zzacw<ResultT, CallbackT> zza(f fVar) {
        F.h(fVar, "firebaseApp cannot be null");
        this.zzc = fVar;
        return this;
    }

    public final zzacw<ResultT, CallbackT> zza(l lVar) {
        F.h(lVar, "firebaseUser cannot be null");
        this.zzd = lVar;
        return this;
    }

    public final zzacw<ResultT, CallbackT> zza(s sVar, Activity activity, Executor executor, String str) {
        s sVarZza = zzads.zza(str, sVar, this);
        synchronized (this.zzh) {
            List<s> list = this.zzh;
            F.g(sVarZza);
            list.add(sVarZza);
        }
        if (activity != null) {
            zza.zza(activity, this.zzh);
        }
        F.g(executor);
        this.zzi = executor;
        return this;
    }

    public static /* synthetic */ void zza(zzacw zzacwVar) {
        zzacwVar.zzb();
        F.i("no success or failure set on method implementation", zzacwVar.zzz);
    }

    public static /* synthetic */ void zza(zzacw zzacwVar, Status status) {
        i iVar = zzacwVar.zzf;
        if (iVar != null) {
            iVar.zza(status);
        }
    }

    public final void zza(Status status) {
        this.zzz = true;
        this.zzx = false;
        this.zzab = status;
        this.zzg.zza(null, status);
    }
}
