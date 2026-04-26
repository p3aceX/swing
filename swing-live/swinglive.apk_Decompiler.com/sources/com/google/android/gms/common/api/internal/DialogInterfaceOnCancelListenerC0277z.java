package com.google.android.gms.common.api.internal;

import android.app.PendingIntent;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Looper;
import com.google.android.gms.internal.base.zaq;
import java.util.concurrent.atomic.AtomicReference;
import z0.C0771b;
import z0.C0774e;
import z0.C0775f;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.z, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class DialogInterfaceOnCancelListenerC0277z extends LifecycleCallback implements DialogInterface.OnCancelListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public volatile boolean f3494a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AtomicReference f3495b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final zaq f3496c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final C0774e f3497d;
    public final n.c e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final C0259g f3498f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public DialogInterfaceOnCancelListenerC0277z(InterfaceC0263k interfaceC0263k, C0259g c0259g) {
        super(interfaceC0263k);
        C0774e c0774e = C0774e.f6959d;
        this.f3495b = new AtomicReference(null);
        this.f3496c = new zaq(Looper.getMainLooper());
        this.f3497d = c0774e;
        this.e = new n.c(0);
        this.f3498f = c0259g;
        this.mLifecycleFragment.d("ConnectionlessLifecycleHelper", this);
    }

    @Override // com.google.android.gms.common.api.internal.LifecycleCallback
    public final void onActivityResult(int i4, int i5, Intent intent) {
        AtomicReference atomicReference = this.f3495b;
        Y y4 = (Y) atomicReference.get();
        C0259g c0259g = this.f3498f;
        if (i4 != 1) {
            if (i4 == 2) {
                int iC = this.f3497d.c(getActivity(), C0775f.f6960a);
                if (iC == 0) {
                    atomicReference.set(null);
                    zaq zaqVar = c0259g.f3481n;
                    zaqVar.sendMessage(zaqVar.obtainMessage(3));
                    return;
                } else {
                    if (y4 == null) {
                        return;
                    }
                    if (y4.f3445b.f6949b == 18 && iC == 18) {
                        return;
                    }
                }
            }
        } else if (i5 == -1) {
            atomicReference.set(null);
            zaq zaqVar2 = c0259g.f3481n;
            zaqVar2.sendMessage(zaqVar2.obtainMessage(3));
            return;
        } else if (i5 == 0) {
            if (y4 == null) {
                return;
            }
            C0771b c0771b = new C0771b(1, intent != null ? intent.getIntExtra("<<ResolutionFailureErrorDetail>>", 13) : 13, null, y4.f3445b.toString());
            atomicReference.set(null);
            c0259g.h(c0771b, y4.f3444a);
            return;
        }
        if (y4 != null) {
            atomicReference.set(null);
            c0259g.h(y4.f3445b, y4.f3444a);
        }
    }

    @Override // android.content.DialogInterface.OnCancelListener
    public final void onCancel(DialogInterface dialogInterface) {
        C0771b c0771b = new C0771b(13, null);
        AtomicReference atomicReference = this.f3495b;
        Y y4 = (Y) atomicReference.get();
        int i4 = y4 == null ? -1 : y4.f3444a;
        atomicReference.set(null);
        this.f3498f.h(c0771b, i4);
    }

    @Override // com.google.android.gms.common.api.internal.LifecycleCallback
    public final void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        if (bundle != null) {
            this.f3495b.set(bundle.getBoolean("resolving_error", false) ? new Y(new C0771b(bundle.getInt("failed_status"), (PendingIntent) bundle.getParcelable("failed_resolution")), bundle.getInt("failed_client_id", -1)) : null);
        }
    }

    @Override // com.google.android.gms.common.api.internal.LifecycleCallback
    public final void onResume() {
        super.onResume();
        if (this.e.isEmpty()) {
            return;
        }
        this.f3498f.b(this);
    }

    @Override // com.google.android.gms.common.api.internal.LifecycleCallback
    public final void onSaveInstanceState(Bundle bundle) {
        super.onSaveInstanceState(bundle);
        Y y4 = (Y) this.f3495b.get();
        if (y4 == null) {
            return;
        }
        bundle.putBoolean("resolving_error", true);
        bundle.putInt("failed_client_id", y4.f3444a);
        C0771b c0771b = y4.f3445b;
        bundle.putInt("failed_status", c0771b.f6949b);
        bundle.putParcelable("failed_resolution", c0771b.f6950c);
    }

    @Override // com.google.android.gms.common.api.internal.LifecycleCallback
    public final void onStart() {
        super.onStart();
        this.f3494a = true;
        if (this.e.isEmpty()) {
            return;
        }
        this.f3498f.b(this);
    }

    @Override // com.google.android.gms.common.api.internal.LifecycleCallback
    public final void onStop() {
        this.f3494a = false;
        C0259g c0259g = this.f3498f;
        c0259g.getClass();
        synchronized (C0259g.f3467r) {
            try {
                if (c0259g.f3478k == this) {
                    c0259g.f3478k = null;
                    c0259g.f3479l.clear();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
