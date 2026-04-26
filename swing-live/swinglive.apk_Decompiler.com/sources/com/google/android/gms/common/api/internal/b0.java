package com.google.android.gms.common.api.internal;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.os.Looper;
import com.google.android.gms.internal.common.zzi;
import java.io.FileDescriptor;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;
import java.util.WeakHashMap;

/* JADX INFO: loaded from: classes.dex */
public final class b0 extends Fragment implements InterfaceC0263k {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final WeakHashMap f3453d = new WeakHashMap();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Map f3454a = Collections.synchronizedMap(new n.b());

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f3455b = 0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Bundle f3456c;

    @Override // com.google.android.gms.common.api.internal.InterfaceC0263k
    public final void d(String str, LifecycleCallback lifecycleCallback) {
        Map map = this.f3454a;
        if (map.containsKey(str)) {
            throw new IllegalArgumentException(com.google.crypto.tink.shaded.protobuf.S.g("LifecycleCallback with tag ", str, " already added to this fragment."));
        }
        map.put(str, lifecycleCallback);
        if (this.f3455b > 0) {
            new zzi(Looper.getMainLooper()).post(new T2.r(this, lifecycleCallback, str, 1));
        }
    }

    @Override // android.app.Fragment
    public final void dump(String str, FileDescriptor fileDescriptor, PrintWriter printWriter, String[] strArr) {
        super.dump(str, fileDescriptor, printWriter, strArr);
        Iterator it = this.f3454a.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).dump(str, fileDescriptor, printWriter, strArr);
        }
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0263k
    public final LifecycleCallback e(Class cls, String str) {
        return (LifecycleCallback) cls.cast(this.f3454a.get(str));
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0263k
    public final Activity h() {
        return getActivity();
    }

    @Override // android.app.Fragment
    public final void onActivityResult(int i4, int i5, Intent intent) {
        super.onActivityResult(i4, i5, intent);
        Iterator it = this.f3454a.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onActivityResult(i4, i5, intent);
        }
    }

    @Override // android.app.Fragment
    public final void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        this.f3455b = 1;
        this.f3456c = bundle;
        for (Map.Entry entry : this.f3454a.entrySet()) {
            ((LifecycleCallback) entry.getValue()).onCreate(bundle != null ? bundle.getBundle((String) entry.getKey()) : null);
        }
    }

    @Override // android.app.Fragment
    public final void onDestroy() {
        super.onDestroy();
        this.f3455b = 5;
        Iterator it = this.f3454a.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onDestroy();
        }
    }

    @Override // android.app.Fragment
    public final void onResume() {
        super.onResume();
        this.f3455b = 3;
        Iterator it = this.f3454a.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onResume();
        }
    }

    @Override // android.app.Fragment
    public final void onSaveInstanceState(Bundle bundle) {
        super.onSaveInstanceState(bundle);
        if (bundle == null) {
            return;
        }
        for (Map.Entry entry : this.f3454a.entrySet()) {
            Bundle bundle2 = new Bundle();
            ((LifecycleCallback) entry.getValue()).onSaveInstanceState(bundle2);
            bundle.putBundle((String) entry.getKey(), bundle2);
        }
    }

    @Override // android.app.Fragment
    public final void onStart() {
        super.onStart();
        this.f3455b = 2;
        Iterator it = this.f3454a.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onStart();
        }
    }

    @Override // android.app.Fragment
    public final void onStop() {
        super.onStop();
        this.f3455b = 4;
        Iterator it = this.f3454a.values().iterator();
        while (it.hasNext()) {
            ((LifecycleCallback) it.next()).onStop();
        }
    }
}
