package Y;

import J3.i;
import android.os.Bundle;
import androidx.lifecycle.EnumC0221g;
import androidx.lifecycle.EnumC0222h;
import androidx.lifecycle.l;
import androidx.lifecycle.n;
import androidx.lifecycle.p;
import b.C0227d;
import b.ExecutorC0233j;
import java.util.ArrayList;
import java.util.Map;
import m.C0542d;
import m.C0544f;

/* JADX INFO: loaded from: classes.dex */
public final class f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f2462a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f2463b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f2464c;

    public f(g gVar) {
        this.f2463b = gVar;
        e eVar = new e();
        eVar.f2460c = new C0544f();
        this.f2464c = eVar;
    }

    public void a(double d5, double d6) {
        boolean z4 = this.f2462a;
        double[] dArr = (double[]) this.f2463b;
        double d7 = 1.0d;
        if (!z4) {
            d7 = 1.0d / (((dArr[7] * d6) + (dArr[3] * d5)) + dArr[15]);
        }
        double d8 = ((dArr[4] * d6) + (dArr[0] * d5) + dArr[12]) * d7;
        double d9 = ((dArr[5] * d6) + (dArr[1] * d5) + dArr[13]) * d7;
        double[] dArr2 = (double[]) this.f2464c;
        if (d8 < dArr2[0]) {
            dArr2[0] = d8;
        } else if (d8 > dArr2[1]) {
            dArr2[1] = d8;
        }
        if (d9 < dArr2[2]) {
            dArr2[2] = d9;
        } else if (d9 > dArr2[3]) {
            dArr2[3] = d9;
        }
    }

    public void b() {
        g gVar = (g) this.f2463b;
        p pVarI = gVar.i();
        if (pVarI.f3077c != EnumC0222h.f3068b) {
            throw new IllegalStateException("Restarter must be created only during owner's initialization stage");
        }
        pVarI.a(new a(gVar, 0));
        final e eVar = (e) this.f2464c;
        eVar.getClass();
        if (eVar.f2458a) {
            throw new IllegalStateException("SavedStateRegistry was already attached.");
        }
        pVarI.a(new l() { // from class: Y.b
            @Override // androidx.lifecycle.l
            public final void a(n nVar, EnumC0221g enumC0221g) {
                i.e(eVar, "this$0");
            }
        });
        eVar.f2458a = true;
        this.f2462a = true;
    }

    public void c(Bundle bundle) {
        if (!this.f2462a) {
            b();
        }
        p pVarI = ((g) this.f2463b).i();
        if (pVarI.f3077c.compareTo(EnumC0222h.f3070d) >= 0) {
            throw new IllegalStateException(("performRestore cannot be called when owner is " + pVarI.f3077c).toString());
        }
        e eVar = (e) this.f2464c;
        if (!eVar.f2458a) {
            throw new IllegalStateException("You must call performAttach() before calling performRestore(Bundle).");
        }
        if (eVar.f2459b) {
            throw new IllegalStateException("SavedStateRegistry was already restored.");
        }
        eVar.f2461d = bundle != null ? bundle.getBundle("androidx.lifecycle.BundlableSavedStateRegistry.key") : null;
        eVar.f2459b = true;
    }

    public void d(Bundle bundle) {
        e eVar = (e) this.f2464c;
        eVar.getClass();
        Bundle bundle2 = new Bundle();
        Bundle bundle3 = (Bundle) eVar.f2461d;
        if (bundle3 != null) {
            bundle2.putAll(bundle3);
        }
        C0544f c0544f = (C0544f) eVar.f2460c;
        c0544f.getClass();
        C0542d c0542d = new C0542d(c0544f);
        c0544f.f5760c.put(c0542d, Boolean.FALSE);
        while (c0542d.hasNext()) {
            Map.Entry entry = (Map.Entry) c0542d.next();
            bundle2.putBundle((String) entry.getKey(), ((d) entry.getValue()).a());
        }
        if (bundle2.isEmpty()) {
            return;
        }
        bundle.putBundle("androidx.lifecycle.BundlableSavedStateRegistry.key", bundle2);
    }

    public f(ExecutorC0233j executorC0233j, C0227d c0227d) {
        this.f2463b = new Object();
        this.f2464c = new ArrayList();
    }

    public f(boolean z4, double[] dArr, double[] dArr2) {
        this.f2462a = z4;
        this.f2463b = dArr;
        this.f2464c = dArr2;
    }
}
