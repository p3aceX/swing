package X3;

/* JADX INFO: loaded from: classes.dex */
public final class e extends h {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final e f2439d;

    static {
        int i4 = k.f2447c;
        int i5 = k.f2448d;
        long j4 = k.e;
        String str = k.f2445a;
        e eVar = new e();
        eVar.f2441c = new c(i4, i5, j4, str);
        f2439d = eVar;
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
        throw new UnsupportedOperationException("Dispatchers.Default cannot be closed");
    }

    @Override // Q3.A
    public final String toString() {
        return "Dispatchers.Default";
    }
}
