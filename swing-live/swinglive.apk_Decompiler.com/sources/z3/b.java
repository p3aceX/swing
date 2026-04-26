package Z3;

/* JADX INFO: loaded from: classes.dex */
public final class b implements c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final h f2604a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final a f2605b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public f f2606c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2607d;
    public boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public long f2608f;

    public b(h hVar) {
        this.f2604a = hVar;
        a aVarV = hVar.v();
        this.f2605b = aVarV;
        f fVar = aVarV.f2601a;
        this.f2606c = fVar;
        this.f2607d = fVar != null ? fVar.f2615b : -1;
    }

    @Override // java.lang.AutoCloseable
    public final void close() {
        this.e = true;
    }

    /* JADX WARN: Code restructure failed: missing block: B:11:0x0020, code lost:
    
        if (r3 == r5.f2615b) goto L15;
     */
    @Override // Z3.c
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final long m(Z3.a r12, long r13) {
        /*
            Method dump skipped, instruction units count: 224
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: Z3.b.m(Z3.a, long):long");
    }
}
