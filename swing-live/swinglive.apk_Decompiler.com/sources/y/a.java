package Y;

import J3.i;
import O.AbstractComponentCallbacksC0109u;
import android.os.Build;
import android.os.Bundle;
import android.window.OnBackInvokedDispatcher;
import androidx.lifecycle.D;
import androidx.lifecycle.EnumC0221g;
import androidx.lifecycle.l;
import androidx.lifecycle.n;
import b.AbstractActivityC0234k;
import b.AbstractC0231h;
import b.u;
import com.google.crypto.tink.shaded.protobuf.S;
import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class a implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2455a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f2456b;

    public /* synthetic */ a(Object obj, int i4) {
        this.f2455a = i4;
        this.f2456b = obj;
    }

    @Override // androidx.lifecycle.l
    public final void a(n nVar, EnumC0221g enumC0221g) {
        switch (this.f2455a) {
            case 0:
                if (enumC0221g != EnumC0221g.ON_CREATE) {
                    throw new AssertionError("Next event must be ON_CREATE");
                }
                nVar.i().b(this);
                Bundle bundleA = ((g) this.f2456b).c().a("androidx.savedstate.Restarter");
                if (bundleA == null) {
                    return;
                }
                ArrayList<String> stringArrayList = bundleA.getStringArrayList("classes_to_restore");
                if (stringArrayList == null) {
                    throw new IllegalStateException("Bundle with restored state for the component \"androidx.savedstate.Restarter\" must contain list of strings by the key \"classes_to_restore\"");
                }
                Iterator<String> it = stringArrayList.iterator();
                if (it.hasNext()) {
                    String next = it.next();
                    try {
                        Class<? extends U> clsAsSubclass = Class.forName(next, false, a.class.getClassLoader()).asSubclass(c.class);
                        i.d(clsAsSubclass, "{\n                Class.…class.java)\n            }");
                        try {
                            Constructor declaredConstructor = clsAsSubclass.getDeclaredConstructor(new Class[0]);
                            declaredConstructor.setAccessible(true);
                            try {
                                i.d(declaredConstructor.newInstance(new Object[0]), "{\n                constr…wInstance()\n            }");
                                throw new ClassCastException();
                            } catch (Exception e) {
                                throw new RuntimeException(B1.a.m("Failed to instantiate ", next), e);
                            }
                        } catch (NoSuchMethodException e4) {
                            throw new IllegalStateException("Class " + clsAsSubclass.getSimpleName() + " must have default constructor in order to be automatically recreated", e4);
                        }
                    } catch (ClassNotFoundException e5) {
                        throw new RuntimeException(S.g("Class ", next, " wasn't found"), e5);
                    }
                }
                return;
            case 1:
                if (enumC0221g == EnumC0221g.ON_STOP) {
                    ((AbstractComponentCallbacksC0109u) this.f2456b).getClass();
                    return;
                }
                return;
            case 2:
                if (enumC0221g != EnumC0221g.ON_CREATE) {
                    throw new IllegalStateException(("Next event must be ON_CREATE, it was " + enumC0221g).toString());
                }
                nVar.i().b(this);
                D d5 = (D) this.f2456b;
                if (d5.f3054b) {
                    return;
                }
                Bundle bundleA2 = d5.f3053a.a("androidx.lifecycle.internal.SavedStateHandlesProvider");
                Bundle bundle = new Bundle();
                Bundle bundle2 = d5.f3055c;
                if (bundle2 != null) {
                    bundle.putAll(bundle2);
                }
                if (bundleA2 != null) {
                    bundle.putAll(bundleA2);
                }
                d5.f3055c = bundle;
                d5.f3054b = true;
                return;
            default:
                if (enumC0221g != EnumC0221g.ON_CREATE || Build.VERSION.SDK_INT < 33) {
                    return;
                }
                u uVar = ((AbstractActivityC0234k) this.f2456b).f3233m;
                OnBackInvokedDispatcher onBackInvokedDispatcherA = AbstractC0231h.a((AbstractActivityC0234k) nVar);
                uVar.getClass();
                i.e(onBackInvokedDispatcherA, "invoker");
                uVar.e = onBackInvokedDispatcherA;
                uVar.b(uVar.f3268g);
                return;
        }
    }
}
