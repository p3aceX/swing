package a0;

import android.content.Context;
import android.os.Bundle;
import android.os.Trace;
import com.swing.live.R;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: renamed from: a0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0185a {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static volatile C0185a f2629d;
    public static final Object e = new Object();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Context f2632c;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashSet f2631b = new HashSet();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final HashMap f2630a = new HashMap();

    public C0185a(Context context) {
        this.f2632c = context.getApplicationContext();
    }

    public static C0185a c(Context context) {
        if (f2629d == null) {
            synchronized (e) {
                try {
                    if (f2629d == null) {
                        f2629d = new C0185a(context);
                    }
                } finally {
                }
            }
        }
        return f2629d;
    }

    public final void a(Bundle bundle) {
        HashSet hashSet;
        String string = this.f2632c.getString(R.string.androidx_startup);
        if (bundle != null) {
            try {
                HashSet hashSet2 = new HashSet();
                Iterator<String> it = bundle.keySet().iterator();
                while (true) {
                    boolean zHasNext = it.hasNext();
                    hashSet = this.f2631b;
                    if (!zHasNext) {
                        break;
                    }
                    String next = it.next();
                    if (string.equals(bundle.getString(next, null))) {
                        Class<?> cls = Class.forName(next);
                        if (InterfaceC0186b.class.isAssignableFrom(cls)) {
                            hashSet.add(cls);
                        }
                    }
                }
                Iterator it2 = hashSet.iterator();
                while (it2.hasNext()) {
                    b((Class) it2.next(), hashSet2);
                }
            } catch (ClassNotFoundException e4) {
                throw new A0.b(e4);
            }
        }
    }

    public final void b(Class cls, HashSet hashSet) {
        if (H0.a.J()) {
            try {
                Trace.beginSection(H0.a.h0(cls.getSimpleName()));
            } catch (Throwable th) {
                Trace.endSection();
                throw th;
            }
        }
        if (hashSet.contains(cls)) {
            throw new IllegalStateException("Cannot initialize " + cls.getName() + ". Cycle detected.");
        }
        HashMap map = this.f2630a;
        if (map.containsKey(cls)) {
            map.get(cls);
        } else {
            hashSet.add(cls);
            try {
                InterfaceC0186b interfaceC0186b = (InterfaceC0186b) cls.getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
                List<Class> listA = interfaceC0186b.a();
                if (!listA.isEmpty()) {
                    for (Class cls2 : listA) {
                        if (!map.containsKey(cls2)) {
                            b(cls2, hashSet);
                        }
                    }
                }
                Object objB = interfaceC0186b.b(this.f2632c);
                hashSet.remove(cls);
                map.put(cls, objB);
            } catch (Throwable th2) {
                throw new A0.b(th2);
            }
        }
        Trace.endSection();
    }
}
