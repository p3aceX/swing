package com.google.android.gms.tasks;

import android.app.Activity;
import com.google.android.gms.common.api.internal.InterfaceC0263k;
import com.google.android.gms.common.api.internal.LifecycleCallback;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzv extends LifecycleCallback {
    private final List zza;

    private zzv(InterfaceC0263k interfaceC0263k) {
        super(interfaceC0263k);
        this.zza = new ArrayList();
        this.mLifecycleFragment.d("TaskOnStopCallback", this);
    }

    public static zzv zza(Activity activity) {
        InterfaceC0263k fragment = LifecycleCallback.getFragment(activity);
        zzv zzvVar = (zzv) fragment.e(zzv.class, "TaskOnStopCallback");
        return zzvVar == null ? new zzv(fragment) : zzvVar;
    }

    @Override // com.google.android.gms.common.api.internal.LifecycleCallback
    public final void onStop() {
        synchronized (this.zza) {
            try {
                Iterator it = this.zza.iterator();
                while (it.hasNext()) {
                    zzq zzqVar = (zzq) ((WeakReference) it.next()).get();
                    if (zzqVar != null) {
                        zzqVar.zzc();
                    }
                }
                this.zza.clear();
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public final void zzb(zzq zzqVar) {
        synchronized (this.zza) {
            this.zza.add(new WeakReference(zzqVar));
        }
    }
}
