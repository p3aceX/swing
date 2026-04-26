package Y0;

import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import d1.X;
import java.lang.reflect.Array;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f2470a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f2471b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f2472c;

    public d(Class cls, S0.g... gVarArr) {
        this.f2470a = cls;
        HashMap map = new HashMap();
        for (S0.g gVar : gVarArr) {
            boolean zContainsKey = map.containsKey(gVar.f1732a);
            Class cls2 = gVar.f1732a;
            if (zContainsKey) {
                throw new IllegalArgumentException("KeyTypeManager constructed with duplicate factories for primitive " + cls2.getCanonicalName());
            }
            map.put(cls2, gVar);
        }
        if (gVarArr.length > 0) {
            this.f2471b = gVarArr[0].f1732a;
        } else {
            this.f2471b = Void.class;
        }
        this.f2472c = Collections.unmodifiableMap(map);
    }

    public static boolean j(Set set, Object obj) {
        if (set == obj) {
            return true;
        }
        if (!(obj instanceof Set)) {
            return false;
        }
        Set set2 = (Set) obj;
        try {
            if (set.size() == set2.size()) {
                return set.containsAll(set2);
            }
            return false;
        } catch (ClassCastException | NullPointerException unused) {
            return false;
        }
    }

    public abstract void a();

    public abstract Object b(int i4, int i5);

    public abstract Map c();

    public abstract int d();

    public abstract int e(Object obj);

    public abstract int f(Object obj);

    public abstract void g(Object obj, Object obj2);

    public abstract void h(int i4);

    public abstract Object i(int i4, Object obj);

    public int k() {
        return 1;
    }

    public abstract String l();

    public Object m(AbstractC0296a abstractC0296a, Class cls) {
        S0.g gVar = (S0.g) ((Map) this.f2472c).get(cls);
        if (gVar != null) {
            return gVar.a(abstractC0296a);
        }
        throw new IllegalArgumentException("Requested primitive class " + cls.getCanonicalName() + " not supported.");
    }

    public abstract Q.b n();

    public abstract X o();

    public abstract AbstractC0296a p(AbstractC0303h abstractC0303h);

    public Object[] q(int i4, Object[] objArr) {
        int iD = d();
        if (objArr.length < iD) {
            objArr = (Object[]) Array.newInstance(objArr.getClass().getComponentType(), iD);
        }
        for (int i5 = 0; i5 < iD; i5++) {
            objArr[i5] = b(i5, i4);
        }
        if (objArr.length > iD) {
            objArr[iD] = null;
        }
        return objArr;
    }

    public abstract void r(AbstractC0296a abstractC0296a);
}
