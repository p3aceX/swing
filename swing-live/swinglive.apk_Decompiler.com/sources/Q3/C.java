package Q3;

import y3.AbstractC0760a;

/* JADX INFO: loaded from: classes.dex */
public final class C extends AbstractC0760a {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final B f1567c = new B();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1568b;

    public C(String str) {
        super(f1567c);
        this.f1568b = str;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        return (obj instanceof C) && J3.i.a(this.f1568b, ((C) obj).f1568b);
    }

    public final int hashCode() {
        return this.f1568b.hashCode();
    }

    public final String toString() {
        return "CoroutineName(" + this.f1568b + ')';
    }
}
