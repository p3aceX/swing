package com.google.android.gms.common.api.internal;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.WeakHashMap;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.y, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0276y implements OnCompleteListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f3492a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f3493b;

    public /* synthetic */ C0276y(Object obj, Object obj2) {
        this.f3493b = obj;
        this.f3492a = obj2;
    }

    public void a(Status status, boolean z4) {
        HashMap map;
        HashMap map2;
        synchronized (((Map) this.f3492a)) {
            map = new HashMap((Map) this.f3492a);
        }
        synchronized (((Map) this.f3493b)) {
            map2 = new HashMap((Map) this.f3493b);
        }
        for (Map.Entry entry : map.entrySet()) {
            if (z4 || ((Boolean) entry.getValue()).booleanValue()) {
                ((BasePendingResult) entry.getKey()).forceFailureUnlessReady(status);
            }
        }
        for (Map.Entry entry2 : map2.entrySet()) {
            if (z4 || ((Boolean) entry2.getValue()).booleanValue()) {
                ((TaskCompletionSource) entry2.getKey()).trySetException(new com.google.android.gms.common.api.j(status));
            }
        }
    }

    @Override // com.google.android.gms.tasks.OnCompleteListener
    public void onComplete(Task task) {
        ((Map) ((C0276y) this.f3493b).f3493b).remove((TaskCompletionSource) this.f3492a);
    }

    public C0276y() {
        this.f3492a = Collections.synchronizedMap(new WeakHashMap());
        this.f3493b = Collections.synchronizedMap(new WeakHashMap());
    }
}
