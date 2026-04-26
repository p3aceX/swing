package X3;

import J3.r;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class a extends Thread {

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2414o = AtomicIntegerFieldUpdater.newUpdater(a.class, "workerCtl$volatile");

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final m f2415a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final r f2416b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public b f2417c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public long f2418d;
    public long e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f2419f;
    private volatile int indexInArray;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f2420m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ c f2421n;
    private volatile Object nextParkedWorker;
    private volatile /* synthetic */ int workerCtl$volatile;

    public a(c cVar, int i4) {
        this.f2421n = cVar;
        setDaemon(true);
        setContextClassLoader(cVar.getClass().getClassLoader());
        this.f2415a = new m();
        this.f2416b = new r();
        this.f2417c = b.f2425d;
        this.nextParkedWorker = c.f2430q;
        int iNanoTime = (int) System.nanoTime();
        this.f2419f = iNanoTime == 0 ? 42 : iNanoTime;
        f(i4);
    }

    /* JADX WARN: Code restructure failed: missing block: B:20:0x0043, code lost:
    
        r13 = X3.m.f2453d.get(r3);
        r0 = X3.m.f2452c.get(r3);
     */
    /* JADX WARN: Code restructure failed: missing block: B:21:0x004f, code lost:
    
        if (r13 == r0) goto L68;
     */
    /* JADX WARN: Code restructure failed: missing block: B:23:0x0057, code lost:
    
        if (X3.m.e.get(r3) != 0) goto L25;
     */
    /* JADX WARN: Code restructure failed: missing block: B:25:0x005a, code lost:
    
        r0 = r0 - 1;
        r1 = r3.c(r0, true);
     */
    /* JADX WARN: Code restructure failed: missing block: B:26:0x0060, code lost:
    
        if (r1 == null) goto L71;
     */
    /* JADX WARN: Code restructure failed: missing block: B:27:0x0062, code lost:
    
        r2 = r1;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final X3.i a(boolean r13) {
        /*
            Method dump skipped, instruction units count: 201
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: X3.a.a(boolean):X3.i");
    }

    public final int b() {
        return this.indexInArray;
    }

    public final Object c() {
        return this.nextParkedWorker;
    }

    public final int d(int i4) {
        int i5 = this.f2419f;
        int i6 = i5 ^ (i5 << 13);
        int i7 = i6 ^ (i6 >> 17);
        int i8 = i7 ^ (i7 << 5);
        this.f2419f = i8;
        int i9 = i4 - 1;
        return (i9 & i4) == 0 ? i8 & i9 : (i8 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER) % i4;
    }

    public final i e() {
        int iD = d(2);
        c cVar = this.f2421n;
        if (iD == 0) {
            i iVar = (i) cVar.e.d();
            return iVar != null ? iVar : (i) cVar.f2435f.d();
        }
        i iVar2 = (i) cVar.f2435f.d();
        return iVar2 != null ? iVar2 : (i) cVar.e.d();
    }

    public final void f(int i4) {
        StringBuilder sb = new StringBuilder();
        sb.append(this.f2421n.f2434d);
        sb.append("-worker-");
        sb.append(i4 == 0 ? "TERMINATED" : String.valueOf(i4));
        setName(sb.toString());
        this.indexInArray = i4;
    }

    public final void g(Object obj) {
        this.nextParkedWorker = obj;
    }

    public final boolean h(b bVar) {
        b bVar2 = this.f2417c;
        boolean z4 = bVar2 == b.f2422a;
        if (z4) {
            c.f2428o.addAndGet(this.f2421n, 4398046511104L);
        }
        if (bVar2 != bVar) {
            this.f2417c = bVar;
        }
        return z4;
    }

    /* JADX WARN: Code restructure failed: missing block: B:25:0x006b, code lost:
    
        r7 = r5;
     */
    /* JADX WARN: Code restructure failed: missing block: B:42:0x00a0, code lost:
    
        r7 = -2;
        r23 = r6;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final X3.i i(int r26) {
        /*
            Method dump skipped, instruction units count: 264
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: X3.a.i(int):X3.i");
    }

    /* JADX WARN: Code restructure failed: missing block: B:128:0x0004, code lost:
    
        continue;
     */
    /* JADX WARN: Code restructure failed: missing block: B:129:0x0004, code lost:
    
        continue;
     */
    /* JADX WARN: Code restructure failed: missing block: B:130:0x0004, code lost:
    
        continue;
     */
    @Override // java.lang.Thread, java.lang.Runnable
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void run() {
        /*
            Method dump skipped, instruction units count: 427
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: X3.a.run():void");
    }
}
