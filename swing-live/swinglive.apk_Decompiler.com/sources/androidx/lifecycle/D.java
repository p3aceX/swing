package androidx.lifecycle;

import I.V;
import android.os.Bundle;
import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class D implements Y.d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Y.e f3053a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f3054b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Bundle f3055c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final w3.f f3056d;

    public D(Y.e eVar, I i4) {
        J3.i.e(eVar, "savedStateRegistry");
        this.f3053a = eVar;
        this.f3056d = new w3.f(new V(i4, 2));
    }

    @Override // Y.d
    public final Bundle a() {
        Bundle bundle = new Bundle();
        Bundle bundle2 = this.f3055c;
        if (bundle2 != null) {
            bundle.putAll(bundle2);
        }
        Iterator it = ((E) this.f3056d.a()).f3057c.entrySet().iterator();
        if (!it.hasNext()) {
            this.f3054b = false;
            return bundle;
        }
        Map.Entry entry = (Map.Entry) it.next();
        entry.getValue().getClass();
        throw new ClassCastException();
    }
}
