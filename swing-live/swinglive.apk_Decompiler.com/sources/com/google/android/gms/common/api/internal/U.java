package com.google.android.gms.common.api.internal;

import android.os.DeadObjectException;
import android.util.Log;
import com.google.android.gms.common.api.Status;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class U extends X {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AbstractC0256d f3438b;

    public U(int i4, AbstractC0256d abstractC0256d) {
        super(i4);
        com.google.android.gms.common.internal.F.h(abstractC0256d, "Null methods are not runnable.");
        this.f3438b = abstractC0256d;
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void a(Status status) {
        try {
            this.f3438b.setFailedResult(status);
        } catch (IllegalStateException e) {
            Log.w("ApiCallRunner", "Exception reporting failure", e);
        }
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void b(RuntimeException runtimeException) {
        String simpleName = runtimeException.getClass().getSimpleName();
        String localizedMessage = runtimeException.getLocalizedMessage();
        StringBuilder sb = new StringBuilder(simpleName.length() + 2 + String.valueOf(localizedMessage).length());
        sb.append(simpleName);
        sb.append(": ");
        sb.append(localizedMessage);
        try {
            this.f3438b.setFailedResult(new Status(10, sb.toString()));
        } catch (IllegalStateException e) {
            Log.w("ApiCallRunner", "Exception reporting failure", e);
        }
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void c(E e) throws DeadObjectException {
        try {
            this.f3438b.run(e.f3394b);
        } catch (RuntimeException e4) {
            b(e4);
        }
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void d(C0276y c0276y, boolean z4) {
        Boolean boolValueOf = Boolean.valueOf(z4);
        Map map = (Map) c0276y.f3492a;
        AbstractC0256d abstractC0256d = this.f3438b;
        map.put(abstractC0256d, boolValueOf);
        abstractC0256d.addStatusListener(new C0275x(c0276y, abstractC0256d));
    }
}
