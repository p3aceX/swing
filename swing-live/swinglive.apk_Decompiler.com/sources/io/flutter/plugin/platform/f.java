package io.flutter.plugin.platform;

import A.Y;
import A.Z;
import A.a0;
import D2.AbstractActivityC0029d;
import a.AbstractC0184a;
import android.os.Build;
import android.view.Window;
import e1.AbstractC0367g;
import java.util.Collections;
import java.util.HashSet;
import l1.C0522a;

/* JADX INFO: loaded from: classes.dex */
public final class f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4626a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f4627b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f4628c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f4629d;
    public Object e;

    public f(AbstractActivityC0029d abstractActivityC0029d, D2.v vVar, AbstractActivityC0029d abstractActivityC0029d2) {
        n nVar = new n(this, 1);
        this.f4627b = abstractActivityC0029d;
        this.f4629d = vVar;
        vVar.f261c = nVar;
        this.f4628c = abstractActivityC0029d2;
        this.f4626a = 1280;
    }

    public void a(l1.j jVar) {
        if (((HashSet) this.f4627b).contains(jVar.f5611a)) {
            throw new IllegalArgumentException("Components are not allowed to depend on interfaces they themselves provide.");
        }
        ((HashSet) this.f4628c).add(jVar);
    }

    public C0522a b() {
        if (((l1.d) this.f4629d) != null) {
            return new C0522a(new HashSet((HashSet) this.f4627b), new HashSet((HashSet) this.f4628c), this.f4626a, (l1.d) this.f4629d, (HashSet) this.e);
        }
        throw new IllegalStateException("Missing required property: factory.");
    }

    public void c(J1.c cVar) {
        Window window = ((AbstractActivityC0029d) this.f4627b).getWindow();
        window.getDecorView();
        int i4 = Build.VERSION.SDK_INT;
        AbstractC0184a a0Var = i4 >= 30 ? new a0(window) : i4 >= 26 ? new Z(window) : new Y(window);
        int i5 = Build.VERSION.SDK_INT;
        if (i5 < 30) {
            window.addFlags(Integer.MIN_VALUE);
            window.clearFlags(201326592);
        }
        int i6 = cVar.f783a;
        if (i6 != 0) {
            int iB = K.j.b(i6);
            if (iB == 0) {
                a0Var.W(false);
            } else if (iB == 1) {
                a0Var.W(true);
            }
        }
        Integer num = (Integer) cVar.f785c;
        if (num != null) {
            window.setStatusBarColor(num.intValue());
        }
        Boolean bool = (Boolean) cVar.f786d;
        if (bool != null && i5 >= 29) {
            window.setStatusBarContrastEnforced(bool.booleanValue());
        }
        if (i5 >= 26) {
            int i7 = cVar.f784b;
            if (i7 != 0) {
                int iB2 = K.j.b(i7);
                if (iB2 == 0) {
                    a0Var.V(false);
                } else if (iB2 == 1) {
                    a0Var.V(true);
                }
            }
            Integer num2 = (Integer) cVar.e;
            if (num2 != null) {
                window.setNavigationBarColor(num2.intValue());
            }
        }
        Integer num3 = (Integer) cVar.f787f;
        if (num3 != null && i5 >= 28) {
            window.setNavigationBarDividerColor(num3.intValue());
        }
        Boolean bool2 = (Boolean) cVar.f788g;
        if (bool2 != null && i5 >= 29) {
            window.setNavigationBarContrastEnforced(bool2.booleanValue());
        }
        this.e = cVar;
    }

    public void d() {
        ((AbstractActivityC0029d) this.f4627b).getWindow().getDecorView().setSystemUiVisibility(this.f4626a);
        J1.c cVar = (J1.c) this.e;
        if (cVar != null) {
            c(cVar);
        }
    }

    public f(Class cls, Class[] clsArr) {
        HashSet hashSet = new HashSet();
        this.f4627b = hashSet;
        this.f4628c = new HashSet();
        this.f4626a = 0;
        this.e = new HashSet();
        hashSet.add(l1.r.a(cls));
        for (Class cls2 : clsArr) {
            AbstractC0367g.a(cls2, "Null interface");
            ((HashSet) this.f4627b).add(l1.r.a(cls2));
        }
    }

    public f(l1.r rVar, l1.r[] rVarArr) {
        HashSet hashSet = new HashSet();
        this.f4627b = hashSet;
        this.f4628c = new HashSet();
        this.f4626a = 0;
        this.e = new HashSet();
        hashSet.add(rVar);
        for (l1.r rVar2 : rVarArr) {
            AbstractC0367g.a(rVar2, "Null interface");
        }
        Collections.addAll((HashSet) this.f4627b, rVarArr);
    }
}
