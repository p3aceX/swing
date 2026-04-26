package J3;

import I3.v;
import a.AbstractC0184a;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import x3.AbstractC0729i;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public final class e implements N3.b, d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Map f822b;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Class f823a;

    static {
        List listT = AbstractC0729i.T(I3.a.class, I3.l.class, I3.p.class, I3.q.class, y2.d.class, I3.r.class, I3.s.class, I3.t.class, I3.u.class, v.class, I3.b.class, I3.c.class, I3.d.class, I3.e.class, I3.f.class, I3.g.class, I3.h.class, I3.i.class, I3.j.class, I3.k.class, I3.m.class, I3.n.class, I3.o.class);
        ArrayList arrayList = new ArrayList(AbstractC0730j.V(listT));
        int i4 = 0;
        for (Object obj : listT) {
            int i5 = i4 + 1;
            if (i4 < 0) {
                AbstractC0729i.U();
                throw null;
            }
            arrayList.add(new w3.c((Class) obj, Integer.valueOf(i4)));
            i4 = i5;
        }
        f822b = x3.s.f0(arrayList);
    }

    public e(Class cls) {
        i.e(cls, "jClass");
        this.f823a = cls;
    }

    @Override // J3.d
    public final Class a() {
        return this.f823a;
    }

    public final String b() {
        String strD;
        Class cls = this.f823a;
        i.e(cls, "jClass");
        String strConcat = null;
        if (cls.isAnonymousClass()) {
            return null;
        }
        if (!cls.isLocalClass()) {
            if (!cls.isArray()) {
                String strD2 = u.d(cls.getName());
                return strD2 == null ? cls.getSimpleName() : strD2;
            }
            Class<?> componentType = cls.getComponentType();
            if (componentType.isPrimitive() && (strD = u.d(componentType.getName())) != null) {
                strConcat = strD.concat("Array");
            }
            return strConcat == null ? "Array" : strConcat;
        }
        String simpleName = cls.getSimpleName();
        Method enclosingMethod = cls.getEnclosingMethod();
        if (enclosingMethod != null) {
            return P3.m.G0(simpleName, enclosingMethod.getName() + '$');
        }
        Constructor<?> enclosingConstructor = cls.getEnclosingConstructor();
        if (enclosingConstructor != null) {
            return P3.m.G0(simpleName, enclosingConstructor.getName() + '$');
        }
        int iIndexOf = simpleName.indexOf(36, 0);
        if (iIndexOf == -1) {
            return simpleName;
        }
        String strSubstring = simpleName.substring(iIndexOf + 1, simpleName.length());
        i.d(strSubstring, "substring(...)");
        return strSubstring;
    }

    public final boolean equals(Object obj) {
        return (obj instanceof e) && AbstractC0184a.J(this).equals(AbstractC0184a.J((N3.b) obj));
    }

    public final int hashCode() {
        return AbstractC0184a.J(this).hashCode();
    }

    public final String toString() {
        return this.f823a.toString() + " (Kotlin reflection is not available)";
    }
}
