package com.google.android.gms.common.api.internal;

import O.AbstractActivityC0114z;
import O.C0090a;
import O.C0113y;
import android.app.Activity;
import android.content.ContextWrapper;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Keep;
import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.lang.ref.WeakReference;
import java.util.WeakHashMap;

/* JADX INFO: loaded from: classes.dex */
public class LifecycleCallback {
    protected final InterfaceC0263k mLifecycleFragment;

    public LifecycleCallback(InterfaceC0263k interfaceC0263k) {
        this.mLifecycleFragment = interfaceC0263k;
    }

    @Keep
    private static InterfaceC0263k getChimeraLifecycleFragmentImpl(C0262j c0262j) {
        throw new IllegalStateException("Method not available in SDK.");
    }

    public static InterfaceC0263k getFragment(Activity activity) {
        return getFragment(new C0262j(activity));
    }

    public void dump(String str, FileDescriptor fileDescriptor, PrintWriter printWriter, String[] strArr) {
    }

    public Activity getActivity() {
        Activity activityH = this.mLifecycleFragment.h();
        com.google.android.gms.common.internal.F.g(activityH);
        return activityH;
    }

    public void onActivityResult(int i4, int i5, Intent intent) {
    }

    public void onCreate(Bundle bundle) {
    }

    public void onDestroy() {
    }

    public void onResume() {
    }

    public void onSaveInstanceState(Bundle bundle) {
    }

    public void onStart() {
    }

    public void onStop() {
    }

    public static InterfaceC0263k getFragment(C0262j c0262j) {
        b0 b0Var;
        c0 c0Var;
        Activity activity = c0262j.f3483a;
        if (!(activity instanceof AbstractActivityC0114z)) {
            if (activity == null) {
                throw new IllegalArgumentException("Can't get fragment for unexpected activity.");
            }
            WeakHashMap weakHashMap = b0.f3453d;
            WeakReference weakReference = (WeakReference) weakHashMap.get(activity);
            if (weakReference != null && (b0Var = (b0) weakReference.get()) != null) {
                return b0Var;
            }
            try {
                b0 b0Var2 = (b0) activity.getFragmentManager().findFragmentByTag("LifecycleFragmentImpl");
                if (b0Var2 == null || b0Var2.isRemoving()) {
                    b0Var2 = new b0();
                    activity.getFragmentManager().beginTransaction().add(b0Var2, "LifecycleFragmentImpl").commitAllowingStateLoss();
                }
                weakHashMap.put(activity, new WeakReference(b0Var2));
                return b0Var2;
            } catch (ClassCastException e) {
                throw new IllegalStateException("Fragment with tag LifecycleFragmentImpl is not a LifecycleFragmentImpl", e);
            }
        }
        AbstractActivityC0114z abstractActivityC0114z = (AbstractActivityC0114z) activity;
        WeakHashMap weakHashMap2 = c0.f3461b0;
        WeakReference weakReference2 = (WeakReference) weakHashMap2.get(abstractActivityC0114z);
        if (weakReference2 != null && (c0Var = (c0) weakReference2.get()) != null) {
            return c0Var;
        }
        try {
            c0 c0Var2 = (c0) ((C0113y) abstractActivityC0114z.f1438x.f104b).e.C("SupportLifecycleFragmentImpl");
            if (c0Var2 == null || c0Var2.f1418r) {
                c0Var2 = new c0();
                O.N n4 = ((C0113y) abstractActivityC0114z.f1438x.f104b).e;
                n4.getClass();
                C0090a c0090a = new C0090a(n4);
                c0090a.e(0, c0Var2, "SupportLifecycleFragmentImpl");
                c0090a.d(true);
            }
            weakHashMap2.put(abstractActivityC0114z, new WeakReference(c0Var2));
            return c0Var2;
        } catch (ClassCastException e4) {
            throw new IllegalStateException("Fragment with tag SupportLifecycleFragmentImpl is not a SupportLifecycleFragmentImpl", e4);
        }
    }

    public static InterfaceC0263k getFragment(ContextWrapper contextWrapper) {
        throw new UnsupportedOperationException();
    }
}
