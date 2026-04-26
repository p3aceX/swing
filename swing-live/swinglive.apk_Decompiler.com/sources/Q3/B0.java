package Q3;

/* JADX INFO: loaded from: classes.dex */
public abstract class B0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final ThreadLocal f1566a = new ThreadLocal();

    public static Z a() {
        ThreadLocal threadLocal = f1566a;
        Z z4 = (Z) threadLocal.get();
        if (z4 != null) {
            return z4;
        }
        C0131h c0131h = new C0131h(Thread.currentThread());
        threadLocal.set(c0131h);
        return c0131h;
    }
}
