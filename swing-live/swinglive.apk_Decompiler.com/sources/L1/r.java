package l1;

/* JADX INFO: loaded from: classes.dex */
public final class r {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Class f5624a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Class f5625b;

    public r(Class cls, Class cls2) {
        this.f5624a = cls;
        this.f5625b = cls2;
    }

    public static r a(Class cls) {
        return new r(q.class, cls);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || r.class != obj.getClass()) {
            return false;
        }
        r rVar = (r) obj;
        if (this.f5625b.equals(rVar.f5625b)) {
            return this.f5624a.equals(rVar.f5624a);
        }
        return false;
    }

    public final int hashCode() {
        return this.f5624a.hashCode() + (this.f5625b.hashCode() * 31);
    }

    public final String toString() {
        Class cls = this.f5625b;
        Class cls2 = this.f5624a;
        if (cls2 == q.class) {
            return cls.getName();
        }
        return "@" + cls2.getName() + " " + cls.getName();
    }
}
